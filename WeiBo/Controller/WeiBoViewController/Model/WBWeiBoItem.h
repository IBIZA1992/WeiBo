//
//  WBWeiBoItem.h
//  WeiBo
//
//  Created by JiangNan on 2022/5/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 列表结构化数据
@interface WBWeiBoItem : NSObject<NSSecureCoding>
@property(nonatomic, copy, readwrite) NSString *created_at;
@property(nonatomic, copy, readwrite) NSString *source;
@property(nonatomic, copy, readwrite) NSString *reposts_count; // 分享数
@property(nonatomic, copy, readwrite) NSString *comments_count; // 评论数
@property(nonatomic, copy, readwrite) NSString *attitudes_count; // 点赞数
@property(nonatomic, copy, readwrite) NSString *idstr;
@property(nonatomic, copy, readwrite) NSString *mblogid;
@property(nonatomic, copy, readwrite) NSString *user_pic;
@property(nonatomic, copy, readwrite) NSString *user_name;
@property(nonatomic, strong, readwrite) NSArray *picArray;
@property(nonatomic, copy, readwrite) NSString *text_raw;
@property(nonatomic, copy, readwrite) NSString *text;
@property(nonatomic, assign, readwrite) BOOL isMedia;
@property(nonatomic, assign, readwrite) BOOL isPage;
@property(nonatomic, assign, readwrite) double height;

/// 解析字典数据
/// @param dictionary 要解析的字典
- (void)configWithDictionary:(NSDictionary *)dictionary;

/// 解析"我的"微博数据获取的字典
/// @param dictionary 要解析的字典
- (NSString *)configMineWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
