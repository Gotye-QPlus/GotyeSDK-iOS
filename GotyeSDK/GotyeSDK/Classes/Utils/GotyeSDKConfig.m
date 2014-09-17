//
//  GotyeSDKConfig.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-7.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeSDKConfig.h"
#import "GotyeAPI.h"
#import "GotyeDeviceUtil.h"
#import "GotyeSDKData.h"
#import "GotyeSDkSkin.h"
#import "GotyeSDKResource.h"

@implementation GotyeSDKConfig
@synthesize userAccount = _userAccount;

NSString *GotyeSDKConfigAppKey = @"gotye_app_key";
NSString *GotyeSDKConfigUserAccount = @"gotye_user_account";
NSString *GotyeSDKConfigUserNickname = @"gotye_user_nickname";
NSString *GotyeSDKConfigUserGender = @"gotye_user_gender";
NSString *GotyeSDKConfigUserAvatar = @"gotye_user_avatar";

+ (GotyeSDKConfig *)sharedInstance
{
    return (GotyeSDKConfig *)[super sharedInstance];
}

- (void)initWithConfig:(NSDictionary *)config;
{
    _config = config;
    _appKey = _config[GotyeSDKConfigAppKey];
    [self setUserInfo:_config];
    
    NSDictionary *apiConfig = @{GotyeAPIConfigAppKey: _appKey, @"gotyesdk_version":GOTYESDK_VERSION};
    [GotyeAPI initWithConfig:apiConfig];
    
    [[GotyeSDkSkin sharedInstance]loadConfig:[GotyeSDKResource pathForResource:@"GotyeSDKResource-SkinConfig" ofType:@"plist"]];
}

- (void)setUserInfo:(NSDictionary *)userInfo
{
    _userAccount = userInfo[GotyeSDKConfigUserAccount];
    _userNickName = userInfo[GotyeSDKConfigUserNickname];
    _userGender = [userInfo[GotyeSDKConfigUserGender]intValue];
    _userAvatar = userInfo[GotyeSDKConfigUserAvatar];
}

- (NSString *)userAccount
{
    if (_userAccount.length <= 0) {
        return [GotyeDeviceUtil getDeviceID];
    }
    
    return _userAccount;
}

- (void)setChatBG:(UIImage *)chatBG
{
    _chatBG = chatBG;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"gotye_sdk_set_chatBG" object:nil];
}

@end
