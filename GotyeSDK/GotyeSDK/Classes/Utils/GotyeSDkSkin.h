//
//  GotyeSDkSkin.h
//  GotyeSDK
//
//  Created by ouyang on 14-3-14.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GotyeSingleton.h"

extern NSString * GotyeTextColorMainTitle;
extern NSString * GotyeTextColorBack;
extern NSString * GotyeTextColorTopCellName;
extern NSString * GotyeTextColorNormalCellName;
extern NSString * GotyeTextColorMorePanel;
extern NSString * GotyeTextColorTime;
extern NSString * GotyeTextColorChatName;
extern NSString * GotyeTextColorBubbleLeft;
extern NSString * GotyeTextColorBubbleRight;
extern NSString * GotyeTextColorHeaderAndFooter;
extern NSString * GotyeTextColorUserListName;
extern NSString * GotyeTextColorPopUserInfo;
extern NSString * GotyeTextColorPopTitle;
extern NSString * GotyeTextColorBubbleDurationLeft;
extern NSString * GotyeTextColorBubbleDurationRight;
extern NSString * GotyeTextColorSendVoiceNormal;
extern NSString * GotyeTextColorSendVoicePressed;

@interface GotyeSDkSkin : GotyeSingleton

+ (GotyeSDkSkin *)sharedInstance;

- (void)loadConfig:(NSString *)configPath;
- (NSDictionary *)textColors;

@end
