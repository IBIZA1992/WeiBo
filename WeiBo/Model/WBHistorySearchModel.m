//
//  WBHistorySearchModel.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/13.
//

#import "WBHistorySearchModel.h"

@implementation WBHistorySearchModel

#pragma mark - Life Cycle

+ (instancetype)shareInstance {
    static WBHistorySearchModel *_sharedInstance = nil;
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
    return [WBHistorySearchModel shareInstance];
}

#pragma mark - public method

- (void)readDataFromLocal {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [pathArray firstObject];
    NSString *dataPath = [cachePath stringByAppendingPathComponent:@"WBData/historySearch"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *readData = [fileManager contentsAtPath:dataPath];
    id unarchiveObj = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSArray class],[NSString class], nil]
                                                          fromData:readData error:nil];
    
    // 如果有，就返回读到的数据
    if ([unarchiveObj isKindOfClass:[NSArray class]] && [unarchiveObj count] > 0) {
        self.historySearchMutableArray = ((NSArray<NSString *> *)unarchiveObj).mutableCopy;
    } else {
        self.historySearchMutableArray = @[].mutableCopy;
    }
}

- (void)saveDataWithString:(NSString *)string {
    BOOL isNew = YES;
    for (NSString *searchString in self.historySearchMutableArray) {  // 如果存在
        if ([searchString isEqualToString:string]) {
            [self.historySearchMutableArray removeObject:searchString];
            [self.historySearchMutableArray insertObject:string atIndex:0];
            isNew = NO;
            break;
        }
    }
    if (isNew) {
        [self.historySearchMutableArray insertObject:string atIndex:0];
    }
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [pathArray firstObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *listDataPath = [cachePath stringByAppendingPathComponent:@"WBData/historySearch"];
    NSData *listData = [NSKeyedArchiver archivedDataWithRootObject:self.historySearchMutableArray.copy
                                             requiringSecureCoding:YES
                                                             error:nil];
    [fileManager createFileAtPath:listDataPath contents:listData attributes:nil];
}

@end
