//
//  WBHistorySearchView.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WBHistorySearchViewDelegate <NSObject>

/// 滚动时注销第一响应者
/// @param historySearchView 自己的view
- (void)historySearchViewWillBeginDragging:(UIView *)historySearchView;

/// 点击历史记录进入搜索页面
/// @param historySearchView 自己的view
/// @param text 点击搜索记录的内容
- (void)historySearchView:(UIView *)historySearchView didSelectCellText:(NSString *)text;


@end

/// 负责在搜索开始前展示搜索历史
@interface WBHistorySearchView : UIView

@property(nonatomic, weak, readwrite) id<WBHistorySearchViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

/// 重载历史搜索记录
- (void)readLoadHistory;

@end

NS_ASSUME_NONNULL_END
