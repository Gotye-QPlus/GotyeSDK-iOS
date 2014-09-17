
#define GOTYE_SDK_VERSION ("v1.0-201409041854")

//
//  GotyeSDK.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-6.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//
//  SDK核心类


#import "GotyeRoom.h"

/**
 *  调用initWithConfig时传入的字典中，应用appkey的key值，对应的value是NSString类型。
 */
extern NSString * const GotyeSDKConfigAppKey;

/**
 *  setUserInfo传入的字典中，用户登录帐号的key值，对应的value是NSString类型。
 */
extern NSString * const GotyeSDKConfigUserAccount;

/**
 *  setUserInfo传入的字典中，用户昵称的key值，对应的value是NSString类型。
 */
extern NSString * const GotyeSDKConfigUserNickname;

/**
 *  setUserInfo传入的字典中，用户性别的key值，对应的value是NSNumber类型。
 */
extern NSString * const GotyeSDKConfigUserGender;

/**
 *  setUserInfo传入的字典中，用户头像的key值，对应的value是UIImage类型。
 */
extern NSString * const GotyeSDKConfigUserAvatar;

typedef enum
{
    /**
     *  男性
     */
    GotyeSDKUserGenderMale,
    
    /**
     *  女性
     */
    GotyeSDKUserGenderFemale,
    
    /**
     *  未设置
     */
    GotyeSDKUserGenderUnset
}GotyeSDKUserGender;

@interface GotyeSDK : NSObject

/**
 *  初始化SDK。
 *
 *  @param config 初始化需要的参数字典，目前只传入appkey。
 */
+ (void)initWithConfig:(NSDictionary *)config;

/**
 *  启动SDK界面。
 *
 *  @param parent 启动SDK的父视图控制器
 *  @param room   如果直接进入某个特定聊天室，则传入由对应的聊天室信息（ID，名字等）构造 的GotyeRoom对象，否则传入nil。
 *
 *  @return 如果未进行初始化，则返回NO，否则返回YES。
 */
+ (BOOL)launchSDKFrom:(UIViewController *)parent ToRoom:(GotyeRoom *)room;

/**
 *  设置当前用户信息。
 *
 *  @param userInfo 用户信息字典，其中包括用户登录帐号（不赋值则使用设备号）、用户性别、用户昵称、用户头像。
 */
+ (void)setUserInfo:(NSDictionary *)userInfo;

/**
 *  设置登录服务器。默认连接的是亲加通讯云的后台。
 *
 *  @param host 登录服务器地址。
 *  @param port 登录服务器端口。
 */
+ (void)setLoginServer:(NSString *)host port:(NSInteger)port;

@end
