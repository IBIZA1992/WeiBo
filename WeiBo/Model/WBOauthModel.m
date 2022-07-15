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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    NSString *bodyStr = [NSString stringWithFormat:@"access_token=%@", self.access_token];
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *jsonError;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if ([(NSDictionary *)jsonObj objectForKey:@"error_code"]) {
            NSLog(@"载入失败");
            self.isAlive = NO;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:NO forKey:@"isAlive"];
        } else {
            NSLog(@"载入成功");
        }
    }];
    [dataTask resume];
}

@end
