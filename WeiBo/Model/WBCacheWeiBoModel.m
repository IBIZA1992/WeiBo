//
//  WBCacheWeiBoModel.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/12.
//

#import "WBCacheWeiBoModel.h"

@implementation WBCacheWeiBoModel

#pragma mark - Life Cycle

+ (instancetype)shareInstance {
    static WBCacheWeiBoModel *_sharedInstance = nil;
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
    return [WBCacheWeiBoModel shareInstance];
}

#pragma mark - public method

- (NSArray<WBWeiBoItem *> *)readDataFromLocalWithCategory:(WBWeiBoCategory)category {
    NSString *categoryStr;
    if (category == WBWeiBoCategoryMine) {
        categoryStr = @"mine";
    } else if (category == WBWeiBoCategoryHot) {
        categoryStr = @"hot";
    } else if (category == WBWeiBoCategorySports) {
        categoryStr = @"sports";
    } else if (category == WBWeiBoCategoryTechnology) {
        categoryStr = @"technology";
    } else if (category == WBWeiBoCategoryEntertainment) {
        categoryStr = @"entertainment";
    }
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [pathArray firstObject];
    NSString *dataPath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"WBData/%@", categoryStr]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *readData = [fileManager contentsAtPath:dataPath];
    id unarchiveObj = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSArray class],[WBWeiBoItem class], nil]
                                                          fromData:readData error:nil];
    
    // 如果有，就返回读到的数据
    if ([unarchiveObj isKindOfClass:[NSArray class]] && [unarchiveObj count] > 0) {
        return (NSArray<WBWeiBoItem *> *)unarchiveObj;
    }
    return nil;;
}

- (void)archiveListDataWithArray:(NSArray<WBWeiBoItem *> *)array category:(WBWeiBoCategory)category {
    NSString *categoryStr;
    if (category == WBWeiBoCategoryMine) {
        categoryStr = @"mine";
    } else if (category == WBWeiBoCategoryHot) {
        categoryStr = @"hot";
    } else if (category == WBWeiBoCategorySports) {
        categoryStr = @"sports";
    } else if (category == WBWeiBoCategoryTechnology) {
        categoryStr = @"technology";
    } else if (category == WBWeiBoCategoryEntertainment) {
        categoryStr = @"entertainment";
    }
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [pathArray firstObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dataPath = [cachePath stringByAppendingPathComponent:@"WBData"];
    NSString *listDataPath = [dataPath stringByAppendingPathComponent:categoryStr];
    NSData *listData = [NSKeyedArchiver archivedDataWithRootObject:array requiringSecureCoding:YES error:nil];
    [fileManager createFileAtPath:listDataPath contents:listData attributes:nil];
}

@end
