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

@interface WBWeiBoDetailView()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, WBWeiBoLoaderDelegate>
@property(nonatomic, strong, readwrite) WBWeiBoLoader *weiBoLoader;
@property(nonatomic, strong, readwrite) WBOauthModel *oauthModel;
@property(nonatomic, strong, readwrite) UILabel *tableHeaderLabel;
@property(nonatomic, strong, readwrite) UILabel *tableFooterLabel;
@property(nonatomic, assign, readwrite) CGFloat perContentOffsetY;
@property(nonatomic, assign, readwrite) BOOL perUserInteractionEnabled;
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
        
        _tableHeaderLabel = [[UILabel alloc] init];
        _tableHeaderLabel.text = @"下拉刷新";
        _tableHeaderLabel.font = [UIFont systemFontOfSize:17];
        _tableHeaderLabel.alpha = 0.5;
        [_tableHeaderLabel sizeToFit];
        _tableHeaderLabel.center = CGPointMake(SCREEN_WIDTH / 2, -27);
        _tableHeaderLabel.text = @"加载中 ... ";
        [_tableView addSubview:_tableHeaderLabel];
        
        _tableFooterLabel = [[UILabel alloc] init];
        _tableFooterLabel.font = [UIFont systemFontOfSize:17];
        _tableFooterLabel.alpha = 0.5;
        [_tableView addSubview:_tableFooterLabel];
        
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.userInteractionEnabled == NO && self.perUserInteractionEnabled) {
        if (self.tableView.contentOffset.y < 0) {
            self.tableHeaderLabel.text = @"加载中 ... ";
        } else if (self.tableView.contentOffset.y > 0)  {
            self.tableFooterLabel.text = @"加载中 ... ";
        }
    } else if (scrollView.contentOffset.y < -70 && self.perContentOffsetY >= -70 && self.userInteractionEnabled) {
        self.tableHeaderLabel.text = @"释放更新";
    } else if (((scrollView.contentOffset.y > -70 && self.perContentOffsetY <= -70) || (self.perContentOffsetY >= 0 && self.tableView.contentOffset.y < 0)) && self.userInteractionEnabled) {
        self.tableHeaderLabel.text = @"下拉刷新";
    } else if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height + 40 && !((self.perContentOffsetY + scrollView.frame.size.height) >= scrollView.contentSize.height + 40) && self.userInteractionEnabled) {
        self.tableFooterLabel.text = @"释放加载";
        [self.tableFooterLabel sizeToFit];
        self.tableFooterLabel.center = CGPointMake(SCREEN_WIDTH / 2, scrollView.contentSize.height + 20);
    } else if ((scrollView.contentOffset.y + scrollView.frame.size.height) < scrollView.contentSize.height + 40 && !((self.perContentOffsetY + scrollView.frame.size.height) < scrollView.contentSize.height + 40) && self.userInteractionEnabled) {
        self.tableFooterLabel.text = @"加载更多";
        [self.tableFooterLabel sizeToFit];
        self.tableFooterLabel.center = CGPointMake(SCREEN_WIDTH / 2, scrollView.contentSize.height + 20);
    }
    self.perContentOffsetY = scrollView.contentOffset.y;
    self.perUserInteractionEnabled = self.userInteractionEnabled;
}

//但用户停止拖动，手指将要离开屏幕的时候调用。
- (void)scrollViewWillBeginDecelerating:(UIScrollView*)scrollView {
    if (scrollView.contentOffset.y < -70) {
        [self beginDownRefresh];
    }
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height + 40) {
        [self _beginUpRefresh];
    }
}

#pragma mark - WBWeiBoLoaderDelegate

- (void)didFinishLoader {
    if (self.userInteractionEnabled == NO) {
        if (self.tableView.contentOffset.y < 0) {
            [self _endDownRefresh];
        } else if (self.tableView.contentOffset.y > 0)  {
            [self _endUpRefresh];
        }
    }
    self.userInteractionEnabled = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(weiBoDetailView:userInteraction:)]) {
        [self.delegate weiBoDetailView:self userInteraction:YES];
    }
}

#pragma mark - public method

- (void)beginDownRefresh {
    if (self.isInitializedRefresh == NO) {
        self.isInitializedRefresh = YES;
    }
    if (self.tableView.contentOffset.y > -70 && self.dataArray.count != 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];  // 移动
    }
    
    // 禁用屏幕点击
    self.userInteractionEnabled = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(weiBoDetailView:userInteraction:)]) {
        [self.delegate weiBoDetailView:self userInteraction:NO];
    }
    [UIView animateWithDuration:0.3
                     animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(70, 0.0f, 0.0f, 0.0f);  // 延长tableView
        self.tableView.contentOffset = CGPointMake(0, -70);
        } completion:^(BOOL finished) {
            self.tableHeaderLabel.text = @"加载中 ... ";
            self.pageNum = 0;
            __weak typeof(self) wself = self;
            [self.weiBoLoader loadWeiBoDataWithPageNmu:0 category:self.category finishBlock:^(BOOL success, NSMutableArray<WBWeiBoItem *> * _Nonnull dataArray) {
                __strong typeof(wself) strongSelf = wself;
                if (dataArray.count != 0) {
                    strongSelf.dataArray = dataArray;
                    [strongSelf.tableView reloadData];
                }
            }];
        }];
}

#pragma mark - private method

- (void)_endDownRefresh {
    [UIView animateWithDuration:0.2 animations:^{
            UIEdgeInsets edgeInsets = self.tableView.contentInset;
            edgeInsets.top = 0;
            self.tableView.contentInset = edgeInsets;
    }];
}

- (void)_beginUpRefresh {
    // 禁用屏幕点击
    self.userInteractionEnabled = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(weiBoDetailView:userInteraction:)]) {
        [self.delegate weiBoDetailView:self userInteraction:NO];
    }
    [UIView animateWithDuration:0.3
                     animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 40, 0.0f);  // 延长tableView
        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height + 40);
        } completion:^(BOOL finished) {
            self.pageNum++;
            __weak typeof(self) wself = self;
            [self.weiBoLoader loadWeiBoDataWithPageNmu:self.pageNum category:self.category finishBlock:^(BOOL success, NSMutableArray<WBWeiBoItem *> * _Nonnull dataArray) {
                __strong typeof(wself) strongSelf = wself;
                if (dataArray.count != 0) {
                    [strongSelf.dataArray addObjectsFromArray:dataArray];
                    [strongSelf.tableView reloadData];
                }
            }];
        }];
}

- (void)_endUpRefresh {
    [UIView animateWithDuration:0.2 animations:^{
            UIEdgeInsets edgeInsets = self.tableView.contentInset;
            edgeInsets.bottom = 0;
            self.tableView.contentInset = edgeInsets;
    }];
    self.tableFooterLabel.text = @"";
}

@end
