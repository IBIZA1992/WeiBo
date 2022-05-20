//
//  WeiboSDKDemo-Prefix.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/7.
//

#import <Availability.h>

#ifndef __IPHONE_6_0
#warning "This project uses features only available in iOS SDK 6.0 and later."
#endif

#ifdef __OBJC__
    #import <UIKit/UIKit.h>
    #import <Foundation/Foundation.h>

#import "WeiboSDK.h"

#define kAppKey         @"497799835"
#define kRedirectURI    @"https://api.weibo.com/oauth2/default.html"

#endif
