//
//  WBWeiBoTableViewCell.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/2.
//

#import "WBWeiBoTableViewCell.h"
#import "WBScreen.h"
#import "WBWeiBoItem.h"
#import "WBTextView.h"
#import "WBButton.h"
#import "WBLikeModel.h"
#import "WBWebImage.h"

@interface WBWeiBoTableViewCell()<UITextViewDelegate>
@property (nonatomic, strong, readwrite) UIImageView *headImg;
@property (nonatomic, strong, readwrite) UILabel *name;
@property (nonatomic, strong, readwrite) UILabel *from;
@property (nonatomic, strong, readwrite) WBTextView *weiBo;
@property (nonatomic, strong, readwrite) UIView *divideView;
@property (nonatomic, assign, readwrite) NSInteger picCount;
@property (nonatomic, strong, readwrite) NSArray<UIImageView *> *picArray;
@property (nonatomic, strong, readwrite) UIView *barView;
@property (nonatomic, strong, readwrite) WBButton *comments;
@property (nonatomic, strong, readwrite) WBButton *reposts;
@property (nonatomic, strong, readwrite) WBButton *attitudes;
@property (nonatomic, strong, readwrite) UIButton *likeButton;
@property (nonatomic, strong, readwrite) WBLikeModel *likeModel;
@property (nonatomic, strong, readwrite) WBWebImage *webImage;
@property (nonatomic, copy, readwrite) NSString *commentsStr;
@property (nonatomic, copy, readwrite) NSString *repostsStr;
@property (nonatomic, copy, readwrite) NSString *attitudesStr;
@property(nonatomic, copy, readwrite) WBClickWebBlock clickWebBlock;
@property (nonatomic, strong, readwrite) WBWeiBoItem *item;
@end

@implementation WBWeiBoTableViewCell

#pragma mark - Life Cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:({
            UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, 10)];
            upView.backgroundColor = [UIColor colorWithRed:0.933 green:0.929 blue:0.949 alpha:1];
            upView;
        })];
        
        _likeModel = [WBLikeModel shareInstance];
        _webImage = [WBWebImage shareInstance];
        
        [self.contentView addSubview:({
            _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(12, 22, 40, 40)];
            _headImg.image = [UIImage imageNamed:@"head"];
            _headImg.layer.cornerRadius = 20;
            _headImg.layer.masksToBounds = YES;
            _headImg;
        })];
        
        [self.contentView addSubview:({
            _likeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 43, 19, 25, 25)];
            [_likeButton addTarget:self action:@selector(_likeButtonClick) forControlEvents:UIControlEventTouchUpInside];
            _likeButton;
        })];
        
        [self.contentView addSubview:({
            _name = [[UILabel alloc] initWithFrame:CGRectZero];
            _name.font = [UIFont systemFontOfSize:16];
            _name.textColor = [UIColor colorWithRed:0.89 green:0.36 blue:0.19 alpha:1];
            _name;
        })];
        
        [self.contentView addSubview:({
            _from = [[UILabel alloc] initWithFrame:CGRectZero];
            _from.font = [UIFont systemFontOfSize:11];
            _from.alpha = 0.5;
            _from;
        })];
        
        [self.contentView addSubview:({
            _weiBo = [[WBTextView alloc] initWithFrame:CGRectZero];
            _weiBo.font = [UIFont systemFontOfSize:16];
            _weiBo.backgroundColor = [UIColor clearColor];
            _weiBo.delegate = self;
            _weiBo.editable = NO;
            _weiBo.scrollEnabled = NO;
            _weiBo;
        })];
        
        [self.contentView addSubview:({
            _divideView = [[UIView alloc] initWithFrame:CGRectZero];
            _divideView.backgroundColor = [UIColor colorWithRed:0.933 green:0.929 blue:0.949 alpha:1];
            _divideView;
        })];
    
        [self.contentView addSubview:({
            _barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, 10)];
            _barView.backgroundColor = [UIColor whiteColor];
            _barView;
        })];

        [self.barView addSubview:({
            _comments = [[WBButton alloc] init];
            _comments.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _comments.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            _comments.center = self.barView.center;
            _comments;
        })];
        
        [self.barView addSubview:({
            _reposts = [[WBButton alloc] init];
            _reposts.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _reposts.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            _reposts.center = self.barView.center;
            _reposts;
        })];
        
        [self.barView addSubview:({
            _attitudes = [[WBButton alloc] init];
            _attitudes.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _attitudes.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            _attitudes.center = self.barView.center;
            _attitudes;
        })];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setFrame:(CGRect)frame {
    frame.size.width = SCREEN_WIDTH;
    [super setFrame:frame];
}

