//
//  GotyeSDkSkin.m
//  GotyeSDK
//
//  Created by ouyang on 14-3-14.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeSDkSkin.h"

NSString * GotyeTextColorMainTitle = @"TextColorMainTitle";
NSString * GotyeTextColorBack = @"TextColorBack";
NSString * GotyeTextColorTopCellName = @"TextColorTopCellName";
NSString * GotyeTextColorNormalCellName = @"TextColorNormalCellName";
NSString * GotyeTextColorMorePanel = @"TextColorMorePanel";
NSString * GotyeTextColorTime = @"TextColorTime";
NSString * GotyeTextColorChatName = @"TextColorChatName";
NSString * GotyeTextColorBubbleLeft = @"TextColorBubbleLeft";
NSString * GotyeTextColorBubbleRight = @"TextColorBubbleRight";
NSString * GotyeTextColorHeaderAndFooter = @"TextColorHeaderAndFooter";
NSString * GotyeTextColorUserListName = @"TextColorUserListName";
NSString * GotyeTextColorPopUserInfo = @"TextColorPopUserInfo";
NSString * GotyeTextColorPopTitle = @"TextColorPopTitle";
NSString * GotyeTextColorBubbleDurationLeft = @"TextColorBubbleDurationLeft";
NSString * GotyeTextColorBubbleDurationRight = @"TextColorBubbleDurationRight";
NSString * GotyeTextColorSendVoiceNormal = @"TextColorSendVoiceNormal";
NSString * GotyeTextColorSendVoicePressed = @"TextColorSendVoicePressed";

@interface GotyeSDkSkin()
{
    NSDictionary *_textColors;
}
@end

@implementation GotyeSDkSkin

+ (GotyeSDkSkin *)sharedInstance
{
    return (GotyeSDkSkin *)[super sharedInstance];
}

- (void)loadConfig:(NSString *)configPath
{
    _textColors = [NSDictionary dictionaryWithContentsOfFile:configPath];
}

- (NSDictionary *)textColors
{
    return _textColors;
}

@end
