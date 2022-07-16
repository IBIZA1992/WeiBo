//
//  WBWeiBoViewController.m
//  WeiBo
//
//  Created by JiangNan on 2022/4/30.
//

#import "WBWeiBoViewController.h"
#import "WBScreen.h"
#import "WBWeiBoDetailView.h"
#import "WBOauthModel.h"
#import "WeiboSDK.h"
#import "WBWeiBoLoader.h"

@interface WBWeiBoViewController ()<UIScrollViewDelegate, WBWeiBoDetailViewDelegate>
@property(nonatomic, strong, readwrite) UIButton *sentWeiBoButton;
@property(nonatomic, strong, readwrite) UIScrollView *scrollView;
@property(nonatomic, strong, readwrite) WBWeiBoDetailView *detailMineView;
@property(nonatomic, strong, readwrite) WBWeiBoDetailView *detailHotView;
@property(nonatomic, strong, readwrite) WBWeiBoDetailView *detailSportsView;
@property(nonatomic, strong, readwrite) WBWeiBoDetailView *detailTechnologyView;
@property(nonatomic, strong, readwrite) WBWeiBoDetailView *detailEntertainmentView;
@property(nonatomic, strong, readwrite) UIView *switchBar;
@property(nonatomic, strong, readwrite) UIButton *mineButton;
@property(nonatomic, strong, readwrite) UIButton *hotButton;
@property(nonatomic, strong, readwrite) UIButton *sportsButton;
@property(nonatomic, strong, readwrite) UIButton *technologyButton;
@property(nonatomic, strong, readwrite) UIButton *entertainmentButton;
@property(nonatomic, strong, readwrite) NSMutableArray *buttonArray;
@property(nonatomic, strong, readwrite) WBOauthModel *oauthModel;
@property(nonatomic, strong, readwrite) UIView *slideBlockView;
@end

@implementation WBWeiBoViewController

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"微博";
        self.tabBarItem.image = [UIImage imageNamed:@"weibo"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"weibo.fill"];
    }
    return self;
}

