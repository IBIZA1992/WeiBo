//
//  WBWeiBoViewController.h
//  WeiBo
//
//  Created by JiangNan on 2022/4/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 微博Tab对应的Controller
@interface WBWeiBoViewController : UIViewController

/// 更新微博
- (void)refreshWeiBo;

/// 给当前位置的微博数据数组
- (NSArray *)dataArray;

@end

NS_ASSUME_NONNULL_END
