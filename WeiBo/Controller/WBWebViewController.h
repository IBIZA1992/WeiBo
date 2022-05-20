//
//  WBWebViewController.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/5.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 加载有进度条的WKWebView
@interface WBWebViewController : UIViewController
- (instancetype)initWithRequest:(NSURLRequest *)request;
@end

NS_ASSUME_NONNULL_END
