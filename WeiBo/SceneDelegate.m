//
//  SceneDelegate.m
//  WeiBo
//
//  Created by JiangNan on 2022/4/30.
//

#import "SceneDelegate.h"
#import "WBWeiBoViewController.h"
#import "WBDiscoverViewController.h"
#import "WBMessageViewController.h"
#import "WBMineViewController.h"
#import "WBScreen.h"
#import "WBHistorySearchView.h"
#import "WBSearchView.h"
#import "WBHistorySearchModel.h"
#if DEBUG
#import "FLEXManager.h"
#endif

@interface SceneDelegate ()<UITabBarControllerDelegate, UISearchBarDelegate, WBHistorySearchViewDelegate, WBSearchViewDelegate>
@property(nonatomic, strong, readwrite) NSDate *preDate;  // 记录进入后台那一刻的时间
@property(nonatomic, strong, readwrite) NSDate *nowDate;  // 记录从后台返回那一刻的时间
@property(nonatomic, strong, readwrite) WBWeiBoViewController *weiboViewController;
@property(nonatomic, strong, readwrite) UISearchBar *searchBar;
@property(nonatomic, strong, readwrite) UINavigationController *navigationController;
@property(nonatomic, strong, readwrite) WBHistorySearchView *searchHistoryView;
@property(nonatomic, strong, readwrite) WBSearchView *searchView;
@property(nonatomic, strong, readwrite) WBHistorySearchModel *historySearchModel;
@end

@implementation SceneDelegate

#pragma mark - SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setWindowScene:windowScene];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
    UITabBarController *tabberController = [[UITabBarController alloc] init];
    UITabBarAppearance * tabbarAppearance = [UITabBarAppearance new];
    tabbarAppearance.backgroundColor = [UIColor whiteColor];
    tabbarAppearance.backgroundEffect = nil;
    tabberController.tabBar.scrollEdgeAppearance = tabbarAppearance;
    tabberController.tabBar.standardAppearance = tabbarAppearance;
    tabberController.tabBar.tintColor = [UIColor lightGrayColor];
    
    self.weiboViewController = [[WBWeiBoViewController alloc] init];
    WBDiscoverViewController *discoverViewController = [[WBDiscoverViewController alloc] init];
    WBMessageViewController *messageViewController = [[WBMessageViewController alloc] init];
    WBMineViewController *mineViewController = [[WBMineViewController alloc] init];

    [tabberController setViewControllers:@[self.weiboViewController, discoverViewController, messageViewController, mineViewController]];
    
    tabberController.delegate = self;
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:tabberController];
    UINavigationBarAppearance *navigationBarAppearance = [UINavigationBarAppearance new];
    navigationBarAppearance.backgroundColor = [UIColor whiteColor];
    navigationBarAppearance.backgroundEffect = nil;
    self.navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance;
    self.navigationController.navigationBar.standardAppearance = navigationBarAppearance;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    self.searchBar.center = CGPointMake(SCREEN_WIDTH / 2, 68);
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.delegate = self;
    [self.navigationController.view addSubview:self.searchBar];
    
    self.searchView = [[WBSearchView alloc] initWithFrame:CGRectMake(0, 88, SCREEN_WIDTH, SCREEN_HEIGHT - 88)];
    self.searchView.delegate = self;
    self.searchHistoryView = [[WBHistorySearchView alloc] initWithFrame:CGRectMake(0, 88, SCREEN_WIDTH, SCREEN_HEIGHT - 88)];
    self.searchHistoryView.delegate = self;

    self.historySearchModel = [WBHistorySearchModel shareInstance];
    
    [self.window setRootViewController:self.navigationController];
    [self.window makeKeyAndVisible];
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    self.nowDate = [NSDate date];
    // timeInterval 在后台的时间
    NSTimeInterval timeInterval = [self.nowDate timeIntervalSinceDate:self.preDate];
    // 如果在后台的时间大于等于30s，刷新微博
    if (timeInterval >= 30) {
        [self.weiboViewController refreshWeiBo];
    }
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    self.preDate = [NSDate date];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[WBWeiBoViewController class]] && [tabBarController.selectedViewController isKindOfClass:[WBWeiBoViewController class]]) {
        [((WBWeiBoViewController *)viewController) refreshWeiBo];
    }
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[WBWeiBoViewController class]]) {
        if (![self.searchBar isDescendantOfView:self.navigationController.view]) {  // 如果没有searchBar,就加上
            [self.navigationController.view addSubview:self.searchBar];
        }
    } else {
        if ([self.searchBar isDescendantOfView:self.navigationController.view]) {  // 如果有searchBar,就移除
            [self.searchBar removeFromSuperview];
        }
    }
}

