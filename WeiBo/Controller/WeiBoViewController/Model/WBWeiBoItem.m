//
//  WBWeiBoItem.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/2.
//

#import "WBWeiBoItem.h"
#import "WBOauthModel.h"

@interface WBWeiBoItem()

@end

@implementation WBWeiBoItem

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.created_at = [coder decodeObjectForKey:@"created_at"];
        self.source = [coder decodeObjectForKey:@"source"];
        self.reposts_count = [coder decodeObjectForKey:@"reposts_count"];
        self.comments_count = [coder decodeObjectForKey:@"comments_count"];
        self.attitudes_count = [coder decodeObjectForKey:@"attitudes_count"];
        self.idstr = [coder decodeObjectForKey:@"idstr"];
        self.mblogid = [coder decodeObjectForKey:@"mblogid"];
        self.user_pic = [coder decodeObjectForKey:@"user_pic"];
        self.user_name = [coder decodeObjectForKey:@"user_name"];
        self.picArray = [coder decodeObjectForKey:@"picArray"];
        self.text_raw = [coder decodeObjectForKey:@"text_raw"];
        self.text = [coder decodeObjectForKey:@"text"];
        NSNumber *isMediaNumber = [coder decodeObjectForKey:@"isMedia"];
        self.isMedia = isMediaNumber.boolValue;
        NSNumber *isPageNumber = [coder decodeObjectForKey:@"isPage"];
        self.isPage = isPageNumber.boolValue;
        NSNumber *height = [coder decodeObjectForKey:@"height"];
        self.height = height.doubleValue;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.created_at forKey:@"created_at"];
    [coder encodeObject:self.source forKey:@"source"];
    [coder encodeObject:self.reposts_count forKey:@"reposts_count"];
    [coder encodeObject:self.comments_count forKey:@"comments_count"];
    [coder encodeObject:self.attitudes_count forKey:@"attitudes_count"];
    [coder encodeObject:self.idstr forKey:@"idstr"];
    [coder encodeObject:self.mblogid forKey:@"mblogid"];
    [coder encodeObject:self.user_pic forKey:@"user_pic"];
    [coder encodeObject:self.user_name forKey:@"user_name"];
    [coder encodeObject:self.picArray forKey:@"picArray"];
    [coder encodeObject:self.text_raw forKey:@"text_raw"];
    [coder encodeObject:self.text forKey:@"text"];
    [coder encodeObject:[NSNumber numberWithBool:self.isMedia] forKey:@"isMedia"];
    [coder encodeObject:[NSNumber numberWithBool:self.isMedia] forKey:@"isPage"];
    [coder encodeObject:[NSNumber numberWithDouble:self.height] forKey:@"height"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark - public method

- (void)configWithDictionary:(NSDictionary *)dictionary {
    
    self.created_at = [dictionary objectForKey:@"created_at"];
    self.source = [dictionary objectForKey:@"source"];
    self.reposts_count = [dictionary objectForKey:@"reposts_count"];
    self.comments_count = [dictionary objectForKey:@"comments_count"];
    self.attitudes_count = [dictionary objectForKey:@"attitudes_count"];
    self.idstr = [dictionary objectForKey:@"idstr"];
    self.mblogid = [dictionary objectForKey:@"mblogid"];
    
    NSDictionary *user = [dictionary objectForKey:@"user"];
    self.user_pic = [user objectForKey:@"avatar_large"];
    self.user_name = [user objectForKey:@"screen_name"];
    
    // 加载图片
    NSMutableArray *picMutableArray = @[].mutableCopy;
    NSArray *pic_ids = [dictionary objectForKey:@"pic_ids"];
    for (NSString *pic_id in pic_ids) {
        NSDictionary *picDict1 = [dictionary objectForKey:@"pic_infos"];
        NSDictionary *picDict2 = [picDict1 objectForKey:pic_id];
        NSDictionary *picDict3 = [picDict2 objectForKey:@"bmiddle"];
        NSString *picStr = [picDict3 objectForKey:@"url"];
        [picMutableArray addObject:picStr];
    }
    self.picArray = picMutableArray.copy;
    
    self.text_raw = [dictionary objectForKey:@"text_raw"];
    self.text = [dictionary objectForKey:@"text"];
    
    if ([dictionary objectForKey:@"page_info"]) {
        NSDictionary *dict = [dictionary objectForKey:@"page_info"];
        if ([dict objectForKey:@"media_info"]) {
            self.isMedia = YES;
            self.isPage = YES;
        } else {
            self.isMedia = NO;
            self.isPage = YES;
        }
    } else {
        self.isMedia = NO;
        self.isPage = NO;
    }
}

- (NSString *)configMineWithDictionary:(NSDictionary *)dictionary {
    self.created_at = [dictionary objectForKey:@"created_at"];
    self.source = @"";
    self.reposts_count = [dictionary objectForKey:@"reposts_count"];
    self.comments_count = [dictionary objectForKey:@"comments_count"];
    self.attitudes_count = [dictionary objectForKey:@"attitudes_count"];
    self.idstr = [dictionary objectForKey:@"idstr"];
    self.mblogid = [dictionary objectForKey:@"mid"];
    
    NSDictionary *user = [dictionary objectForKey:@"user"];
    self.user_pic = [user objectForKey:@"avatar_large"];
    self.user_name = [user objectForKey:@"screen_name"];
    id uid = [user objectForKey:@"id"];
    
    // 加载图片
    NSMutableArray *picMutableArray = @[].mutableCopy;
    NSArray *pic_ids = [dictionary objectForKey:@"pic_urls"];
    for (NSDictionary *pic_id in pic_ids) {
        NSString *picStr = [pic_id objectForKey:@"thumbnail_pic"];
        [picMutableArray addObject:picStr];
    }
    self.picArray = picMutableArray.copy;
    
    self.text_raw = [dictionary objectForKey:@"text"];
    id isLongText = [dictionary objectForKey:@"isLongText"];
    if (((NSNumber *)isLongText).boolValue != 0) {
        self.text = @"<span class=\"expand\">展开</span>";
    } else {
        self.text = @"";
    }

    self.isMedia = NO;
    self.isPage = NO;
    
    return [NSString stringWithFormat:@"%@", uid];
}

@end
