//
//  GotyeViewController.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-6.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeViewController.h"
#import "GotyeSDKConstants.h"
#import "GotyeSDKResource.h"

@interface GotyeViewController ()

@end

@implementation GotyeViewController

- (id)init
{
    NSBundle *bundle = [GotyeSDKResource resourceBundle];
    NSString *className = NSStringFromClass([self class]);
    
    if (IS_IPAD) {
        NSString *padXib = [NSString stringWithFormat:@"%@~ipad", className];
        NSString *path = [bundle pathForResource:padXib ofType:@"nib"];
        if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
            return self = [super initWithNibName:padXib bundle:bundle];
        }
    }
    
    return self = [super initWithNibName:className bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self changeToLandscapeMode];
    } else {
        [self changeToPortraitMode];
    }
}

- (void)changeToLandscapeMode
{
    
}

- (void)changeToPortraitMode
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self changeToLandscapeMode];
    } else {
        [self changeToPortraitMode];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
//    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
//        [self changeToLandscapeMode];
//    } else {
//        [self changeToPortraitMode];
//    }
}

@end
