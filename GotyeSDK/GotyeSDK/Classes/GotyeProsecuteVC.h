//
//  GotyeProsecuteVC.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-20.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeViewController.h"
#import "GotyeUserDelegate.h"

@class GotyeMessage;

@interface GotyeProsecuteVC : GotyeViewController <UIActionSheetDelegate, GotyeUserDelegate, UIAlertViewDelegate>

- (id)initWithMessage:(GotyeMessage *)message;

- (void)showInView:(UIView *)parentView;

@end
