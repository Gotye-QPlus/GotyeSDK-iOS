//
//  GotyeChatMessageItem.h
//  GotyeSDK
//
//  Created by ouyang on 14-2-18.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GotyeMessage;

typedef enum
{
    //发送消息状态
    GotyeChatMessageStateSending,
    GotyeChatMessageStateSendSuccessful,
    GotyeChatMessageStateSendFailed,
    GotyeChatMessageStateForbidden,
    
    //接收消息状态
    GotyeChatMessageStateReceived,
    GotyeChatMessageStateDownloading,
    GotyeChatMessageStateDownloadSuccessful,
    GotyeChatMessageStateDownloadFailed
}GotyeChatMessageState;

@interface GotyeChatMessageItem : NSObject

@property(nonatomic, strong) GotyeMessage *msgObj;
@property(nonatomic) BOOL needToShowTime;
@property(nonatomic) GotyeChatMessageState state;
@property(nonatomic, strong) NSAttributedString *formattedText;
@property(nonatomic) CGSize textSize;

@end
