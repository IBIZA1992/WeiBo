//
//  WBMineLikeViewController.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/8.
//

#import "WBMineLikeViewController.h"
#import "WBWeiBoItem.h"
#import "WBWeiBoTableViewCell.h"
#import "WebKit/WebKit.h"
#import "WBScreen.h"
#import "WBWebViewController.h"
#import "WBOauthModel.h"
#import "WeiboSDK.h"
#import "WBLikeModel.h"
#import "WBHistoryModel.h"

@interface WBMineLikeViewController ()<UITableViewDataSource, UITableViewDelegate, WBWeiBoTableViewCellDelegate>
@property(nonatomic, strong, readwrite) NSMutableArray *dataArray;
@property(nonatomic, strong, readwrite) UITableView *tableView;
@property(nonatomic, strong, readwrite) WBOauthModel *oauthModel;
@property(nonatomic, strong, readwrite) WBLikeModel *likeModel;
@end

@implementation WBMineLikeViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.likeModel = [WBLikeModel shareInstance];
    self.dataArray = self.likeModel.likeWeiBoMutableArray;
    
    if (self.likeModel.likeWeiBoMutableArray.count == 0) {  // 没收藏微博就返回
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"您还没有收藏微博" message:nil preferredStyle:UIAlertControllerStyleAlert];
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
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WBWeiBoTableViewCell *cell = [[WBWeiBoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"id"];
    cell.delegate = self;
    __weak typeof(self) wself = self;
    [cell layoutTableViewCellWithItem:[self.dataArray objectAtIndex:indexPath.row] clickWebBlock:^(NSURL * _Nonnull URL) {
        __strong typeof(wself) strongSelf = wself;
        WBWebViewController *webViewController = [[WBWebViewController alloc] initWithRequest:[NSURLRequest requestWithURL:URL]];
        webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [strongSelf presentViewController:webViewController animated:YES completion:nil];
    }];
    return cell;
}

#pragma mark - WBWeiBoTableViewCellDelegate

- (void)tableViewCell:(UITableViewCell *)tableViewCell clickLikeFillButton:(UIButton *)likeButton {
    self.dataArray = self.likeModel.likeWeiBoMutableArray;
    [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:tableViewCell]] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (self.dataArray.count == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"您还没有收藏微博" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull   action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [sureBtn setValue:[UIColor redColor] forKey:@"titleTextColor"];
        [alertController addAction:sureBtn];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end

