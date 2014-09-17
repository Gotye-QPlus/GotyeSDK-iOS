//
//  GotyeSDKUIControl.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-7.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeSDKUIControl.h"
#import "GotyeRoomListVC.h"
#import "GotyeSDKConstants.h"
#import "GotyeMBProgressHUD.h"
#import "GotyeSDKConfig.h"
#import "GotyeSDKData.h"
#import "GotyeUser.h"
#import "GotyeSDKResource.h"
#import "GotyeImageManager.h"
#import "GotyePortraitNavigationVC.h"
#import "GotyeChatVC.h"
#import "GotyeStatusMessage.h"

@interface GotyeSDKUIControl()
{
    BOOL _statusBarHidden;
    BOOL _onlyRoom;
    NSString *_lastMsgID;
}

@end

@implementation GotyeSDKUIControl

+ (GotyeSDKUIControl *)sharedInstance
{
    return (GotyeSDKUIControl *)[super sharedInstance];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)presentSDK:(UIViewController *)parentViewController animated:(BOOL)animated
{
    _sdkParentViewController = parentViewController;
//    _sdkParentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    _showSDKAnimated = animated;
    _statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    
    [[GotyeSDKData sharedInstance]initialize];
    [[GotyeImageManager sharedImageManager]initialize];
    
    if (_isSDKMinimized) {
        [self resumeSDKTo:parentViewController];
        return;
    }
    
    _onlyRoom = ([GotyeSDKConfig sharedInstance].roomToEnter != nil);
    
    if (![GotyeAPI isOnline]) {
        [self login];
        return;
    }
    
    if (_onlyRoom && ![GotyeAPI isRoomEntered:[GotyeSDKConfig sharedInstance].roomToEnter]) {
        [self enterRoom];
    } else {
        [self _loadMainView];
    }

}

- (void)closeSDK:(BOOL)animated
{
    [[UIApplication sharedApplication]setStatusBarHidden:_statusBarHidden];
    
    [_sdkRootViewController dismissModalViewControllerAnimated:animated];
    _sdkRootViewController = nil;
    
    [GotyeAPI logout];
    
    //释放资源
    [[GotyeSDKData sharedInstance]uninitialize];
    [[GotyeImageManager sharedImageManager]uninitialize];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [GotyeAPI removeListener:self];
}

- (void)minimizeSDK
{
    [[UIApplication sharedApplication]setStatusBarHidden:_statusBarHidden];

    [_sdkRootViewController dismissModalViewControllerAnimated:_showSDKAnimated];
    _isSDKMinimized = YES;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)resumeSDKTo:(UIViewController *)parentViewController
{
    _sdkParentViewController = parentViewController;
    [_sdkParentViewController presentModalViewController:_sdkRootViewController animated:_showSDKAnimated];
    _isSDKMinimized = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(applicationDidBecomActive:)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [_sdkRootViewController pushViewController:viewController animated:animated];
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    if (_sdkRootViewController.viewControllers.count == 1) {
        [self closeSDK:animated];
    } else {
        [_sdkRootViewController popViewControllerAnimated:animated];
    }
}

- (void)showHudInView:(UIView *)view animated:(BOOL)animated text:(NSString *)text
{
    GotyeMBProgressHUD *hud = [GotyeMBProgressHUD HUDForView:view];
    if (hud == nil) {
        hud = [GotyeMBProgressHUD showHUDAddedTo:view animated:animated];
    }
    
    hud.labelText = text;
    hud.removeFromSuperViewOnHide = YES;
}

- (void)hideHudInView:(UIView *)view animated:(BOOL)animated
{
    [GotyeMBProgressHUD hideAllHUDsForView:view animated:animated];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

- (void)showFullScreenView:(UIView *)fullScreenView inView:(UIView *)view
{
    [view addSubview:fullScreenView];
    fullScreenView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    fullScreenView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    fullScreenView.alpha = 0;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         fullScreenView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                         fullScreenView.alpha = 1.0;
                     }
                     completion:nil
     ];
}

- (void)hideFullScreenView:(UIView *)fullScreenView
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         fullScreenView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
                         fullScreenView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             [fullScreenView removeFromSuperview];
                         }
                     }
     ];
}

- (void)makeRoundedView:(UIView *)view
{
//    return;
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:5.0];
    [layer setShouldRasterize:YES];
    [layer setRasterizationScale:[UIScreen mainScreen].scale];
    // You can even add a border
    [layer setBorderWidth:.7];
    [layer setBorderColor:[[UIColor grayColor] CGColor]];
}

- (void)login
{
    [self showHudInView:_sdkParentViewController.view animated:YES text:@"登录中..."];
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeLogin];
    [GotyeAPI loginWithUsername:[GotyeSDKConfig sharedInstance].userAccount password:nil];
}

