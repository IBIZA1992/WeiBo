//
//  WBWebImage.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/16.
//

#import "WBWebImage.h"

@interface WBWebImage()
@property(nonatomic, strong, readwrite) NSMutableDictionary *imageDictionary;
@property(nonatomic, strong, readwrite) NSMutableArray *imageKeyArray;
@property(nonatomic, assign, readwrite) NSInteger deleteIndex;
@end

@implementation WBWebImage

#pragma mark - Life Cycle

+ (instancetype)shareInstance {
    static WBWebImage *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super allocWithZone:NULL] init];
    });
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [WBWebImage shareInstance];
}

#pragma mark - private method

- (void)_setImage:image forKey:key{
    if (self.imageDictionary == nil) {
        self.imageDictionary = [[NSMutableDictionary alloc] init];
    }
    if (self.imageKeyArray == nil) {
        self.imageKeyArray = @[].mutableCopy;
    }
    [self.imageDictionary setObject:image forKey:key];
    if (self.imageDictionary.count > 1000) {  // 设定缓冲1000条数据，防止缓冲过多
        [self.imageDictionary removeObjectForKey:self.imageKeyArray[self.deleteIndex]];
        self.deleteIndex++;
    }
    [self.imageKeyArray addObject:key];
}

#pragma mark - public method

- (UIImage *)loadImageWithUrlString:(NSString *)urlString {
    UIImage *image = [self.imageDictionary objectForKey:urlString];
    if (image) {
        // 如果内存中有
        return image;
    } else {
        // 如果内存中没有
        
        // 沙盒
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *dataPath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"WBImageData/%@", [urlString lastPathComponent]]];
        NSData *imageDataFromLocal =[NSData dataWithContentsOfFile:dataPath];
        if (imageDataFromLocal) {
            // 如果磁盘中有
            UIImage *image = [UIImage imageWithData:imageDataFromLocal];
            [self _setImage:image forKey:urlString];
            return image;
        } else {
            // 如果磁盘中没有
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            UIImage *image = [UIImage imageWithData:imageData];
            if (image) {  // 防止网络异常
                [self _setImage:image forKey:urlString];
                [imageData writeToFile:dataPath atomically:YES];
                return image;
            } else {
                return nil;
            }
        }
    }
}

@end
