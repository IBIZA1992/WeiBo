//
//  WBTextView.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/8.
//

#import "WBTextView.h"

@implementation WBTextView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // 判断字符位置
    NSUInteger characterIndex = [self.layoutManager characterIndexForPoint:point
                                                           inTextContainer:self.textContainer
                                  fractionOfDistanceBetweenInsertionPoints:nil];
    if (characterIndex < self.textStorage.length - 1) {
        // 如果字符是“网页链接”，直接点击
        if ([self.textStorage attribute:NSLinkAttributeName atIndex:characterIndex effectiveRange:nil] != nil) {
            return self;
        }
    }
    return nil;
}

@end
