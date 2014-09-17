//
//  GotyeImageCache.m
//  GotyeSDK
//
//  Created by ouyang on 13-12-16.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeImageCache.h"
#import "TMMemoryCache.h"

@implementation GotyeImageCache

+ (GotyeImageCache *)sharedImageCache
{
    static dispatch_once_t onceToken;
    static GotyeImageCache* instance;
    dispatch_once(&onceToken, ^{
        instance = [[GotyeImageCache alloc]init];
    });
    
    return instance;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    [[TMMemoryCache sharedCache]setObject:image forKey:key];
}

- (UIImage *)imageForKey:(NSString *)key
{
    return [[TMMemoryCache sharedCache]objectForKey:key];
}

- (void)removeImageForKey:(NSString *)key
{
    [[TMMemoryCache sharedCache]removeObjectForKey:key];
}

- (void)clear
{
    [[TMMemoryCache sharedCache]removeAllObjects];
}

@end
