//
//  WBLikeModel.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/8.
//

#import <Foundation/Foundation.h>
#import "WBWeiBoItem.h"

NS_ASSUME_NONNULL_BEGIN

/// 单例，储存收藏相关信息
@interface WBLikeModel : NSObject
+ (instancetype)shareInstance;
@property (nonatomic, strong, readwrite) NSMutableArray<WBWeiBoItem *> *likeWeiBoMutableArray;
- (void)readDataFromLocal;
- (void)saveDataFromLocal;
@end

NS_ASSUME_NONNULL_END
