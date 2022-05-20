//
//  WBWebViewController.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/5.
//

#import "WBWebViewController.h"

@interface WBWebViewController ()<WKNavigationDelegate>
@property(nonatomic, strong, readwrite) WKWebView *webView;
@property(nonatomic, strong, readwrite) UIProgressView *progressView;
@property(nonatomic, copy, readwrite) NSURLRequest *request;
@end

@implementation WBWebViewController

#pragma mark - Life Cycle

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (instancetype)initWithRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        self.request = request;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:({
        self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 88, self.view.frame.size.width, self.view.frame.size.height - 88)];
        self.webView.navigationDelegate = self;
        self.webView;
    })];
    
    [self.view addSubview:({
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 88, self.view.frame.size.width, 20)];
        self.progressView;
    })];
    
    [self.webView loadRequest:self.request];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 88)];
    barView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:barView];
    
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titlelabel.text = @"网页链接";
    titlelabel.font = [UIFont boldSystemFontOfSize:20];
    [titlelabel sizeToFit];
    titlelabel.center = CGPointMake(self.view.frame.size.width / 2, 63);
    [barView addSubview:titlelabel];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [cancelButton setTitle:@"退出" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [cancelButton sizeToFit];
    cancelButton.center = CGPointMake(self.view.frame.size.width / 10, 63);
    [cancelButton addTarget:self action:@selector(_clickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:cancelButton];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(nullable void *)context {
    self.progressView.progress = self.webView.estimatedProgress;
    if (self.progressView.progress == 1) {
        [self.progressView removeFromSuperview];
    }

}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction
                    decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
                        [self.view addSubview:self.progressView];
                        decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - private method

- (void)_clickCancelButton {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
