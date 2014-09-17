//
//  GotyeSingleton.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-7.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeSingleton.h"

@implementation GotyeSingleton

+ (GotyeSingleton *)sharedInstance
{
    static NSMutableDictionary *instanceMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceMap = [[NSMutableDictionary alloc]init];
    });
    
    NSString *className = NSStringFromClass([self class]);
    GotyeSingleton * instance = instanceMap[className];
    if (instance == nil) {
        instance = [[super alloc]init];
        [instanceMap setObject:instance forKey:className];
    }
    
    return instance;
}

@end
