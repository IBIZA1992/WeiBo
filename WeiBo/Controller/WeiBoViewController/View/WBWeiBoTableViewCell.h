//
//  WBWeiBoTableViewCell.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/2.
//

#import <UIKit/UIKit.h>
#import "WebKit/WebKit.h"

@class WBWeiBoItem;

NS_ASSUME_NONNULL_BEGIN

// 取消收藏
@protocol WBWeiBoTableViewCellDelegate <NSObject>

- (void)tableViewCell:(UITableViewCell *)tableViewCell clickLikeFillButton:(UIButton *)likeButton;

@end

typedef void(^WBClickWebBlock)(NSURL *URL);

/// 微博展示cell
@interface WBWeiBoTableViewCell : UITableViewCell

@property(nonatomic, weak, readwrite) id<WBWeiBoTableViewCellDelegate> delegate;

/// 布局cell
/// @param item 要布局的信息item
/// @param clickWebBlock 点击文字中网页地址的回调
- (void)layoutTableViewCellWithItem:(WBWeiBoItem *)item clickWebBlock:(WBClickWebBlock)clickWebBlock;
@end

NS_ASSUME_NONNULL_END
