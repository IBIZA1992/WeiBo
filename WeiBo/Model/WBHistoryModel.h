//
//  WBHistoryModel.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/9.
//

#import <Foundation/Foundation.h>
#import "WBWeiBoItem.h"

NS_ASSUME_NONNULL_BEGIN

/// 单例，储存历史记录
@interface WBHistoryModel : NSObject
+ (instancetype)shareInstance;
@property (nonatomic, strong, readwrite) NSMutableArray<WBWeiBoItem *> *historyWeiBoMutableArray;
- (void)readDataFromLocal;
- (void)saveDataFromLocal;
@end

NS_ASSUME_NONNULL_END

