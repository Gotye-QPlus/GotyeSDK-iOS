//
//  GotyeProsecuteVC.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-20.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeProsecuteVC.h"
#import "GotyeMessage.h"
#import "GotyeSDKData.h"
#import "GotyeUser.h"
#import "GotyeSDKUIControl.h"
#import "GotyeSDKResource.h"
#import "GotyeAPI.h"
#import "GotyeSDKUIControl.h"
#import "GotyeImageManager.h"
#import "UIColor+HTML.h"
#import "GotyeSDkSkin.h"

NSArray *_prosecuteType;

@interface GotyeProsecuteVC ()
{
    GotyeMessage *_message;
    GotyeUser *_userInfo;
    
    IBOutlet UITextView *_textView;
    IBOutlet UIView *_textArea;
    IBOutlet UIButton *_confirmBtn;
    IBOutlet UILabel *_titleLabel;
    
    UIButton *_backgroundBtn;
    __strong GotyeProsecuteVC *_retained_self;
    
    CGFloat _initialY;
    NSInteger _selectedType;
    
    UIView *_parentView;
    
}
@end

@implementation GotyeProsecuteVC

- (void)dealloc
{
    [self unregisterForKeyboardNotifications];
}

- (id)initWithMessage:(GotyeMessage *)message
{
    if (self = [super init]) {
        _message = message;
        _userInfo = (GotyeUser *)_message.sender;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _prosecuteType =  @[@"恶意刷屏", @"谩骂", @"其它理由"];
    });
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self registerForKeyboardNotifications];

    _titleLabel.textColor = [UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorPopTitle]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showInView:(UIView *)parentView
{
    _retained_self = self;
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeUser];

    _parentView = parentView;
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"请选择投诉理由" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:_prosecuteType[0], _prosecuteType[1], _prosecuteType[2], nil];
    
    [sheet showInView:_parentView];
}

- (void)showPopView
{
    if (!_backgroundBtn) {
        _backgroundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backgroundBtn addTarget:self action:@selector(backgroundBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundBtn setBackgroundImage:[[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"fullscreen_bg" ofType:@"png"]]  forState:UIControlStateNormal];
        _backgroundBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    _backgroundBtn.frame = _parentView.bounds;
    
    [_parentView addSubview:_backgroundBtn];
    
    self.view.frame = CGRectMake((_backgroundBtn.frame.size.width - self.view.frame.size.width) /2 , (_backgroundBtn.frame.size.height - self.view.frame.size.height) /2, self.view.frame.size.width, self.view.frame.size.height);
    
    [[GotyeSDKUIControl sharedInstance]showFullScreenView:self.view inView:_parentView];
}

- (void)hide
{
    [_textView resignFirstResponder];
    [[GotyeSDKUIControl sharedInstance]hideFullScreenView:self.view];
    [_backgroundBtn removeFromSuperview];
    
    [GotyeAPI removeListener:self];
    _retained_self = nil;
}

- (void) moveTextViewForKeyBoard:(NSNotification*)notify up:(BOOL)up
{
    NSDictionary *userInfo = [notify userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    if(animationDuration > 0)
    {
        // Animate up or down
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }
    
    CGRect newFrame = self.view.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    //CGRect textViewScreenFrame= [textView convertRect:textView.frame toView:self.view.superview];
    
    if(!up)
        newFrame.origin.y = _initialY;
    else {
//        newFrame.origin.y = _backgroundBtn.frame.size.height - _textArea.frame.origin.y - _textArea.frame.size.height - keyboardFrame.size.height;
        newFrame.origin.y = _backgroundBtn.frame.size.height - self.view.frame.size.height - keyboardFrame.size.height;
        if (newFrame.origin.y > _initialY) {
            newFrame.origin.y = _initialY;
        }
    }
    self.view.frame = newFrame;
    
    if(animationDuration > 0)
    {
        [UIView commitAnimations];
    }
}

- (void) keyboardWillShown:(NSNotification*)notify
{
    _initialY = self.view.frame.origin.y;
    [self moveTextViewForKeyBoard:notify up:YES];
}

- (void) keyboardWillHidden:(NSNotification*)notify
{
    // keyboardShown = NO;
    [self moveTextViewForKeyBoard:notify up:NO];
}

- (void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - actions -

- (void)backgroundBtnClicked:(id)sender
{
    if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
    } else {
        [self hide];
    }
}

- (IBAction)closeBtnClicked:(id)sender
{
    [self hide];
}

- (IBAction)confirmBtnClicked:(id)sender
{
    [[GotyeSDKUIControl sharedInstance]showHudInView:_parentView animated:NO text:nil];
    [GotyeAPI reportUser:_userInfo.uniqueID type:_selectedType content:_textView.text message:_message];
}

- (IBAction)cancelKeyboardBtnClicked:(id)sender
{
    [_textView resignFirstResponder];
}

#pragma mark - text view delegate -

- (void)textViewDidBeginEditing:(UITextView *)textView
{

}

- (void)textViewDidEndEditing:(UITextView *)textView
{

}

#pragma mark - action sheet delegate -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < _prosecuteType.count) {
        _selectedType = buttonIndex;
        if (buttonIndex != _prosecuteType.count - 1) {
            [self confirmBtnClicked:nil];
        } else {
            [self showPopView];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == _prosecuteType.count) {
        [self hide];
    }
}

#pragma mark - alert view delegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self hide];
}

#pragma mark - user delegate -

- (void)onReportUser:(NSString *)userAccount result:(GotyeStatusCode)status
{
    [[GotyeSDKUIControl sharedInstance]hideHudInView:_parentView animated:NO];
    
    [GotyeAPI removeListener:self];
    NSString *message = (status == GotyeStatusCodeOK ? @"举报成功" : [NSString stringWithFormat:@"%@%d", @"举报失败: ", status]);
    [[GotyeSDKUIControl sharedInstance]showAlertViewWithTitle:@"举报" message:message delegate:self];
}

@end
