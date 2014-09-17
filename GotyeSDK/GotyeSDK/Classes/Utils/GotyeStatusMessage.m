//
//  GotyeStatusMessage.m
//  GotyeSDK
//
//  Created by ouyang on 14-2-25.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeStatusMessage.h"

@implementation GotyeStatusMessage

+ (NSString *)statusMessage:(GotyeStatusCode)code
{
    switch (code) {
        case GotyeStatusCodeOK:
            return @"一切正常";
        case GotyeStatusCodeTimeout:
            return @"连接服务器超时";
        case GotyeStatusCodeVefyFailed:
            return @"验证失败";
        case GotyeStatusCodeLoginFailed:
            return @"登录服务器失败";
        case GotyeStatusCodeForceLogout:
            return @"用户在另外一个客户端登录，您已被强制下线！";
        case GotyeStatusCodeNetworkDisConnected:
            return @"连接服务器失败";
        case GotyeStatusCodeRoomNotExist:
            return @"房间不存在";
        case GotyeStatusCodeRoomIsFull:
            return @"房间已满，请稍后再试";
        case GotyeStatusCodeNotInRoom:
            return @"您不在该房间内，请重新进入";
        case GotyeStatusCodeForbidden:
            return @"您已被禁言，如需恢复请与管理员联系!";
        case GotyeStatusCodeUserNotExist:
            return @"该用户不存在";
        case GotyeStatusCodeSendToSelf:
            return @"不允许给自己发消息";
        case GotyeStatusCodeRequestMicFailed:
            return @"抢麦失败";
        case GotyeStatusCodeVoiceTimeOver:
            return @"您说话时间太长了，请休息一下吧";
        case GotyeStatusCodeArgumentErr:
            return @"参数错误";
        case GotyeStatusCodeUnkonwnError:
            return @"未知错误";
        default:
            break;
    }
    
    return nil;
}

@end
