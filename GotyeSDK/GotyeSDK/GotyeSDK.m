//
//  GotyeSDK.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-6.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeSDK.h"
#import "GotyeSDKConfig.h"
#import "GotyeSDKUIControl.h"
#import "GotyeAPI.h"
#import "GotyeSDKData.h"

@implementation GotyeSDK

+ (void)initWithConfig:(NSDictionary *)config
{
    [[GotyeSDKConfig sharedInstance]initWithConfig:config];
}

+ (void)setUserInfo:(NSDictionary *)userInfo
{
    [[GotyeSDKConfig sharedInstance]setUserInfo:userInfo];
}

+ (BOOL)launchSDKFrom:(UIViewController *)parent ToRoom:(GotyeRoom *)room
{
//    [[GotyeSDKConfig sharedInstance]initialize];
    
    if ([GotyeSDKConfig sharedInstance].appKey.length == 0) {
        return NO;
    }
    
    [GotyeSDKConfig sharedInstance].roomToEnter = room;
    [[GotyeSDKUIControl sharedInstance]presentSDK:parent animated:YES];
    return YES;
}

+ (void)setLoginServer:(NSString *)host port:(NSInteger)port
{
    [GotyeAPI setLoginServer:host port:port];
}

//+ (void)setChatBackgroundImage:(UIImage *)bgImage
//{
//    [GotyeSDKConfig sharedInstance].chatBG = bgImage;
//}

@end
