//
//  GotyeSDKConfig.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-7.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeSingleton.h"
#import "GotyeUser.h"

#define GOTYESDK_VERSION (@"GotyeSDK 1.0")

@class GotyeRoom;

@interface GotyeSDKConfig : GotyeSingleton
{
    NSDictionary *_config;
}

+ (GotyeSDKConfig *)sharedInstance;

- (void)initWithConfig:(NSDictionary *)config;
- (void)setUserInfo:(NSDictionary *)userInfo;

//- (void)initialize;

@property(nonatomic, strong) NSString *appKey;
@property(nonatomic, strong) NSString *userAccount;
@property(nonatomic, strong) NSString *userNickName;
@property(nonatomic) GotyeUserGender userGender;
@property(nonatomic, strong) UIImage *userAvatar;
@property(nonatomic, strong) UIImage *chatBG;
@property(nonatomic, strong) GotyeRoom *roomToEnter;

@end