#pragma mark - public method

- (void)layoutTableViewCellWithItem:(WBWeiBoItem *)item clickWebBlock:(nonnull WBClickWebBlock)clickWebBlock{
    self.clickWebBlock = clickWebBlock;
    
    self.item = item;
    
    [self.likeButton setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    for (WBWeiBoItem *weiBoArrayItem in self.likeModel.likeWeiBoMutableArray) {  // 如果存在
        if ([self.item.idstr isEqualToString:weiBoArrayItem.idstr]) {
            [self.likeButton setImage:[UIImage imageNamed:@"star.fill"] forState:UIControlStateNormal];
            break;
        }
    }
    
    _name.text = item.user_name;
    [_name sizeToFit];
    _name.frame = CGRectMake(_headImg.frame.origin.x + 50, 22, _name.bounds.size.width, _name.bounds.size.height);
    
    _from.text = [NSString stringWithFormat:@"%@   %@", [self _timeFormat:item.created_at], item.source];
    [_from sizeToFit];
    _from.frame = CGRectMake(_headImg.frame.origin.x + 50, 22 + _name.bounds.size.height + 6, _from.bounds.size.width, _from.bounds.size.height);
    
    _weiBo.text = item.text_raw;
    if ([item.text containsString:@"<span class=\"expand\">展开</span>"]) {
        _weiBo.text = [NSString stringWithFormat:@"%@... 全文", item.text_raw];
        [self _needWebAndAllWeiboText:_weiBo.text];
    } else {
        _weiBo.text = item.text_raw;
        [self _needWebText:_weiBo.text];
    }
    _weiBo.frame = CGRectMake(10, self.headImg.frame.origin.y + 40, SCREEN_WIDTH - 20, _weiBo.bounds.size.height);
    [_weiBo sizeToFit];
    
    // 加载图片
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
        imageView.image = [UIImage imageNamed:@"img"];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setClipsToBounds:YES];
        [self.contentView addSubview:imageView];
        [picMutableArray addObject:imageView];
    }
    self.picArray = picMutableArray.copy;
    if (_picCount != 0) {
        self.divideView.frame = CGRectMake(0, self.picArray.lastObject.frame.origin.y + self.picArray.lastObject.bounds.size.height + 15, SCREEN_WIDTH, 1);
    } else {
        self.divideView.frame = CGRectMake(0, self.weiBo.frame.origin.y + self.weiBo.bounds.size.height + 0, SCREEN_WIDTH, 1);
    }
    
    self.barView.frame = CGRectMake(0, self.divideView.frame.origin.y + 1, SCREEN_WIDTH, 35);
    CGFloat comments_num = [item.comments_count integerValue];
    CGFloat reposts_num = [item.reposts_count integerValue];
    CGFloat attitudes_num = [item.attitudes_count integerValue];
    [self.comments setImage:[UIImage imageNamed:@"comments"] forState:UIControlStateNormal];
    if (comments_num >= 10000) {
        self.commentsStr = [NSString stringWithFormat:@"%.1f万", comments_num / 10000];
    } else {
        self.commentsStr = [NSString stringWithFormat:@"%@", item.comments_count];
    }
    [self.comments setTitle:self.commentsStr forState:UIControlStateNormal];
    [self.comments setTitleColor:[UIColor grayColor]forState:UIControlStateNormal];
    [self.comments sizeToFit];
    self.comments.frame = CGRectMake(SCREEN_WIDTH / 2 - self.comments.frame.size.width / 2, self.comments.frame.origin.y, self.comments.frame.size.width, self.comments.frame.size.height);
    [self.reposts setImage:[UIImage imageNamed:@"reposts"] forState:UIControlStateNormal];
    if (reposts_num >= 10000) {
        self.repostsStr = [NSString stringWithFormat:@"%.1f万", reposts_num / 10000];
    } else {
        self.repostsStr = [NSString stringWithFormat:@"%@", item.reposts_count];
    }
    [self.reposts setTitle:self.repostsStr forState:UIControlStateNormal];
    [self.reposts setTitleColor:[UIColor grayColor]forState:UIControlStateNormal];
    [self.reposts sizeToFit];
    self.reposts.frame = CGRectMake(SCREEN_WIDTH / 2 - self.reposts.frame.size.width / 2 - SCREEN_WIDTH / 3, self.reposts.frame.origin.y, self.reposts.frame.size.width, self.reposts.frame.size.height);
    [self.attitudes setImage:[UIImage imageNamed:@"attitudes"] forState:UIControlStateNormal];
    if (attitudes_num >= 10000) {
        self.attitudesStr = [NSString stringWithFormat:@"%.1f万", attitudes_num / 10000];
    } else {
        self.attitudesStr = [NSString stringWithFormat:@"%@", item.attitudes_count];
    }
    [self.attitudes setTitle:self.attitudesStr forState:UIControlStateNormal];
    [self.attitudes setTitleColor:[UIColor grayColor]forState:UIControlStateNormal];
    [self.attitudes sizeToFit];
    self.attitudes.frame = CGRectMake(SCREEN_WIDTH / 2 - self.attitudes.frame.size.width / 2 + SCREEN_WIDTH / 3, self.attitudes.frame.origin.y, self.attitudes.frame.size.width, self.attitudes.frame.size.height);
    
    // 加载图片
    dispatch_queue_global_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_main_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(globalQueue, ^{
        UIImage *image = [self.webImage loadImageWithUrlString:item.user_pic];
        if (image) {
            dispatch_async(mainQueue, ^{
                self.headImg.image = image;
            });
        }
        
        for (int i = 0; i < self.picCount; i++) {
            UIImage *image = [self.webImage loadImageWithUrlString:item.picArray[i]];
            if (image) {
                dispatch_async(mainQueue, ^{
                    self.picArray[i].image = image;
                });
            }
        }
        
    });
}

