//
//  GotyeStatusMessage.h
//  GotyeSDK
//
//  Created by ouyang on 14-2-25.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GotyeStatusCode.h"

@interface GotyeStatusMessage : NSObject

+ (NSString *)statusMessage:(GotyeStatusCode)code;

@end
