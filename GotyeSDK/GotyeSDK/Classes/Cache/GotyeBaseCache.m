//
//  GotyeBaseCache.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-14.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeBaseCache.h"

@interface GotyeBaseCache()
{
    double _cachedTime;
}
@end

@implementation GotyeBaseCache

- (id)init
{
    if (self = [super init]) {
        _cachedTime = CACurrentMediaTime();
    }
    
    return self;
}

+ (GotyeBaseCache *)cacheWithObject:(id)object
{
    GotyeBaseCache * cache = [[GotyeBaseCache alloc] init];
    cache.cachedObject = object;
    
    return cache;
}

- (BOOL)isExpired
{
    if (_expiredTime <= 0) {
        return NO;
    }
    
    double currentTime = CACurrentMediaTime();
    return ((currentTime - _cachedTime) >= _expiredTime);
}

- (void)resetCachedTime
{
    _cachedTime = CACurrentMediaTime();
}

@end