- (void)enterRoom
{
    [self showHudInView:_sdkParentViewController.view animated:YES text:@"进入中..."];
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeRoom];
    [GotyeAPI enterRoom:[GotyeSDKConfig sharedInstance].roomToEnter];
}

- (void)_loadMainView
{
    if ([_sdkParentViewController.modalViewController isEqual:_sdkRootViewController]) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(applicationDidBecomActive:)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    if (!_sdkRootViewController) {
        UIViewController *rootVC;
        if (_onlyRoom) {
            rootVC = [[GotyeChatVC alloc]initWithChatUnit:[GotyeSDKConfig sharedInstance].roomToEnter lastMsgID:_lastMsgID];
        } else {
            rootVC = [[GotyeRoomListVC alloc]init];
        }
        
        _sdkRootViewController = [[GotyePortraitNavigationVC alloc]initWithRootViewController:rootVC];
        _sdkRootViewController.navigationBarHidden = YES;
        _sdkRootViewController.delegate = self;
    }
    
    [_sdkParentViewController presentModalViewController:_sdkRootViewController animated:_showSDKAnimated];
}

- (void)applicationDidBecomActive:(NSNotification *)notification
{
    [self checkLoginState];
}

- (BOOL)checkLoginState
{
    if ([GotyeAPI isOnline]) {
        return YES;
    }
    
    DLog(@"not online");
    [[GotyeSDKUIControl sharedInstance]showHudInView:_sdkRootViewController.topViewController.view animated:NO text:@"正在登录..."];
    [GotyeAPI loginWithUsername:[GotyeSDKConfig sharedInstance].userAccount password:nil];
    
    return NO;
}


#pragma mark - login delegate

- (void)onLoginResp:(GotyeStatusCode)statusCode account:(NSString *)account appKey:(NSString *)appKey
{
    [self hideHudInView:_sdkParentViewController.view animated:NO];
    [self hideHudInView:_sdkRootViewController.topViewController.view animated:NO];
    
    if (statusCode != GotyeStatusCodeOK) {
//        NSString *errorMsg = [NSString stringWithFormat:@"%@%d", @"登录服务器失败！错误码:",statusCode];
        [self showAlertViewWithTitle:nil message:[GotyeStatusMessage statusMessage:statusCode] delegate:self];
        return;
    }
    
    if (_onlyRoom) {
        [self enterRoom];
    } else {
        [self _loadMainView];
    }
}

- (void)onLogout:(GotyeStatusCode)error account:(NSString *)account appKey:(NSString *)appKey
{
    DLog(@"%@退出登录: %@", account, [GotyeStatusMessage statusMessage:error]);
    if (_sdkRootViewController == nil) {
        return;
    }
    
    //正常退出
    if (error == GotyeStatusCodeOK) {
        return;
    }
    
    [[GotyeSDKUIControl sharedInstance]showAlertViewWithTitle:nil message:@"与服务器失去连接" delegate:self];
}

#pragma mark - room delegate -

- (void)onEnterRoom:(GotyeRoom *)room lastMsgID:(NSString *)lastMsgID result:(GotyeStatusCode)status
{
    DLog(@"onEnterRoom:%@ lastMsgID:%@ result: %d", room.uniqueID, lastMsgID, status);

    _lastMsgID = lastMsgID;
    
    [[GotyeSDKUIControl sharedInstance]hideHudInView:_sdkParentViewController.view animated:NO];
    
    if (status != GotyeStatusCodeOK && status != GotyeStatusCodeTimeout) {
        [[GotyeSDKUIControl sharedInstance]showAlertViewWithTitle:nil message:@"进群失败" delegate:self];
        return;
    }
    
    [GotyeAPI removeListener:self type:GotyeAPIListenerTypeRoom];
    
    [self _loadMainView];
}

#pragma mark - navigation delegate -

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![viewController isKindOfClass:[GotyeRoomListVC class]]) {
        [self checkLoginState];
    }
    
#ifdef __IPHONE_7_0
    //ios 7 bug：在push动画未完成时，如果有滑动的操作，会造成界面死锁。在第一个vc界面有滑动操作，也会造成界面卡死
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        // disable interactivePopGestureRecognizer in the rootViewController of navigationController
        if ([[navigationController.viewControllers firstObject] isEqual:viewController]) {
            navigationController.interactivePopGestureRecognizer.enabled = NO;
        } else {
            // enable interactivePopGestureRecognizer
            navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
#endif
}

#pragma mark - alert view delegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [_sdkRootViewController popToRootViewControllerAnimated:YES];
    }
}

@end
