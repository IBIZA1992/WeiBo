//
//  WBMineViewController.m
//  WeiBo
//
//  Created by JiangNan on 2022/4/30.
//

#import "WBMineViewController.h"
#import "WBScreen.h"
#import "WebKit/WebKit.h"
#import "WBOauthModel.h"
#import "WBMineLikeViewController.h"
#import "WBMineHistoryViewController.h"
#import "WBWebImage.h"
#import <AFNetworking.h>

@interface WBMineViewController ()<WKNavigationDelegate>

@property(nonatomic, strong, readwrite) WBOauthModel *oauthModel;
@property(nonatomic, strong, readwrite) WBWebImage *webImage;

// 公用组件
@property(nonatomic, strong, readwrite) UIView *twoButtonDetailView;

// login组件
@property(nonatomic, strong, readwrite) UIButton *loginButton;

// logout组件
@property(nonatomic, strong, readwrite) UIButton *logoutButton;
@property(nonatomic, strong, readwrite) UIImageView *headImageView;
@property(nonatomic, strong, readwrite) UILabel *nameLabel;

@end

@implementation WBMineViewController

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"我";
        self.tabBarItem.image = [UIImage imageNamed:@"mine"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"mine.fill"];
        
        self.view.backgroundColor = [UIColor colorWithRed:0.933 green:0.929 blue:0.949 alpha:1];
        
        _oauthModel = [WBOauthModel shareInstance];
      
        _webImage = [WBWebImage shareInstance];

        // 初始化公用控件
        _twoButtonDetailView = [[UIView alloc] initWithFrame:UIRect(54, 257, 282, 89)];
        _twoButtonDetailView.backgroundColor = [UIColor whiteColor];
        _twoButtonDetailView.layer.cornerRadius = 15;
        _twoButtonDetailView.layer.masksToBounds = YES;
        
        UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:UIRect(0, 0, 40, 40)];
        leftImageView.center = CGPointMake(_twoButtonDetailView.frame.size.width / 4, _twoButtonDetailView.frame.size.height / 2 - UI(10));
        leftImageView.userInteractionEnabled = YES;
        leftImageView.image = [UIImage imageNamed:@"list"];
        UITapGestureRecognizer *leftImageViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                  action:@selector(_leftImageViewClick)];
        [leftImageView addGestureRecognizer:leftImageViewTapGesture];
        [_twoButtonDetailView addSubview:leftImageView];
        
        UILabel *leftLabel = [[UILabel alloc] init];
        leftLabel.text = @"历史记录";
        leftLabel.alpha = 0.75;
        leftLabel.font = [UIFont systemFontOfSize:UI(14)];
        [leftLabel sizeToFit];
        leftLabel.center = CGPointMake(leftImageView.center.x, leftImageView.center.y + UI(35));
        [_twoButtonDetailView addSubview:leftLabel];
        
        UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:UIRect(0, 0, 40, 40)];
        rightImageView.center = CGPointMake(_twoButtonDetailView.frame.size.width / 4 * 3, _twoButtonDetailView.frame.size.height / 2 - UI(10));
        rightImageView.userInteractionEnabled = YES;
        rightImageView.image = [UIImage imageNamed:@"star"];
        UITapGestureRecognizer *rightImageViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(_rightImageViewClick)];
        [rightImageView addGestureRecognizer:rightImageViewTapGesture];
        [_twoButtonDetailView addSubview:rightImageView];
        
        UILabel *rightLabel = [[UILabel alloc] init];
        rightLabel.text = @"我的收藏";
        rightLabel.alpha = 0.75;
        rightLabel.font = [UIFont systemFontOfSize:UI(14)];
        [rightLabel sizeToFit];
        rightLabel.center = CGPointMake(rightImageView.center.x, rightImageView.center.y + UI(35));
        [_twoButtonDetailView addSubview:rightLabel];
        
        // login组件初始化
        _loginButton = [[UIButton alloc] initWithFrame:UIRect(111, 163, 169, 66)];
        _loginButton.backgroundColor = [UIColor colorWithRed:0.89 green:0.36 blue:0.19 alpha:1];
        _loginButton.layer.cornerRadius = _loginButton.frame.size.height / 2;
        _loginButton.layer.masksToBounds = YES;
        UILabel *loginLabel = [[UILabel alloc] init];
        loginLabel.text = @"登陆/注册";
        loginLabel.textColor = [UIColor whiteColor];
        loginLabel.font = [UIFont boldSystemFontOfSize:UI(22)];
        [loginLabel sizeToFit];
        loginLabel.center = CGPointMake(_loginButton.bounds.size.width / 2, _loginButton.bounds.size.height / 2);
        [_loginButton addSubview:loginLabel];
        [_loginButton addTarget:self action:@selector(_login) forControlEvents:UIControlEventTouchUpInside];
        
        // logout组件初始化
        _logoutButton = [[UIButton alloc] initWithFrame:UIRect(111, 338, 169, 66)];
        _logoutButton.backgroundColor = [UIColor colorWithRed:0.89 green:0.36 blue:0.19 alpha:1];
        _logoutButton.layer.cornerRadius = _logoutButton.frame.size.height / 2;
        _logoutButton.layer.masksToBounds = YES;
        UILabel *logoutLabel = [[UILabel alloc] init];
        logoutLabel.text = @"退出账号";
        logoutLabel.textColor = [UIColor whiteColor];
        logoutLabel.font = [UIFont boldSystemFontOfSize:UI(22)];
        [logoutLabel sizeToFit];
        logoutLabel.center = CGPointMake(_logoutButton.bounds.size.width / 2, _logoutButton.bounds.size.height / 2);
        [_logoutButton addSubview:logoutLabel];
        [_logoutButton addTarget:self action:@selector(_logout) forControlEvents:UIControlEventTouchUpInside];
        
        _headImageView = [[UIImageView alloc] initWithFrame:UIRect(16, 105, 86, 86)];
        _headImageView.layer.cornerRadius = _headImageView.frame.size.width / 2;
        _headImageView.layer.masksToBounds = YES;
        _headImageView.backgroundColor = [UIColor whiteColor];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:UI(22)];
        _nameLabel.text = @"昵称";
        _nameLabel.textColor = [UIColor colorWithRed:0.89 green:0.36 blue:0.19 alpha:1];
        [_nameLabel sizeToFit];
        _nameLabel.frame = CGRectMake(UI(120), UI(123), _nameLabel.bounds.size.width, _nameLabel.bounds.size.height);
        
        // 初始布局
        if (_oauthModel.isAlive) {
            [self _layoutLogoutView];
        } else {
            [self _layoutLoginView];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - WKNavigationDelegate

// 获取授权
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void   (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSString *urlString = navigationAction.request.URL.absoluteString;
    
    if ([urlString containsString:@"http://www.example.com/response?code="]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        NSString *code = [[urlString componentsSeparatedByString:@"code="] lastObject];
        NSString *urlString = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/access_token"];
        
        // 加载获得数据
        NSDictionary *parameters= @{
                                    @"client_id":@"2407730117",
                                    @"client_secret":@"4af118a9f9bbb956b1369327b9483875",
                                    @"grant_type":@"authorization_code",
                                    @"code":code,
                                    @"redirect_uri":@"http://www.example.com/response"
        };
        
        [[AFHTTPSessionManager manager] POST:urlString parameters:parameters headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSLog(@"");
                    dispatch_async(dispatch_get_main_queue(), ^{  // 推出页面
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                    self.oauthModel.access_token = [responseObject objectForKey:@"access_token"];
                    self.oauthModel.uid = [responseObject objectForKey:@"uid"];
                    self.oauthModel.isAlive = YES;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:self.oauthModel.access_token forKey:@"access_token"];
                    [defaults setObject:self.oauthModel.uid forKey:@"uid"];
                    [defaults setBool:YES forKey:@"isAlive"];
                    NSLog(@"");
                    dispatch_async(dispatch_get_main_queue(), ^{  // 推出页面
                        [self.loginButton removeFromSuperview];
                        [self.twoButtonDetailView removeFromSuperview];
                        [self _layoutLogoutView];
                    });
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"");
                }];
    } else if ([urlString containsString:@"http://www.example.com/response?error_uri="]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

#pragma mark - private method

- (void)_layoutLoginView {
    [self.view addSubview:self.loginButton];
    self.twoButtonDetailView.frame = UIRect(54, 257, 282, 89);
    [self.view addSubview:self.twoButtonDetailView];
}

- (void)_layoutLogoutView {
    [self.view addSubview:self.headImageView];
    [self.view addSubview:self.nameLabel];
    self.twoButtonDetailView.frame = UIRect(54, 217, 282, 89);
    [self.view addSubview:self.twoButtonDetailView];
    [self.view addSubview:self.logoutButton];
    
    // 加载用户信息
    NSString *urlString = [NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?access_token=%@&uid=%@", self.oauthModel.access_token, self.oauthModel.uid];
    [[AFHTTPSessionManager manager] GET:urlString parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"");
            dispatch_async(dispatch_get_main_queue(), ^{  // 推出页面
                self.nameLabel.text= [responseObject objectForKey:@"screen_name"];
                [self.nameLabel sizeToFit];
                self.nameLabel.frame = CGRectMake(UI(120), UI(135), self.nameLabel.bounds.size.width, self.nameLabel.bounds.size.height);
            });
            dispatch_queue_global_t downloadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_queue_main_t mainQueue = dispatch_get_main_queue();
            dispatch_async(downloadQueue, ^{
                UIImage *image = [self.webImage loadImageWithUrlString:[responseObject objectForKey:@"avatar_large"]];
                if (image) {
                    dispatch_async(mainQueue, ^{
                        self.headImageView.image = image;
                    });
                }
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"");
        }];
}

- (void)_login {
    NSString *urlString = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=2407730117&redirect_uri=http://www.example.com/response&response_type=code"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 88, SCREEN_WIDTH, SCREEN_HEIGHT - 88) configuration:config];
    webView.navigationDelegate = self;
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController.view addSubview:webView];
    [self.navigationController pushViewController:viewController animated:YES];
    [webView loadRequest:request];
}

- (void)_logout {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull   action) {
        NSString *urlString = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/revokeoauth2?access_token=%@", self.oauthModel.access_token];
        
        // 加载登出
        [[AFHTTPSessionManager manager] GET:urlString parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSLog(@"");
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:NO forKey:@"isAlive"];
                    self.oauthModel.isAlive = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{  // 推出页面
                        [self.logoutButton removeFromSuperview];
                        [self.nameLabel removeFromSuperview];
                        [self.twoButtonDetailView removeFromSuperview];
                        [self.headImageView removeFromSuperview];
                        [self _layoutLoginView];
                    });
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"");
                }];
    }];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull   action) {
    }];
    [sureBtn setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [cancelBtn setValue:[UIColor systemBlueColor] forKey:@"titleTextColor"];
    [alertController addAction:sureBtn];
    [alertController addAction:cancelBtn];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)_leftImageViewClick {
    WBMineHistoryViewController *historyViewController = [[WBMineHistoryViewController alloc] init];
    [self.navigationController pushViewController:historyViewController animated:YES];
}

- (void)_rightImageViewClick {
    WBMineLikeViewController *likeViewController = [[WBMineLikeViewController alloc] init];
    [self.navigationController pushViewController:likeViewController animated:YES];
}

@end
