//
//  WBOauthModel.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/5.
//

#import "WBOauthModel.h"
#import <AFNetworking.h>

@implementation WBOauthModel

#pragma mark - Life Cycle

+ (instancetype)shareInstance {
    static WBOauthModel *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super allocWithZone:NULL] init];
    });
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [WBOauthModel shareInstance];
}

#pragma mark - public method

- (void)readDataFromLocal {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults stringForKey:@"access_token"] == nil) {  // 初始化数据
        [defaults setObject:@"access_token F" forKey:@"access_token"];
        [defaults setObject:@"uid F" forKey:@"uid"];
        [defaults setBool:NO forKey:@"isAlive"];
    }
    self.access_token = [defaults stringForKey:@"access_token"];
    self.uid = [defaults stringForKey:@"uid"];
    self.isAlive = [defaults boolForKey:@"isAlive"];
    // 判断加载时是否失效
    if (self.isAlive) {
        [self _isAlive];
    }
}

#pragma mark - private method

- (void)_isAlive {
    NSString *urlString = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/get_token_info"];
    NSDictionary *parameters= @{@"access_token":self.access_token};
    [[AFHTTPSessionManager manager] POST:urlString parameters:parameters headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {

        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"载入成功");
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"载入失败");
            self.isAlive = NO;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:NO forKey:@"isAlive"];
        }];
}

@end
