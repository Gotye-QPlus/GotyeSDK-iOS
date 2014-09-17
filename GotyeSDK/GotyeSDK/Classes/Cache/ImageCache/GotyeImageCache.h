//
//  GotyeImageCache.h
//  GotyeSDK
//
//  Created by ouyang on 13-12-16.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GotyeImageCache : NSObject

+ (GotyeImageCache *)sharedImageCache;

- (void)setImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;

- (void)removeImageForKey:(NSString *)key;
- (void)clear;

@end
