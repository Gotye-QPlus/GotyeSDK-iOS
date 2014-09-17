//
//  GotyeChatVC.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-8.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeViewController.h"
#import "GotyeAPI.h"
#import "EGORefreshTableHeaderView.h"
#import "GotyeTouchTableView.h"

@class GotyeFullScreenImage;
@class GotyeEmoticonPanel;

@interface GotyeChatVC : GotyeViewController <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GotyeChatDelegate, GotyeRoomDelegate, GotyeUserDelegate, GotyeDownloadDelegate, UIAlertViewDelegate, GotyePlaybackDelegate, GotyeLoginDelegate,  UIGestureRecognizerDelegate, EGORefreshTableDelegate, GotyeTouchTableViewDelegate>
{
    IBOutlet GotyeTouchTableView *_msgListView;
    IBOutlet UIButton *_textModeBtn;
    IBOutlet UIButton *_voiceModeBtn;
    IBOutlet UIButton *_sendVoiceBtn;
    IBOutlet UITextView *_textArea;
    IBOutlet UIImageView *_textAreaBg;
    IBOutlet UIView *_textModeView;
    IBOutlet UIView *_extraPanelView;
    IBOutlet UIView *_bottomView;
    IBOutlet UIView *_topView;
    IBOutlet UIView *_speakingView;
    IBOutlet UIImageView *_speakingIndicator;
    IBOutlet UIImageView *_voiceIcon;
    IBOutlet UILabel *_titleLabel;
    IBOutlet UIView *_morePanel;
    IBOutlet UIView *_voiceTooShortView;
    IBOutlet UIButton *_moreBtn;
    IBOutlet UIView *_popActionView;
    IBOutlet UIImageView *_popActionBG;
    IBOutlet UIButton *_copyBtn;
    IBOutlet UIButton *_prosecuteBtn;
    IBOutlet UIImageView *_popActionDivider;
    IBOutlet UIButton *_roomUserListBtn;
    IBOutlet UIButton *_backToGameBtn;
    IBOutlet UIButton *_showExtraBtn;
    IBOutlet UIImageView *_bgImageView;
    IBOutlet UIButton *_backBtn;
    IBOutlet UILabel *_voiceError;
    
    IBOutlet UIImageView *_topBarBG;
    
    IBOutlet UIImageView *_roomIconView;
    IBOutlet UIImageView *_greenLine0;
    IBOutlet UIImageView *_greenLine1;
    IBOutlet UIImageView *_greenLine2;
    IBOutlet UIImageView *_greenLine3;
    IBOutlet UIButton *_userListBtnLandscape;
    IBOutlet UIButton *_minimizeBtnLandscape;
    
    IBOutlet UIView *_chatContentView;
    
    UIPopoverController *_imagePopover;
}

- (id)initWithChatUnit:(GotyeChatUnit *)chatUnit lastMsgID:(NSString *)lastMsgID;


@end
