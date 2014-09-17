//
//  GotyePortraitNavigationVC.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-25.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyePortraitNavigationVC.h"
#import "GotyeAPI.h"
#import "GotyeSDKUIControl.h"
#import "GotyeSDKConfig.h"

@interface GotyePortraitNavigationVC ()

@end

@implementation GotyePortraitNavigationVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
	//	(iOS 6)
	//	auto rotating
	return !IS_IPAD;
}

- (NSUInteger)supportedInterfaceOrientations
{
	//	(iOS 6)
	return (IS_IPAD ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskAllButUpsideDown);
}

//before iOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (IS_IPAD ? interfaceOrientation == UIInterfaceOrientationPortrait : interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[GotyeSDKUIControl sharedInstance]checkLoginState];
    [self.topViewController viewWillAppear:animated];
}

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
{
#ifdef __IPHONE_7_0
    //ios 7 bug：在push动画未完成时，如果有滑动的操作，会造成界面死锁
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
#endif
    [super pushViewController:viewController animated:animated];
}

@end
