//
//  WBHistoryModel.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/9.
//

#import "WBHistoryModel.h"

@implementation WBHistoryModel

#pragma mark - Life Cycle

+ (instancetype)shareInstance {
    static WBHistoryModel *_sharedInstance = nil;
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
    return [WBHistoryModel shareInstance];
}

#pragma mark - public method

- (void)readDataFromLocal {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [pathArray firstObject];
    NSString *dataPath = [cachePath stringByAppendingPathComponent:@"WBData/historyWeiBo"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *readData = [fileManager contentsAtPath:dataPath];
    id unarchiveObj = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSArray class],[WBWeiBoItem class], nil]
                                                          fromData:readData error:nil];
    
    // 如果有，就返回读到的数据
    if ([unarchiveObj isKindOfClass:[NSArray class]] && [unarchiveObj count] > 0) {
        self.historyWeiBoMutableArray = ((NSArray<WBWeiBoItem *> *)unarchiveObj).mutableCopy;
    } else {
        self.historyWeiBoMutableArray = @[].mutableCopy;
    }
}

- (void)saveDataFromLocal {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [pathArray firstObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];    
    NSString *listDataPath = [cachePath stringByAppendingPathComponent:@"WBData/historyWeiBo"];
    NSData *listData = [NSKeyedArchiver archivedDataWithRootObject:self.historyWeiBoMutableArray.copy
                                             requiringSecureCoding:YES
                                                             error:nil];
    [fileManager createFileAtPath:listDataPath contents:listData attributes:nil];
}

@end

