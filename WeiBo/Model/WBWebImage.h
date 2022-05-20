//
//  WBWebImage.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 单例，加载图片
@interface WBWebImage : NSObject
+ (instancetype)shareInstance;

/// 建立缓存和本地存储，从网络加载图片
/// @param urlString 图片网址
- (UIImage *)loadImageWithUrlString:(NSString *)urlString;
@end

NS_ASSUME_NONNULL_END
