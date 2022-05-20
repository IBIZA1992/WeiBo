//
//  WBGetWeiBoItemHeight.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class WBWeiBoItem;
NS_ASSUME_NONNULL_BEGIN

/// 得到每个cell的高度，实现cell高度自适应
@interface WBGetWeiBoItemHeight : NSObject

/// 得到cell高度
/// @param item 要得到高度的item
- (CGFloat)getItemHeight:(WBWeiBoItem *)item;

@end

NS_ASSUME_NONNULL_END
