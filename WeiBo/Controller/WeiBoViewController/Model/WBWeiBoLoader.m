//
//  WBWeiBoLoader.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/2.
//

#import "WBWeiBoLoader.h"
#import "WBWeiBoItem.h"
#import "WBOauthModel.h"
#import "WBCacheWeiBoModel.h"
#import "WBGetWeiBoItemHeight.h"
#import <AFNetworking.h>

@implementation WBWeiBoLoader

#pragma mark - public method

- (void)loadWeiBoDataWithPageNmu:(NSInteger)pageNum category:(WBWeiBoCategory)category finishBlock:(WBWeiBoLoaderFinishBlock)finishBlock {
    WBCacheWeiBoModel *cacheWeiBoModel = [WBCacheWeiBoModel shareInstance];
    WBOauthModel *oauthModel = [WBOauthModel shareInstance];
    NSString *urlString;
    if (category == WBWeiBoCategoryMine) {
        if (pageNum == 0) {
            NSMutableArray *listItemArray = @[].mutableCopy;
            urlString = [NSString stringWithFormat:@"https://api.weibo.com/2/statuses/user_timeline.json?access_token=%@", oauthModel.access_token];
            
            // 请求网络
            [[AFHTTPSessionManager manager] GET:urlString parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {

                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        NSLog(@"");
                        NSArray *dataArray = [responseObject objectForKey:@"statuses"];
                        if (dataArray != nil) {
                            for (NSDictionary *info in dataArray) {
                                WBWeiBoItem *listItem = [[WBWeiBoItem alloc] init];
                                [listItem configMineWithDictionary:info];
                                if (!listItem.isMedia && ![listItem.text_raw containsString:@"http://mapi/"] && ![self _isManyWeb:listItem.text_raw]) {
                                    [listItemArray addObject:listItem];
                                }
                            }
                            NSString *urlString = [NSString stringWithFormat:@"https://api.weibo.com/2/statuses/home_timeline.json?access_token=%@&page=1", oauthModel.access_token];
                            [[AFHTTPSessionManager manager] GET:urlString parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                                
                            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                NSArray *dataArray = [responseObject objectForKey:@"statuses"];
                                if (dataArray != nil) {
                                    for (NSDictionary *info in dataArray) {
                                        WBWeiBoItem *listItem = [[WBWeiBoItem alloc] init];
                                        NSString *uid = [listItem configMineWithDictionary:info];
                                        if (!listItem.isMedia && ![listItem.text_raw containsString:@"http://mapi/"] && ![self _isManyWeb:listItem.text_raw] && ![uid isEqualToString:oauthModel.uid]) {
                                            [listItemArray addObject:listItem];
                                        }
                                    }
                                }
                                dispatch_async(dispatch_get_main_queue(), ^{  // 放在主线程
                                    WBGetWeiBoItemHeight *getHeight = [[WBGetWeiBoItemHeight alloc] init];
                                    for (WBWeiBoItem *item in listItemArray) {
                                        item.height = [getHeight getItemHeight:item];
                                    }
                                    [cacheWeiBoModel archiveListDataWithArray:listItemArray.copy category:category];
                                    if (finishBlock) {
                                        finishBlock(YES, listItemArray);
                                    }
                                    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishLoader)]) {
                                        [self.delegate didFinishLoader];
                                    }
                                });
                            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                
                            }];
                        }
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        NSLog(@"");
                    }];
            
        } else {
            urlString = [NSString stringWithFormat:@"https://api.weibo.com/2/statuses/home_timeline.json?access_token=%@&page=%@", oauthModel.access_token, @(pageNum+1)];
            
            // 加载网络
            [[AFHTTPSessionManager manager] GET:urlString parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                            
                        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            NSArray *dataArray = [responseObject objectForKey:@"statuses"];
                            NSMutableArray *listItemArray = @[].mutableCopy;
                            if (dataArray != nil) {
                                for (NSDictionary *info in dataArray) {
                                    WBWeiBoItem *listItem = [[WBWeiBoItem alloc] init];
                                    NSString *uid = [listItem configMineWithDictionary:info];
                                    if (!listItem.isMedia && ![listItem.text_raw containsString:@"http://mapi/"] && ![self _isManyWeb:listItem.text_raw] && ![uid isEqualToString:oauthModel.uid]) {
                                        [listItemArray addObject:listItem];
                                    }
                                }
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{  // 放在主线程
                                WBGetWeiBoItemHeight *getHeight = [[WBGetWeiBoItemHeight alloc] init];
                                for (WBWeiBoItem *item in listItemArray) {
                                    item.height = [getHeight getItemHeight:item];
                                }
                                if (finishBlock) {
                                    finishBlock(YES, listItemArray);
                                }
                                if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishLoader)]) {
                                    [self.delegate didFinishLoader];
                                }
                            });
                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            
                        }];
        }
    } else {
        if (category == WBWeiBoCategoryHot) {
            if (pageNum == 0) {
                urlString = @"https://weibo.com/ajax/feed/hottimeline?since_id=0&refresh=0&group_id=102803&containerid=102803&extparam=discover%7Cnew_feed&max_id=0&count=10";
            } else {
                urlString = [NSString stringWithFormat:@"https://weibo.com/ajax/feed/hottimeline?refresh=2&group_id=102803&containerid=102803&extparam=discover%%7Cnew_feed&max_id=%@&count=10", @(pageNum+1)];
            }
        } else if (category == WBWeiBoCategorySports) {
            if (pageNum == 0) {
                urlString = @"https://weibo.com/ajax/feed/hottimeline?since_id=0&refresh=1&group_id=1028031388&containerid=102803_ctg1_1388_-_ctg1_1388&extparam=discover%7Cnew_feed&max_id=0&count=10";
            } else {
                urlString = [NSString stringWithFormat:@"https://weibo.com/ajax/feed/hottimeline?refresh=2&group_id=1028031388&containerid=102803_ctg1_1388_-_ctg1_1388&extparam=discover%%7Cnew_feed&max_id=%@&count=10", @(pageNum+1)];
            }
        } else if (category == WBWeiBoCategoryTechnology) {
            if (pageNum == 0) {
                urlString = @"https://weibo.com/ajax/feed/hottimeline?since_id=0&refresh=1&group_id=1028032088&containerid=102803_ctg1_2088_-_ctg1_2088&extparam=discover%7Cnew_feed&max_id=0&count=10";
            } else {
                urlString = [NSString stringWithFormat:@"https://weibo.com/ajax/feed/hottimeline?refresh=2&group_id=1028032088&containerid=102803_ctg1_2088_-_ctg1_2088&extparam=discover%%7Cnew_feed&max_id=%@&count=10", @(pageNum+1)];
            }
        } else if (category == WBWeiBoCategoryEntertainment) {
            if (pageNum == 0) {
                urlString = @"https://weibo.com/ajax/feed/hottimeline?since_id=0&refresh=1&group_id=1028034288&containerid=102803_ctg1_4288_-_ctg1_4288&extparam=discover%7Cnew_feed&max_id=0&count=10";
            } else {
                urlString = [NSString stringWithFormat:@"https://weibo.com/ajax/feed/hottimeline?refresh=2&group_id=1028034288&containerid=102803_ctg1_4288_-_ctg1_4288&extparam=discover%%7Cnew_feed&max_id=%@&count=10", @(pageNum+1)];
            }
        }

        // 设置header,防止出现m.weibo这样在移动端的现象
        NSDictionary *header = @{@"User-Agent":@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15"};
        // 请求网络
        [[AFHTTPSessionManager manager] GET:urlString parameters:nil headers:header progress:^(NSProgress * _Nonnull downloadProgress) {

                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSArray *dataArray = [responseObject objectForKey:@"statuses"];
                    NSMutableArray *listItemArray = @[].mutableCopy;
                    for (NSDictionary *info in dataArray) {
                        WBWeiBoItem *listItem = [[WBWeiBoItem alloc] init];
                        [listItem configWithDictionary:info];
                        if (!listItem.isMedia && ![listItem.text_raw containsString:@"http://mapi/"] && ![self _isManyWeb:listItem.text_raw]) {
                            [listItemArray addObject:listItem];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{  // 放在主线程
                        WBGetWeiBoItemHeight *getHeight = [[WBGetWeiBoItemHeight alloc] init];
                        for (WBWeiBoItem *item in listItemArray) {
                            item.height = [getHeight getItemHeight:item];
                        }
                        if (pageNum == 0) {
                            [cacheWeiBoModel archiveListDataWithArray:listItemArray.copy category:category];
                        }
                        if (finishBlock) {
                            finishBlock(YES, listItemArray);
                        }
                        if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishLoader)]) {
                            [self.delegate didFinishLoader];
                        }
                    });
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                }];
    }
}

#pragma mark - private method

- (BOOL)_isManyWeb:(NSString *)wholeText {
    NSError *error;
    NSDataDetector *dataDetector=[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *arrayOfAllMatches=[dataDetector matchesInString:wholeText options:NSMatchingReportProgress range:NSMakeRange(0, wholeText.length)];
    if (arrayOfAllMatches == nil || arrayOfAllMatches.count == 1 || arrayOfAllMatches.count == 0) {
        return NO;
    } else {
        return YES;
    }
}

@end
