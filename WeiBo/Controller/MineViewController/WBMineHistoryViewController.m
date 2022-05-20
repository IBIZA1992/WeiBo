//
//  WBMineHistoryViewController.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/9.
//

#import "WBMineHistoryViewController.h"
#import "WBWeiBoItem.h"
#import "WBWeiBoTableViewCell.h"
#import "WebKit/WebKit.h"
#import "WBScreen.h"
#import "WBWebViewController.h"
#import "WBOauthModel.h"
#import "WeiboSDK.h"
#import "WBHistoryModel.h"

@interface WBMineHistoryViewController ()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong, readwrite) NSMutableArray *dataArray;
@property(nonatomic, strong, readwrite) UITableView *tableView;
@property(nonatomic, strong, readwrite) WBOauthModel *oauthModel;
@property(nonatomic, strong, readwrite) WBHistoryModel *historyModel;
@end

@implementation WBMineHistoryViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.historyModel = [WBHistoryModel shareInstance];
    self.dataArray = self.historyModel.historyWeiBoMutableArray.copy;
    
    if (self.historyModel.historyWeiBoMutableArray.count == 0) {  // 没微博就返回
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"您还没有浏览历史" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull   action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [sureBtn setValue:[UIColor redColor] forKey:@"titleTextColor"];
        [alertController addAction:sureBtn];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        self.oauthModel = [WBOauthModel shareInstance];
        
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        self.tableView.backgroundColor = [UIColor colorWithRed:0.933 green:0.929 blue:0.949 alpha:1];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:self.tableView];
        
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ((WBWeiBoItem *)self.dataArray[indexPath.row]).height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.oauthModel.isAlive) {
        WBWeiBoItem *item = self.dataArray[indexPath.row];
        [WeiboSDK linkToSingleBlog:item.idstr blogID:item.mblogid];
        BOOL isNew = YES;
        for (WBWeiBoItem *weiBoArrayItem in self.historyModel.historyWeiBoMutableArray) {  // 如果存在
            if ([item.idstr isEqualToString:weiBoArrayItem.idstr]) {
                [self.historyModel.historyWeiBoMutableArray removeObject:weiBoArrayItem];
                [self.historyModel.historyWeiBoMutableArray insertObject:item atIndex:0];
                [self.historyModel saveDataFromLocal];
                isNew = NO;
                break;
            }
        }
        if (isNew) {
            [self.historyModel.historyWeiBoMutableArray insertObject:item atIndex:0];
            [self.historyModel saveDataFromLocal];
        }
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请先登陆，再看详情" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull   action) {
        }];
        [sureBtn setValue:[UIColor redColor] forKey:@"titleTextColor"];
        [alertController addAction:sureBtn];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WBWeiBoTableViewCell *cell = [[WBWeiBoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"id"];
    __weak typeof(self) wself = self;
    [cell layoutTableViewCellWithItem:[self.dataArray objectAtIndex:indexPath.row] clickWebBlock:^(NSURL * _Nonnull URL) {
        __strong typeof(wself) strongSelf = wself;
        WBWebViewController *webViewController = [[WBWebViewController alloc] initWithRequest:[NSURLRequest requestWithURL:URL]];
        webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [strongSelf presentViewController:webViewController animated:YES completion:nil];
    }];
    return cell;
}

@end

