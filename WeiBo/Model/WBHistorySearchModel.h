//
//  WBHistorySearchModel.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 单例，储存搜索的历史记录
@interface WBHistorySearchModel : NSObject
+ (instancetype)shareInstance;
@property (nonatomic, strong, readwrite) NSMutableArray<NSString *> *historySearchMutableArray;
- (void)readDataFromLocal;
- (void)saveDataWithString:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
