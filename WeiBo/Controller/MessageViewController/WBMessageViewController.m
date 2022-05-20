//
//  WBMessageViewController.m
//  WeiBo
//
//  Created by JiangNan on 2022/4/30.
//

#import "WBMessageViewController.h"

@interface WBMessageViewController ()

@end

@implementation WBMessageViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"消息";
        self.tabBarItem.image = [UIImage imageNamed:@"message"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"message.fill"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
