//
//  WBSendWeiBoViewController.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/6.
//

#import "WBSendWeiBoViewController.h"
#import "WBOauthModel.h"
#import "WBScreen.h"
#import "WeiboSDK.h"

@interface WBSendWeiBoViewController ()

@end

@implementation WBSendWeiBoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [WeiboSDK shareToWeibo:@"SDK Share Test"];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