#pragma mark - UISearchBarDelegate

// 点击时加载searchView
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:NO];
    
    if (![self.searchHistoryView isDescendantOfView:self.window] && ![self.searchView isDescendantOfView:self.window] ) {
        [self.window addSubview:self.searchHistoryView];
        [self.searchHistoryView readLoadHistory];
    }
    
    return YES;
}

// 点击取消按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:NO animated:NO];
    [self.searchBar resignFirstResponder];
    if ([self.searchHistoryView isDescendantOfView:self.window]) {
        [self.searchHistoryView removeFromSuperview];
    } else {
        [self.searchView removeFromSuperview];
    }
    self.searchBar.text = @"";
}

// 点击确认按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.historySearchModel saveDataWithString:self.searchBar.text];
    if ([self.searchHistoryView isDescendantOfView:self.window]) {
        [self.window addSubview:self.searchView];
        [self.searchHistoryView removeFromSuperview];
        [self.searchView searchWithString:self.searchBar.text dataArray:self.weiboViewController.dataArray];
    } else {
        [self.searchView searchWithString:self.searchBar.text dataArray:self.weiboViewController.dataArray];
    }
}

#pragma mark - WBHistorySearchViewDelegate

- (void)historySearchViewWillBeginDragging:(UIView *)historySearchView {
    [self.searchBar resignFirstResponder];
    UIButton *cancelBtn = [self.searchBar valueForKey:@"cancelButton"];
    cancelBtn.enabled = YES;
}

- (void)historySearchView:(UIView *)historySearchView didSelectCellText:(NSString *)text {
    self.searchBar.text = text;
    [self.historySearchModel saveDataWithString:self.searchBar.text];
    if ([self.searchHistoryView isDescendantOfView:self.window]) {
        [self.window addSubview:self.searchView];
        [self.searchHistoryView removeFromSuperview];
        [self.searchView searchWithString:self.searchBar.text dataArray:self.weiboViewController.dataArray];
    } else {
        [self.searchView searchWithString:self.searchBar.text dataArray:self.weiboViewController.dataArray];
    }
}

#pragma mark - WBSearchViewDelegate

- (void)searchViewWillBeginDragging:(UIView *)searchView {
    [self.searchBar resignFirstResponder];
    UIButton *cancelBtn = [self.searchBar valueForKey:@"cancelButton"];
    cancelBtn.enabled = YES;
}

- (void)searchView:(UIView *)searchView presentViewController:(UIViewController *)viewController {
    [self.navigationController presentViewController:viewController animated:YES completion:nil];
}

- (void)searchView:(UIView *)searchView presentWebViewController:(UIViewController *)viewController {
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:viewController animated:NO completion:nil];
}


- (void)handleSixFingerQuadrupleTap:(UITapGestureRecognizer *)tapRecognizer
{
#if DEBUG
    if (tapRecognizer.state == UIGestureRecognizerStateRecognized) {
        // This could also live in a handler for a keyboard shortcut, debug menu item, etc.
        [[FLEXManager sharedManager] showExplorer];
    }
#endif
}

@end
