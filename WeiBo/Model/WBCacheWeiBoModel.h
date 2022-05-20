//
//  WBCacheWeiBoModel.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/12.
//

#import <UIKit/UIKit.h>
#import "WBWeiBoItem.h"
#import "WBWeiBoLoader.h"

NS_ASSUME_NONNULL_BEGIN

/// 单例，在微博类型刚加载是展示微博，之后才从网络加载刷新
@interface WBCacheWeiBoModel : UIView
+ (instancetype)shareInstance;
- (NSArray<WBWeiBoItem *> *)readDataFromLocalWithCategory:(WBWeiBoCategory)category;
- (void)archiveListDataWithArray:(NSArray<WBWeiBoItem *> *)array category:(WBWeiBoCategory)category;
@end

NS_ASSUME_NONNULL_END
