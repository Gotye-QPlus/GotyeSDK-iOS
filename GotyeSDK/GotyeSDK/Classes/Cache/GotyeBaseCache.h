//
//  GotyeBaseCache.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-14.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GotyeBaseCache : NSObject

@property(nonatomic, strong) id cachedObject;
@property(nonatomic) NSUInteger expiredTime;

+ (GotyeBaseCache *)cacheWithObject:(id)object;

- (BOOL)isExpired;
- (void)resetCachedTime;

@end
