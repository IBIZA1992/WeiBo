//
//  WBOauthModel.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 单例，全局存取access_token等关于Oauth登陆的信息
@interface WBOauthModel : NSObject
+ (instancetype)shareInstance;
@property (nonatomic, copy, readwrite) NSString *access_token;
@property (nonatomic, copy, readwrite) NSString *uid;
@property (nonatomic, assign, readwrite) BOOL isAlive;
- (void)readDataFromLocal;
@end

NS_ASSUME_NONNULL_END
