//
//  WBGetWeiBoItemHeight.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/4.
//

#import "WBGetWeiBoItemHeight.h"
#import "WBWeiBoItem.h"
#import "WBScreen.h"

@interface WBGetWeiBoItemHeight()
@property (nonatomic, strong, readwrite) UITextView *weiBo;
@property (nonatomic, strong, readwrite) UIView *divideView;
@property (nonatomic, assign, readwrite) NSInteger picCount;
@property (nonatomic, strong, readwrite) NSArray<UIImageView *> *picArray;
@property (nonatomic, strong, readwrite) UIView *barView;
@end

@implementation WBGetWeiBoItemHeight

#pragma mark - public method

- (CGFloat)getItemHeight:(WBWeiBoItem *)item {
    _weiBo = [[UITextView alloc] init];
    _weiBo.font = [UIFont systemFontOfSize:16];
    _weiBo.backgroundColor = [UIColor clearColor];
    _weiBo.editable = NO;
    _weiBo.scrollEnabled = NO;
    _weiBo.text = item.text_raw;
    if ([item.text containsString:@"<span class=\"expand\">展开</span>"]) {
        _weiBo.text = [NSString stringWithFormat:@"%@... 全文", item.text_raw];
        [self _needWebAndAllWeiboText:_weiBo.text];
    } else {
        _weiBo.text = item.text_raw;
        [self _needWebText:_weiBo.text];
    }
    _weiBo.frame = CGRectMake(10, 22 + 40, SCREEN_WIDTH - 20, _weiBo.bounds.size.height);
    [_weiBo sizeToFit];
    
    if (item.picArray.count >= 9) {
        self.picCount = 9;
    } else {
        self.picCount = item.picArray.count;
    }
    
    NSMutableArray<UIImageView *> *picMutableArray = @[].mutableCopy;
    for (int i = 0; i < self.picCount; i++) {
        CGFloat width = (SCREEN_WIDTH - 40) / 3;
        CGFloat height = width;
        CGFloat x = 15 + (i % 3) * (width + 5);
        CGFloat y = _weiBo.bounds.size.height + _weiBo.frame.origin.y + (i / 3) * (height + 5);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setClipsToBounds:YES];
        [picMutableArray addObject:imageView];
    }
    self.picArray = picMutableArray.copy;

    if (_picCount != 0) {
        self.divideView = [[UIView alloc] initWithFrame:CGRectMake(0, self.picArray.lastObject.frame.origin.y + self.picArray.lastObject.frame.size.height + 15, SCREEN_WIDTH, 1)];
    } else {
        self.divideView = [[UIView alloc] initWithFrame:CGRectMake(0, self.weiBo.frame.origin.y + self.weiBo.bounds.size.height + 0, SCREEN_WIDTH, 1)];
    }
    return self.divideView.frame.origin.y + 36;
}

#pragma mark - private method

- (void)_needWebAndAllWeiboText:(NSString *)wholeText {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:wholeText];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithRed:0.89 green:0.36 blue:0.19 alpha:1]
                 range:[[text string] rangeOfString:@"全文"]];
    NSError *error;
    NSDataDetector *dataDetector=[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *arrayOfAllMatches=[dataDetector matchesInString:wholeText options:NSMatchingReportProgress range:NSMakeRange(0, wholeText.length)];
    NSMutableAttributedString *text1 = [[NSMutableAttributedString alloc]initWithString:@" 网页链接 "];
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {

        [text replaceCharactersInRange:match.range withAttributedString:text1];
        [text addAttribute:NSLinkAttributeName
                                 value:match.URL
                                 range:[[text string] rangeOfString:@" 网页链接 "]];

    }
    _weiBo.attributedText = text;
    [_weiBo  setFont:[UIFont systemFontOfSize:16]];
}

- (void)_needWebText:(NSString *)wholeText {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:wholeText];
    NSError *error;
    NSDataDetector *dataDetector=[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *arrayOfAllMatches=[dataDetector matchesInString:wholeText options:NSMatchingReportProgress range:NSMakeRange(0, wholeText.length)];
    NSMutableAttributedString *text1 = [[NSMutableAttributedString alloc]initWithString:@" 网页链接 "];
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {

        [text replaceCharactersInRange:match.range withAttributedString:text1];
        [text addAttribute:NSLinkAttributeName
                                 value:match.URL
                                 range:[[text string] rangeOfString:@" 网页链接 "]];

    }
    _weiBo.attributedText = text;
    [_weiBo  setFont:[UIFont systemFontOfSize:16]];
    
}

@end

