//
//  WBWeiBoDetailView.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/11.
//

#import "WBWeiBoDetailView.h"
#import "WBWeiBoItem.h"
#import "WBWeiBoTableViewCell.h"
#import "WebKit/WebKit.h"
#import "WBScreen.h"
#import "WBWebViewController.h"
#import "WBOauthModel.h"
#import "WeiboSDK.h"
#import "WBHistoryModel.h"
#import "WBCacheWeiBoModel.h"
#import <MJRefresh.h>

@interface WBWeiBoDetailView()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, WBWeiBoLoaderDelegate>
@property(nonatomic, strong, readwrite) WBWeiBoLoader *weiBoLoader;
@property(nonatomic, strong, readwrite) WBOauthModel *oauthModel;
@property(nonatomic, assign ,readwrite) NSInteger pageNum;  // 页数,初始值为0
@property(nonatomic, assign, readwrite) WBWeiBoCategory category;
@end

@implementation WBWeiBoDetailView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame andCategory:(WBWeiBoCategory)category{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.933 green:0.929 blue:0.949 alpha:1];
        
        _category = category;
        _oauthModel = [WBOauthModel shareInstance];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 88 + 40, self.bounds.size.width, self.bounds.size.height - (88 + 40) - 83)];
        _tableView.backgroundColor = [UIColor colorWithRed:0.933 green:0.929 blue:0.949 alpha:1];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        MJRefreshAutoFooter *footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        footer.triggerAutomaticallyRefreshPercent = -60;
        _tableView.mj_footer = footer;
        
        [self addSubview:_tableView];

        _weiBoLoader = [[WBWeiBoLoader alloc] init];  // 加载数据
        _weiBoLoader.delegate = self;
        WBCacheWeiBoModel *cacheWeiBoModel = [WBCacheWeiBoModel shareInstance];
        NSArray<WBWeiBoItem *> *dataArray = [cacheWeiBoModel readDataFromLocalWithCategory:self.category];
        if (dataArray) {
            self.dataArray = dataArray.mutableCopy;
            [self.tableView reloadData];
        }
        self.isInitializedRefresh = NO;
    }
    return self;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ((WBWeiBoItem *)self.dataArray[indexPath.row]).height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.oauthModel.isAlive) {
        WBWeiBoItem *item = self.dataArray[indexPath.row];
        [WeiboSDK linkToSingleBlog:item.idstr blogID:item.mblogid];
        WBHistoryModel *historyModel = [WBHistoryModel shareInstance];
        BOOL isNew = YES;
        for (WBWeiBoItem *weiBoArrayItem in historyModel.historyWeiBoMutableArray) {  // 如果存在
            if ([item.idstr isEqualToString:weiBoArrayItem.idstr]) {
                [historyModel.historyWeiBoMutableArray removeObject:weiBoArrayItem];
                [historyModel.historyWeiBoMutableArray insertObject:item atIndex:0];
                [historyModel saveDataFromLocal];
                isNew = NO;
                break;
            }
        }
        if (isNew) {
            [historyModel.historyWeiBoMutableArray insertObject:item atIndex:0];
            [historyModel saveDataFromLocal];
        }
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请先登陆，再看详情" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull   action) {
        }];
        [sureBtn setValue:[UIColor redColor] forKey:@"titleTextColor"];
        [alertController addAction:sureBtn];
        if (self.delegate && [self.delegate respondsToSelector:@selector(weiBoDetailView:presentViewController:)]) {
            [self.delegate weiBoDetailView:self presentViewController:alertController];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = ((WBWeiBoItem *)self.dataArray[indexPath.row]).idstr;
    WBWeiBoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WBWeiBoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    __weak typeof(self) wself = self;
    [cell layoutTableViewCellWithItem:[self.dataArray objectAtIndex:indexPath.row] clickWebBlock:^(NSURL * _Nonnull URL) {
        __strong typeof(wself) strongSelf = wself;
        WBWebViewController *webViewController = [[WBWebViewController alloc] initWithRequest:[NSURLRequest requestWithURL:URL]];
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(weiBoDetailView:pushViewController:)]) {
            [strongSelf.delegate weiBoDetailView:self pushViewController:webViewController];
        }
    }];
    return cell;
}

#pragma mark - WBWeiBoLoaderDelegate

- (void)didFinishLoader {
    if (self.tableView.contentOffset.y < 0) {
        [self.tableView.mj_header endRefreshing];
    } else if (self.tableView.contentOffset.y > 0)  {
        [self.tableView.mj_footer endRefreshing];
    }
}

#pragma mark - public method

- (void)beginDownRefresh {
    // 是否初始化页面
    if (self.isInitializedRefresh == NO) {
        self.isInitializedRefresh = YES;
    }
    // 开始刷新
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - MJRefresh

- (void)loadNewData {
    self.pageNum = 0;
    __weak typeof(self) wself = self;
    [self.weiBoLoader loadWeiBoDataWithPageNmu:0 category:self.category finishBlock:^(BOOL success, NSMutableArray<WBWeiBoItem *> * _Nonnull dataArray) {
        __strong typeof(wself) strongSelf = wself;
        if (dataArray.count != 0) {
            strongSelf.dataArray = dataArray;
            [strongSelf.tableView reloadData];
        }
    }];
}

- (void)loadMoreData {
    self.pageNum++;
    __weak typeof(self) wself = self;
    [self.weiBoLoader loadWeiBoDataWithPageNmu:self.pageNum category:self.category finishBlock:^(BOOL success, NSMutableArray<WBWeiBoItem *> * _Nonnull dataArray) {
        __strong typeof(wself) strongSelf = wself;
        if (dataArray.count != 0) {
            [strongSelf.dataArray addObjectsFromArray:dataArray];
            [strongSelf.tableView reloadData];
        }
    }];
}

@end