// 返回页面时，刷新页面，更新收藏状态
- (void)viewDidAppear:(BOOL)animated {
    [self _tableViewReloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.933 green:0.929 blue:0.949 alpha:1];
    
    self.oauthModel = [WBOauthModel shareInstance];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * 5, 0);
    self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    self.detailHotView = [[WBWeiBoDetailView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                      andCategory:WBWeiBoCategoryHot];
    self.detailHotView.delegate = self;
    [self.scrollView addSubview:self.detailHotView];
    [self.detailHotView beginDownRefresh];
    
    self.detailMineView = [[WBWeiBoDetailView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                       andCategory:WBWeiBoCategoryMine];
    self.detailMineView.delegate = self;
    
    self.detailSportsView = [[WBWeiBoDetailView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                         andCategory:WBWeiBoCategorySports];
    self.detailSportsView.delegate = self;
    [self.scrollView addSubview:self.detailSportsView];
    
    self.detailTechnologyView = [[WBWeiBoDetailView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 3, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                             andCategory:WBWeiBoCategoryTechnology];
    self.detailTechnologyView.delegate = self;
    [self.scrollView addSubview:self.detailTechnologyView];
    
    self.detailEntertainmentView = [[WBWeiBoDetailView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 4, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                andCategory:WBWeiBoCategoryEntertainment];
    self.detailEntertainmentView.delegate = self;
    [self.scrollView addSubview:self.detailEntertainmentView];
    
    // 设置发微博按钮
    UIView *buttonBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, SCREEN_HEIGHT - 155, 45, 45)];
    buttonBackgroundView.layer.cornerRadius = 22.5;
    buttonBackgroundView.layer.masksToBounds = YES;
    buttonBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:buttonBackgroundView];
    self.sentWeiBoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    self.sentWeiBoButton.layer.cornerRadius = 22.5;
    self.sentWeiBoButton.layer.masksToBounds = YES;
    [self.sentWeiBoButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [self.sentWeiBoButton addTarget:self
                             action:@selector(_sendWeiBo)
                   forControlEvents:UIControlEventTouchUpInside];
    [buttonBackgroundView addSubview:self.sentWeiBoButton];
    
    // 设置切换显示bar
    self.switchBar = [[UIView alloc] initWithFrame:CGRectMake(0, 88, SCREEN_WIDTH, 40)];
    self.switchBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.switchBar];
    
    self.buttonArray = @[].mutableCopy;
    
    self.mineButton = [[UIButton alloc] init];
    [self.mineButton setTitle:@"我的" forState:UIControlStateNormal];
    [self.mineButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.mineButton sizeToFit];
    self.mineButton.center = CGPointMake(SCREEN_WIDTH / 6 * 1, 20);
    [self.mineButton addTarget:self
                        action:@selector(_clickMineButton)
              forControlEvents:UIControlEventTouchUpInside];
    [self.buttonArray addObject:self.mineButton];
    [self.switchBar addSubview:self.mineButton];
    
    self.hotButton = [[UIButton alloc] init];
    [self.hotButton setTitle:@"热点" forState:UIControlStateNormal];
    [self.hotButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.hotButton sizeToFit];
    self.hotButton.center = CGPointMake(SCREEN_WIDTH / 6 * 2, 20);
    [self.hotButton addTarget:self
                       action:@selector(_clickHotButton)
             forControlEvents:UIControlEventTouchUpInside];
    [self.buttonArray addObject:self.hotButton];
    [self.switchBar addSubview:self.hotButton];
    
    self.sportsButton = [[UIButton alloc] init];
    [self.sportsButton setTitle:@"运动" forState:UIControlStateNormal];
    [self.sportsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.sportsButton sizeToFit];
    self.sportsButton.center = CGPointMake(SCREEN_WIDTH / 2, 20);
    [self.sportsButton addTarget:self
                          action:@selector(_clickSportsButton)
                forControlEvents:UIControlEventTouchUpInside];
    [self.buttonArray addObject:self.sportsButton];
    [self.switchBar addSubview:self.sportsButton];
    
    self.technologyButton = [[UIButton alloc] init];
    [self.technologyButton setTitle:@"科技" forState:UIControlStateNormal];
    [self.technologyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.technologyButton sizeToFit];
    self.technologyButton.center = CGPointMake(SCREEN_WIDTH / 6 * 4, 20);
    [self.technologyButton addTarget:self
                              action:@selector(_clickTechnologyButton)
                    forControlEvents:UIControlEventTouchUpInside];
    [self.buttonArray addObject:self.technologyButton];
    [self.switchBar addSubview:self.technologyButton];
    
    self.entertainmentButton = [[UIButton alloc] init];
    [self.entertainmentButton setTitle:@"娱乐" forState:UIControlStateNormal];
    [self.entertainmentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.entertainmentButton sizeToFit];
    self.entertainmentButton.center = CGPointMake(SCREEN_WIDTH / 6 * 5, 20);
    [self.entertainmentButton addTarget:self
                                 action:@selector(_clickEntertainmentButton)
                       forControlEvents:UIControlEventTouchUpInside];
    [self.buttonArray addObject:self.entertainmentButton];
    [self.switchBar addSubview:self.entertainmentButton];
    
    self.slideBlockView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 37, 5)];
    self.slideBlockView.center = CGPointMake(SCREEN_WIDTH / 6 * 2, 35);
    self.slideBlockView.backgroundColor = [UIColor colorWithRed:0.89 green:0.36 blue:0.19 alpha:1];
    self.slideBlockView.layer.cornerRadius = 2.5;
    self.slideBlockView.layer.masksToBounds = YES;
    [self.switchBar addSubview:self.slideBlockView];
    
}

#pragma mark - WBWeiBoDetailViewDelegate

