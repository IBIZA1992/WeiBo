//
//  WBWeiBoLoader.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/2.
//

#import <Foundation/Foundation.h>

@class WBWeiBoItem;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WBWeiBoCategory) {
    WBWeiBoCategoryMine             = 0,  // 我的
    WBWeiBoCategoryHot              = 1,  // 热门
    WBWeiBoCategorySports           = 2,  // 体育
    WBWeiBoCategoryTechnology       = 3,  // 科技
    WBWeiBoCategoryEntertainment    = 4   // 娱乐
    
};

@protocol WBWeiBoLoaderDelegate <NSObject>

/// 结束加载
- (void)didFinishLoader;

@end

typedef void(^WBWeiBoLoaderFinishBlock)(BOOL success, NSMutableArray<WBWeiBoItem *> *dataArray);

/// 加载列表
@interface WBWeiBoLoader : NSObject

/// 加载微博列表
/// @param finishBlock 加载微博之后进行的回调
- (void)loadWeiBoDataWithPageNmu:(NSInteger)pageNum
                        category:(WBWeiBoCategory)category
                     finishBlock:(WBWeiBoLoaderFinishBlock)finishBlock;

@property(nonatomic, weak, readwrite) id<WBWeiBoLoaderDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
