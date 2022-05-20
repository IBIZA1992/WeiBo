//
//  WBLikeModel.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/8.
//

#import "WBLikeModel.h"

@implementation WBLikeModel

#pragma mark - Life Cycle

+ (instancetype)shareInstance {
    static WBLikeModel *_sharedInstance = nil;
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
    return [WBLikeModel shareInstance];
}

#pragma mark - public method

- (void)readDataFromLocal {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults dataForKey:@"likeWeiBoArray"];
    id unarchiveObj = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSArray class], [WBWeiBoItem class], nil]
                                                          fromData:data
                                                             error:nil];
    if ([unarchiveObj isKindOfClass:[NSArray class]] && [unarchiveObj count] > 0) {
        self.likeWeiBoMutableArray = ((NSArray<WBWeiBoItem *> *)unarchiveObj).mutableCopy;
    } else {
        self.likeWeiBoMutableArray = @[].mutableCopy;
    }
}

- (void)saveDataFromLocal {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:self.likeWeiBoMutableArray.copy
                                              requiringSecureCoding:YES
                                                              error:nil];
    [defaults setObject:arrayData forKey:@"likeWeiBoArray"];
}

@end
