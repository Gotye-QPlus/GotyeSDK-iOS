//
//  GotyeUserInfoVC.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-20.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeViewController.h"
#import "GotyeUserDelegate.h"
#import "GotyeDownloadDelegate.h"

@class GotyeUser;

@interface GotyeUserInfoVC : GotyeViewController <GotyeUserDelegate, GotyeDownloadDelegate>

- (id)initWithUserAccount:(NSString *)account;

- (void)showInView:(UIView *)parentView;
- (void)hide;

@end
