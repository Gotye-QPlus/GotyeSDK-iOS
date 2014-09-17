//
//  GotyeSDKResource.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-8.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GotyeSDKResource : NSObject

+ (NSBundle *)resourceBundle;
+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)type;

+ (UIImage *)getDefaultAvatar;
+ (UIImage *)getDefaultRoomImage;

+ (UIImage *)getAvatarMask;

@end
