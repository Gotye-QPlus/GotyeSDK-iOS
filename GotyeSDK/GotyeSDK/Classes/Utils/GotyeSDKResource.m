//
//  GotyeSDKResource.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-8.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeSDKResource.h"
#import "GotyeSDKConstants.h"
#import "GotyeImageManager.h"

@implementation GotyeSDKResource

+ (NSBundle *)resourceBundle
{
    return [NSBundle bundleWithURL:
            [[NSBundle mainBundle] URLForResource:GotyeSDK_RESOURCES_BUNDLE withExtension:@"bundle"]];
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)type
{
    return [[self resourceBundle]pathForResource:name ofType:type];
}

+ (UIImage *)getDefaultAvatar
{
    return [[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"default_user_avatar" ofType:@"png"]];
}

+ (UIImage *)getDefaultRoomImage
{
    return [[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"default_room_image" ofType:@"jpg"]];
}

UIImage *_bubbleImageMask;

+ (UIImage *)getAvatarMask
{
    if (!_bubbleImageMask) {
        UIImage *originImage = [[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"avatar_mask" ofType:@"png"]];
        CGSize imageSize = originImage.size;
        _bubbleImageMask = [originImage stretchableImageWithLeftCapWidth:imageSize.width / 2 topCapHeight:imageSize.height / 2];
    }
    
    return _bubbleImageMask;
}

@end
