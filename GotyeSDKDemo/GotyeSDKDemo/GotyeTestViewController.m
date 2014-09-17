//
//  GotyeTestViewController.m
//  NewGotyeSDKDemo
//
//  Created by ouyang on 14-1-8.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeTestViewController.h"
#import "GotyeSDK.h"

@interface GotyeTestViewController ()
{
    IBOutlet UITextField *_accountField;
    IBOutlet UITextField *_nickField;
    IBOutlet UISwitch *_maleSwitch;
    IBOutlet UISwitch *_femaleSwitch;
    IBOutlet UISwitch *_unsetSwitch;
    
    IBOutlet UITextField *_ipField;
    IBOutlet UITextField *_portField;
    
    IBOutlet UITextField *_roomIDField;
    IBOutlet UITextField *_roomNameField;
    
    UISwitch *_selectedSwitch;
}
@end

@implementation GotyeTestViewController

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
    // Do any additional setup after loading the view from its nib.
    NSDictionary *info = @{GotyeSDKConfigAppKey:@"8a629636-19f6-4bd8-9b29-e454fdbf4990"};

    [GotyeSDK initWithConfig:info];
    
    _selectedSwitch = _maleSwitch;
    _selectedSwitch.userInteractionEnabled = NO;
    _maleSwitch.tag = GotyeSDKUserGenderMale;
    [_maleSwitch addTarget:self action:@selector(genderSwitched:) forControlEvents:UIControlEventValueChanged];
    
    _femaleSwitch.tag = GotyeSDKUserGenderFemale;
    [_femaleSwitch addTarget:self action:@selector(genderSwitched:) forControlEvents:UIControlEventValueChanged];
    
    _unsetSwitch.tag = GotyeSDKUserGenderUnset;
    [_unsetSwitch addTarget:self action:@selector(genderSwitched:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)findFirstResponder:(UIView *)rootView
{
    if (rootView.isFirstResponder) {
        return rootView;
    }
    for (UIView *subView in rootView.subviews) {
        id responder = [self findFirstResponder:subView];
        if (responder) return responder;
    }
    return nil;
}


- (IBAction)launchBtnClicked:(id)sender
{
    NSDictionary *userInfo = @{GotyeSDKConfigUserAccount: (_accountField.text == nil ? @"" : _accountField.text), GotyeSDKConfigUserNickname: (_nickField.text == nil ? @"" : _nickField.text), GotyeSDKConfigUserGender: @(_selectedSwitch.tag), GotyeSDKConfigUserAvatar:[UIImage imageNamed:@"userAvatar"]};
    [GotyeSDK setUserInfo:userInfo];
    [GotyeSDK setLoginServer:(_ipField.text == nil ? @"" : _ipField.text) port:_portField.text.integerValue];
    GotyeRoom *room = nil;
    if (_roomIDField.text.length > 0 && _roomIDField.text.intValue > 0) {
        room =  [[GotyeRoom alloc]initWithUniqueID:_roomIDField.text];
        room.name = _roomNameField.text;
    }
    [GotyeSDK launchSDKFrom:self ToRoom:room];
}

- (IBAction)cancelBtnClicked:(id)sender
{
    [[self findFirstResponder:self.view]resignFirstResponder];
}

- (void)genderSwitched:(id)sender
{
    _selectedSwitch = (UISwitch *)sender;
    
    [_maleSwitch setOn:(_selectedSwitch == _maleSwitch)];
    _maleSwitch.userInteractionEnabled = !_maleSwitch.isOn;
    [_femaleSwitch setOn:(_selectedSwitch == _femaleSwitch)];
    _femaleSwitch.userInteractionEnabled = !_femaleSwitch.isOn;
    [_unsetSwitch setOn:(_selectedSwitch == _unsetSwitch)];
    _unsetSwitch.userInteractionEnabled = !_unsetSwitch.isOn;

}

@end
