//
//  WBDiscoverViewController.m
//  WeiBo
//
//  Created by JiangNan on 2022/4/30.
//

#import "WBDiscoverViewController.h"

@interface WBDiscoverViewController ()

@end

@implementation WBDiscoverViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"发现";
        self.tabBarItem.image = [UIImage imageNamed:@"discover"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"discover.fill"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
