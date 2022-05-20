//
//  WBSearchView.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/13.
//

#import <UIKit/UIKit.h>

@class WBWeiBoItem;

NS_ASSUME_NONNULL_BEGIN

@protocol WBSearchViewDelegate <NSObject>

/// 滚动时注销第一响应者
/// @param searchView 自己的view
- (void)searchViewWillBeginDragging:(UIView *)searchView;

/// 在页面上展示viewController
/// @param searchView 自己的view
/// @param viewController 要展示的viewController
- (void)searchView:(UIView *)searchView presentViewController:(UIViewController *)viewController;

/// 在页面上展示要点击的网页
/// @param searchView 自己的view
/// @param viewController 要展示的viewController
- (void)searchView:(UIView *)searchView presentWebViewController:(UIViewController *)viewController;

@end

@interface WBSearchView : UIView

@property(nonatomic, weak, readwrite) id<WBSearchViewDelegate> delegate;

/// 在所给数据中搜索
/// @param searchString 搜索的字符串
/// @param searchDataArray item的数组
- (void)searchWithString:(NSString *)searchString dataArray:(NSArray<WBWeiBoItem *> *)searchDataArray;

@end

NS_ASSUME_NONNULL_END
