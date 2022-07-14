//
//  AppDelegate.m
//  WeiBo
//
//  Created by JiangNan on 2022/4/30.
//

#import "AppDelegate.h"
#import "WBOauthModel.h"
#import "WBLikeModel.h"
#import "WBHistoryModel.h"
#import "WBHistorySearchModel.h"

@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    WBOauthModel *oauthModel = [WBOauthModel shareInstance];
    [oauthModel readDataFromLocal];
    
    NSLog(@"this is in dev");
    NSLog(@"this is in feature");
    
    NSLog(@"this is in dev");
    
    NSLog(@"这一次是dev");
    NSLog(@"这一次是feature");
    
    WBLikeModel *likeModel = [WBLikeModel shareInstance];
    [likeModel readDataFromLocal];
    
    WBHistoryModel *historyModel = [WBHistoryModel shareInstance];
    [historyModel readDataFromLocal];
    
    WBHistorySearchModel *historySearchModel = [WBHistorySearchModel shareInstance];
    [historySearchModel readDataFromLocal];

    // 创建文件夹
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [pathArray firstObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dataPath = [cachePath stringByAppendingPathComponent:@"WBData"];
    if (![fileManager fileExistsAtPath:dataPath]) {
        NSError *creatError;
        [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:&creatError];
        
        dataPath = [cachePath stringByAppendingPathComponent:@"WBImageData"];
        [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:&creatError];
    }
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