- (void)weiBoDetailView:(WBWeiBoDetailView *)detailView pushViewController:(UIViewController *)viewController {
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)weiBoDetailView:(WBWeiBoDetailView *)detailView presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.oauthModel.isAlive == NO && self.scrollView.contentOffset.x == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请先登陆，再看我的微博" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull   action) {
            [UIView animateWithDuration:0.1 animations:^{
                self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
            }];
        }];
        [sureBtn setValue:[UIColor redColor] forKey:@"titleTextColor"];
        [alertController addAction:sureBtn];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    // 刚开始不加载，选择才加载
    if (scrollView.contentOffset.x < SCREEN_WIDTH - 15 && self.detailMineView.superview == nil && self.oauthModel.isAlive) {
        [self.scrollView addSubview:self.detailMineView];
        if (self.detailMineView.isInitializedRefresh == NO) {
            [self.detailMineView beginDownRefresh];
        }
    } else if (scrollView.contentOffset.x > SCREEN_WIDTH + 15 &&
               scrollView.contentOffset.x <= SCREEN_WIDTH * 2 &&
               self.detailSportsView.isInitializedRefresh == NO) {
        [self.detailSportsView beginDownRefresh];
    } else if (scrollView.contentOffset.x > SCREEN_WIDTH * 2 + 15 && scrollView.contentOffset.x <= SCREEN_WIDTH * 3 && self.detailTechnologyView.isInitializedRefresh == NO) {
        [self.detailTechnologyView beginDownRefresh];
    } else if (scrollView.contentOffset.x > SCREEN_WIDTH * 3 + 15 && scrollView.contentOffset.x <= SCREEN_WIDTH * 4 && self.detailEntertainmentView.isInitializedRefresh == NO) {
        [self.detailEntertainmentView beginDownRefresh];
    }
    
    // 设置按钮颜色
    if (scrollView.contentOffset.x == 0) {
        for (UIButton *button in self.buttonArray) {
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        [self.mineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else if (scrollView.contentOffset.x == SCREEN_WIDTH) {
        for (UIButton *button in self.buttonArray) {
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        [self.hotButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else if (scrollView.contentOffset.x == SCREEN_WIDTH * 2) {
        for (UIButton *button in self.buttonArray) {
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        [self.sportsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else if (scrollView.contentOffset.x == SCREEN_WIDTH * 3) {
        for (UIButton *button in self.buttonArray) {
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        [self.technologyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else if (scrollView.contentOffset.x == SCREEN_WIDTH * 4) {
        for (UIButton *button in self.buttonArray) {
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        [self.entertainmentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    // 设置滑块滚动
    double k = self.scrollView.contentOffset.x / SCREEN_WIDTH + 1;  // 算出比例系数
    [UIView animateWithDuration:0.1 animations:^{
        self.slideBlockView.center = CGPointMake(SCREEN_WIDTH / 6 * k, 35);
    }];
}

#pragma mark - public method

- (void)refreshWeiBo {
    if (self.scrollView.contentOffset.x == 0 && self.detailMineView != nil) {
        [self.detailMineView beginDownRefresh];
    } else if (self.scrollView.contentOffset.x == SCREEN_WIDTH) {
        [self.detailHotView beginDownRefresh];
    } else if (self.scrollView.contentOffset.x == SCREEN_WIDTH * 2) {
        [self.detailSportsView beginDownRefresh];
    } else if (self.scrollView.contentOffset.x == SCREEN_WIDTH * 3) {
        [self.detailTechnologyView beginDownRefresh];
    } else if (self.scrollView.contentOffset.x == SCREEN_WIDTH * 4) {
        [self.detailEntertainmentView beginDownRefresh];
    }
}

- (NSArray *)dataArray {
    if (self.scrollView.contentOffset.x == 0 && self.detailMineView.superview != nil) {
        return self.detailMineView.dataArray.copy;
    } else if (self.scrollView.contentOffset.x == SCREEN_WIDTH) {
        return self.detailHotView.dataArray.copy;
    } else if (self.scrollView.contentOffset.x == SCREEN_WIDTH * 2) {
        return self.detailSportsView.dataArray.copy;
    } else if (self.scrollView.contentOffset.x == SCREEN_WIDTH * 3) {
        return self.detailTechnologyView.dataArray.copy;
    } else if (self.scrollView.contentOffset.x == SCREEN_WIDTH * 4) {
        return self.detailEntertainmentView.dataArray.copy;
    } else {
        return nil;
    }
}

#pragma mark - private method

- (void)_sendWeiBo {
    if (self.oauthModel.isAlive) {
        [WeiboSDK shareToWeibo:@""];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请先登陆，再发微博" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull   action) {
        }];
        [sureBtn setValue:[UIColor redColor] forKey:@"titleTextColor"];
        [alertController addAction:sureBtn];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)_tableViewReloadData {
    if (self.oauthModel.isAlive == NO) {
        if (self.detailMineView != nil) {
            [self.detailMineView removeFromSuperview];
            self.detailMineView.isInitializedRefresh = NO;
        }
        if (self.scrollView.contentOffset.x == 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请先登陆，再看我的微博" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull   action) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
                }];
            }];
            [sureBtn setValue:[UIColor redColor] forKey:@"titleTextColor"];
            [alertController addAction:sureBtn];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    
    if (self.detailMineView.superview != nil) {
        [self.detailMineView.tableView reloadData];
    }
    if (self.detailHotView.isInitializedRefresh) {
        [self.detailHotView.tableView reloadData];
    }
    if (self.detailSportsView.isInitializedRefresh) {
        [self.detailSportsView.tableView reloadData];
    }
    if (self.detailTechnologyView.isInitializedRefresh) {
        [self.detailTechnologyView.tableView reloadData];
    }
    if (self.detailEntertainmentView.isInitializedRefresh) {
        [self.detailEntertainmentView.tableView reloadData];
    }
}

- (void)_clickMineButton {
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

- (void)_clickHotButton {
    self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
}

- (void)_clickSportsButton {
    self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * 2, 0);
}

- (void)_clickTechnologyButton {
    self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * 3, 0);
}

- (void)_clickEntertainmentButton {
    self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * 4, 0);
}

@end
