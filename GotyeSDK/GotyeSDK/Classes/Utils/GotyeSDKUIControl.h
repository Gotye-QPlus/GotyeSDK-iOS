//
//  GotyeSDKUIControl.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-7.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeSingleton.h"
#import "GotyeLoginDelegate.h"
#import "GotyeUserDelegate.h"
#import "GotyeRoomDelegate.h"

@class GotyePortraitNavigationVC;

@interface GotyeSDKUIControl : GotyeSingleton <GotyeLoginDelegate, GotyeUserDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, GotyeRoomDelegate>

+ (GotyeSDKUIControl *)sharedInstance;

- (void)presentSDK:(UIViewController *)parentViewController animated:(BOOL)animated;
- (void)closeSDK:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)popViewControllerAnimated:(BOOL)animated;

- (void)showHudInView:(UIView *)view animated:(BOOL)animated text:(NSString *)text;
- (void)hideHudInView:(UIView *)view animated:(BOOL)animated;

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate;

- (void)showFullScreenView:(UIView *)fullScreenView inView:(UIView *)view;
- (void)hideFullScreenView:(UIView *)fullScreenView;

- (void)minimizeSDK;
- (void)resumeSDKTo:(UIViewController *)parentViewController;

- (void)makeRoundedView:(UIView *)view;

- (BOOL)checkLoginState;

@property(nonatomic, strong) UIViewController *sdkParentViewController;
@property(nonatomic, strong) GotyePortraitNavigationVC *sdkRootViewController;
@property(nonatomic) BOOL showSDKAnimated;
@property(nonatomic) BOOL isSDKMinimized;

@end
