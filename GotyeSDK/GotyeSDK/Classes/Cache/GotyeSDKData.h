//
//  GotyeSDKData.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-13.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GotyeSingleton.h"
#import "GotyeAPI.h"
#import "GotyeUser.h"

@interface GotyeSDKUserInfo : GotyeUser

- (id)initWithUser:(GotyeUser *)user;

@property(nonatomic, GOTYESDK_WEAK_ATTR) UIImage *userAvatar;

@end

@interface GotyeSDKData : GotyeSingleton <GotyeUserDelegate, GotyeLoginDelegate, GotyeDownloadDelegate, NSCacheDelegate>

+ (GotyeSDKData *)sharedInstance;

@property(nonatomic, strong) GotyeSDKUserInfo *currentUser;

//user info cache
- (void)initialize;
- (GotyeSDKUserInfo *)getUserWithAccount:(NSString *)accountName;
- (void)clearCache;
- (void)uninitialize;

@end
