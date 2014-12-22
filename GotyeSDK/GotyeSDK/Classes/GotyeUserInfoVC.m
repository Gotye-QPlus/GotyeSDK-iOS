//
//  GotyeUserInfoVC.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-20.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeUserInfoVC.h"
#import "GotyeUser.h"
#import "GotyeSDKData.h"
#import "GotyeImageManager.h"
#import "GotyeSDKResource.h"
#import "GotyeSDKUIControl.h"
#import "UIImage+Mask.h"
#import "UIColor+HTML.h"
#import "GotyeSDkSkin.h"

@interface GotyeUserInfoVC ()
{
    IBOutlet UIImageView *_avatar;
    IBOutlet UILabel *_nameLabel;
    IBOutlet UILabel *_idLabbel;
    IBOutlet UILabel *_genderLabel;
    IBOutlet UIButton *_chatBtn;
    
    UIButton *_backgroundBtn;
    
    GotyeSDKUserInfo *_userInfo;
    NSString *_userAccount;
    __strong GotyeUserInfoVC *_retained_self;
}

@end

NSDictionary *_genderMap;
BOOL _showing;

@implementation GotyeUserInfoVC


- (id)initWithUserAccount:(NSString *)account
{
    if (self = [super init]) {
        _userAccount = account;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _genderMap = @{@(GotyeUserGenderMale): @"男", @(GotyeUserGenderFemale): @"女", @(GotyeUserGenderUnset):@"你猜"};

    });
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _nameLabel.textColor = _idLabbel.textColor = _genderLabel.textColor = [UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorPopUserInfo]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showInView:(UIView *)parentView
{
    if (_showing) {
        return;
    }
    
    _showing = YES;
    _retained_self = self;
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeUser];
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeDownload];
    
    if (!_backgroundBtn) {
        _backgroundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backgroundBtn addTarget:self action:@selector(backgroundBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundBtn setBackgroundImage:[[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"fullscreen_bg" ofType:@"png"]]  forState:UIControlStateNormal];
        _backgroundBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    _backgroundBtn.frame = parentView.bounds;

    [parentView addSubview:_backgroundBtn];
    
    self.view.frame = CGRectMake((_backgroundBtn.frame.size.width - self.view.frame.size.width) /2 , (_backgroundBtn.frame.size.height - self.view.frame.size.height) /2, self.view.frame.size.width, self.view.frame.size.height);
    
    [[GotyeSDKUIControl sharedInstance]showFullScreenView:self.view inView:parentView];
    
    _userInfo = [[GotyeSDKData sharedInstance]getUserWithAccount:_userAccount];
    if (_userInfo == nil) {
        _userInfo = [[GotyeSDKUserInfo alloc]initWithUniqueID:_userAccount];
    }
    
    [self updateUserInfo];
}

- (void)hide
{
    [[GotyeSDKUIControl sharedInstance]hideFullScreenView:self.view];
    [_backgroundBtn removeFromSuperview];
    
    [GotyeAPI removeListener:self];
    
    _retained_self = nil;

    _showing = NO;
}

- (void)updateUserInfo
{
    [self updateUserAvatar];
    _nameLabel.text = _userInfo.name;
    _idLabbel.text = [NSString stringWithFormat:@"ID：%d", _userInfo.userID];
    _genderLabel.text = [NSString stringWithFormat:@"性别：%@", _genderMap[@(_userInfo.gender)]];
}

- (void)updateUserAvatar
{
    UIImage *avatar = _userInfo.userAvatar;
    if (avatar == nil) {
        avatar = [[GotyeImageManager sharedImageManager]getImageWithPath:_userInfo.avatarURL];
        if (avatar == nil) {
            avatar = [GotyeSDKResource getDefaultAvatar];
        }
    }
    
    _avatar.image = [avatar maskWithImage:[GotyeSDKResource getAvatarMask]];
}

#pragma mark - actions -

- (IBAction)closeBtnClicked:(id)sender
{
    [self hide];
}

- (IBAction)chatBtnClicked:(id)sender
{
    
}

- (void)backgroundBtnClicked:(id)sender
{
    [self hide];
}

#pragma mark - user delegate -

- (void)onGetUserInfo:(GotyeUser *)user result:(GotyeStatusCode)status
{
    if (status != GotyeStatusCodeOK) {
        return;
    }
    
    if ([user.uniqueID isEqualToString:_userInfo.uniqueID]) {
        _userInfo = [[GotyeSDKData sharedInstance]getUserWithAccount:user.uniqueID];
        [self updateUserInfo];
    }
}

#pragma mark - download delegate -

- (void)onDownloadRes:(NSString *)downloadURL path:(NSString *)savedPath result:(GotyeStatusCode)status
{
    if (status != GotyeStatusCodeOK) {
        return;
    }
    
    if (![downloadURL isEqualToString:_userInfo.avatarURL]) {
        return;
    }
    
    [self updateUserAvatar];
}

@end
