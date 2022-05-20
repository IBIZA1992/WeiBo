//
//  WBWeiBoDetailView.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/11.
//

#import <UIKit/UIKit.h>
#import "WBWeiBoLoader.h"

@class WBWeiBoDetailView;

NS_ASSUME_NONNULL_BEGIN

@protocol WBWeiBoDetailViewDelegate <NSObject>

/// 推送需要的controller
/// @param detailView 自己的view
/// @param viewController 要推送的controller
- (void)weiBoDetailView:(WBWeiBoDetailView *)detailView pushViewController:(UIViewController *)viewController;

/// 展示需要的controller
/// @param detailView 自己的view
/// @param viewController 要推送的controller
- (void)weiBoDetailView:(WBWeiBoDetailView *)detailView presentViewController:(UIViewController *)viewController;

/// 需要禁用/启用手势
/// @param detailView 自己的view
/// @param isEnabled 需要禁用/启用的手势
- (void)weiBoDetailView:(WBWeiBoDetailView *)detailView userInteraction:(BOOL)isEnabled;

@end

@interface WBWeiBoDetailView : UIView

@property(nonatomic, weak, readwrite) id<WBWeiBoDetailViewDelegate> delegate;
@property(nonatomic, strong, readwrite) NSMutableArray *dataArray;
@property(nonatomic, strong, readwrite) UITableView *tableView;

/// 是否初始化刷新
@property(nonatomic, assign, readwrite) BOOL isInitializedRefresh;

/// 初始化
/// @param frame 初始化frame
/// @param category 类别
- (instancetype)initWithFrame:(CGRect)frame andCategory:(WBWeiBoCategory)category;

/// 进行下拉刷新
- (void)beginDownRefresh;

@end

NS_ASSUME_NONNULL_END
