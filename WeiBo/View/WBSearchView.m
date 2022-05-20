//
//  WBSearchView.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/13.
//

#import "WBSearchView.h"
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

@interface WBSearchView()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, strong, readwrite) NSArray<WBWeiBoItem *> *dataArray;
@property(nonatomic, strong, readwrite) WBOauthModel *oauthModel;
@end

@implementation WBSearchView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.933 green:0.929 blue:0.949 alpha:1];
        
        _oauthModel = [WBOauthModel shareInstance];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _tableView.backgroundColor = [UIColor colorWithRed:0.933 green:0.929 blue:0.949 alpha:1];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self addSubview:_tableView];
        
        self.dataArray = @[].copy;
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
        if (self.delegate && [self.delegate respondsToSelector:@selector(searchView:presentViewController:)]) {
            [self.delegate searchView:self presentViewController:alertController];
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
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(searchView:presentWebViewController:)]) {
            [strongSelf.delegate searchView:self presentWebViewController:webViewController];
        }
    }];
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchViewWillBeginDragging:)]) {
        [self.delegate searchViewWillBeginDragging:self];
    }
}

#pragma mark - public method

- (void)searchWithString:(NSString *)searchString dataArray:(NSArray<WBWeiBoItem *> *)searchDataArray {
    NSMutableArray *dataMutableArray = @[].mutableCopy;
    NSArray *separatedString = [searchString componentsSeparatedByString:@" "];  // 有空格将字符串分开
    NSMutableArray *separatedStringArray = @[].mutableCopy;
    for (NSString *str in separatedString) {
        if (![str isEqualToString:@""]) {
            [separatedStringArray addObject:str];
        }
    }
    
    for (WBWeiBoItem *item in searchDataArray) {
        NSString *text = [item.user_name stringByAppendingString:item.text_raw];  // 解决xx人 做xx事搜索
        BOOL isContainText = YES;
        for (NSString *str in separatedStringArray) {
            if (![self _searchString:str intext:text]) {
                isContainText =NO;
            }
        }
        if (isContainText) {
            [dataMutableArray addObject:item];
        }
    }
    
    self.dataArray = dataMutableArray.copy;
    
    self.tableView.contentOffset = CGPointMake(0, 0);
    [self.tableView reloadData];
}

#pragma mark - private method

/// text是否在string中存在
/// @param searchString 要搜索的字符串
/// @param text 整体字符串
- (BOOL)_searchString:(NSString *)searchString intext:(NSString *)text {
    NSMutableArray *searchStringArray = [NSMutableArray array];
    for (NSInteger i = 0; i < searchString.length; i++) {
        NSRange range =  NSMakeRange(i, 1);
        NSString *subStr = [searchString substringWithRange:range];
        [searchStringArray addObject:subStr];
    }
    for (NSString *str in searchStringArray) {
        if ([text containsString:str]) {
            NSRange range = [text rangeOfString:str];
            text = [text substringFromIndex:range.location + 1];
        } else {
            return NO;
        }
    }
    return YES;
}

@end
