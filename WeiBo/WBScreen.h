//
//  WBScreen.h
//  WeiBo
//
//  Created by JiangNan on 2022/4/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define IS_LANDSCAPE (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

//#define STATUSBARHEIGHT (([[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom) ? 88 : 64)

#define UI(x) UIAdapter(x)
#define UIRect(x, y, width, height) UIRectAdapter(x, y, width, height)

static inline NSInteger UIAdapter (float x) {
    CGFloat scale = 390 / SCREEN_WIDTH;
    return (NSInteger)x / scale;
}

static inline CGRect UIRectAdapter(x, y, width, height) {
    return CGRectMake(UIAdapter(x), UIAdapter(y), UIAdapter(width), UIAdapter(height));
}

/// 分辨率及状态栏适配
@interface WBScreen : NSObject

@end

NS_ASSUME_NONNULL_END