#pragma mark - private method

- (NSString *)_timeFormat:(NSString *)time {
    NSString *string = time;
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDate *date = [fmt dateFromString:string];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy-MM-dd HH:mm"];
    return [dateFormatter stringFromDate:date];
}

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

- (BOOL)_likeButtonClick{
    for (WBWeiBoItem *weiBoArrayItem in self.likeModel.likeWeiBoMutableArray) {  // 如果存在，点一下不存在
        if ([self.item.idstr isEqualToString:weiBoArrayItem.idstr]) {
            [self.likeButton setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
            [self.likeModel.likeWeiBoMutableArray removeObject:weiBoArrayItem];
            [self.likeModel saveDataFromLocal];
            if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewCell:clickLikeFillButton:)]) {
                [self.delegate tableViewCell:self clickLikeFillButton:self.likeButton];
            }
            return YES;
        }
    }
    [self.likeButton setImage:[UIImage imageNamed:@"star.fill"] forState:UIControlStateNormal];
    [self.likeModel.likeWeiBoMutableArray insertObject:self.item atIndex:0];
    [self.likeModel saveDataFromLocal];
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView
    shouldInteractWithURL:(NSURL *)URL
                  inRange:(NSRange)characterRange
              interaction:(UITextItemInteraction)interaction {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.clickWebBlock(URL);
    });
    return NO;
}

@end


