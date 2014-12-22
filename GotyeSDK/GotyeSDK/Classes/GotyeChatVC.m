//
//  GotyeChatVC.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-8.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeChatVC.h"
#import "GotyeSDKUIControl.h"
#import "GotyeSDKResource.h"
#import "GotyeRoomUserListVC.h"
#import "GotyeSDKData.h"
#import "GotyeMessageBubbleCell.h"
#import "GotyeImageManager.h"
#import "GotyeUser.h"
#import "GotyeEmotionLabel.h"
#import "GotyeVoiceObject.h"
#import "GotyeTextCell.h"
#import "GotyeMessageBubbleCell.h"
#import "GotyeImageCell.h"
#import "GotyeFileUtil.h"
#import "GotyeVoiceCell.h"
#import "NSString+MD5.h"
#import "GotyeFullScreenImage.h"
#import "GotyeEmoticonPanel.h"
#import "GotyeUserInfoVC.h"
#import "GotyeProsecuteVC.h"
#import "GotyeSDKConfig.h"
#import "GotyeTimeUtil.h"
#import "GotyeChatMessageItem.h"
#import "GotyeSDKConstants.h"
#import "GotyeStatusMessage.h"
#import "UIImage+Mask.h"
#import "GotyeMessageBubbleCell.h"
#import "UIColor+HTML.h"
#import "GotyeSDkSkin.h"
#import <AVFoundation/AVFoundation.h>

#define kFullScreenImageTag (0x1100)
#define kGetHisttoryLimit   (10)

@interface GotyeChatVC ()
{
    BOOL _isTextMode;
    NSInteger _initBottomHeight;
    NSInteger _initTextHeight;
    NSInteger _maxTextHeight;
    NSInteger _maxTextLines;
    UIImage *_bgOfTextAreaFocused;
    //    UIImage *_bgOfTextAreaLostFocus;
    
    GotyeEmoticonPanel *_emoticonPanel;
    GotyeChatUnit *_targetUnit;
    
    NSMutableArray *_messageArray;
    
    NSCache *_cachedCellHeight;
    NSCache *_cachedCellsForCalculatingHeight;
    
    NSMutableArray *_downloadingRes;
    GotyeMessage *_lastClickVoice;
    NSMutableDictionary *_sendMsgMap;

    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isLoading;
    NSString *_lastMsgID;
    
    UIMenuController *_menuController;
    UIMenuItem *_copyItem;
    UIMenuItem *_prosecuteItem;
    NSInteger _actionIndex;
    
    CGRect backBtnFramePortrait;
    CGRect titleFramePortrait;
    CGRect topbarFramePortrait;
    
    UIEdgeInsets backBtnInsetsPortrait;
    
    UIImage *topbarBGPortrait;
    UIImage *topbarBGLandscape;
    UIImage *backBtnBG;
    
    CGFloat _keyboardOffset;
}

@end

@implementation GotyeChatVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [GotyeAPI removeListener:self];
}

- (id)initWithChatUnit:(GotyeChatUnit *)chatUnit lastMsgID:(NSString *)lastMsgID
{
    if (self = [super init]) {
        _targetUnit = chatUnit;
        _lastMsgID = lastMsgID;
        
        _messageArray = [[NSMutableArray alloc]init];
        _downloadingRes = [[NSMutableArray alloc]init];
        
        _cachedCellHeight = [[NSCache alloc]init];
        
        _cachedCellsForCalculatingHeight = [[NSCache alloc]init];
        
        _sendMsgMap = [[NSMutableDictionary alloc]init];
        
        //最多4行
        _maxTextLines = 4;
        _actionIndex = -1;
        
        [GotyeAPI addListener:self type:GotyeAPIListenerTypeLogin];
        [GotyeAPI addListener:self type:GotyeAPIListenerTypeChat];
        [GotyeAPI addListener:self type:GotyeAPIListenerTypeUser];
        [GotyeAPI addListener:self type:GotyeAPIListenerTypeDownload];
        [GotyeAPI addListener:self type:GotyeAPIListenerTypeRoom];
        [GotyeAPI addListener:self type:GotyeAPIListenerTypePlayer];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _textArea.textColor = [UIColor blackColor];
    
    backBtnFramePortrait = _backBtn.frame;
    titleFramePortrait = _titleLabel.frame;
    topbarFramePortrait = _topView.frame;
    backBtnInsetsPortrait = _backBtn.imageEdgeInsets;
    
    topbarBGPortrait = _topBarBG.image;
    topbarBGLandscape = [UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"titlebar_bg_landscape" ofType:@"png"]];
    backBtnBG = [_backBtn backgroundImageForState:UIControlStateNormal];
    
	// Do any additional setup after loading the view.
    [self createHeaderView];
    [self updateChateBG];
    [self initPopMenu];
    
    UIImage *voiceUpImage = [[UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"chat_bottom_bar_btn_send_voice_normal" ofType:@"png"]]stretchableImageWithLeftCapWidth:20 topCapHeight:15];
    UIImage *voiceDownImage = [[UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"chat_bottom_bar_btn_send_voice_pressed" ofType:@"png"]]stretchableImageWithLeftCapWidth:20 topCapHeight:15];
    [_sendVoiceBtn setBackgroundImage:voiceUpImage forState:UIControlStateNormal];
    [_sendVoiceBtn setTitleColor:[UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorSendVoiceNormal]] forState:UIControlStateNormal];
    [_sendVoiceBtn setBackgroundImage:voiceDownImage forState:UIControlStateHighlighted];
    [_sendVoiceBtn setTitleColor:[UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorSendVoicePressed]] forState:UIControlStateHighlighted];
    
    [_backBtn setTitleColor:[UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorBack]] forState:UIControlStateNormal];
    _titleLabel.textColor = [UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorMainTitle]];
    [_roomUserListBtn setTitleColor:[UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorMorePanel]] forState:UIControlStateNormal];
    [_backToGameBtn setTitleColor:[UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorMorePanel]] forState:UIControlStateNormal];
    
    CGRect bgFrame = _bgImageView.frame;
    bgFrame.size.height = self.view.bounds.size.height - bgFrame.origin.y;
    _bgImageView.frame = bgFrame;
    
    //ios 7中，点击事件会被srollview拦截造成延迟
    _msgListView.delaysContentTouches = NO;
    _msgListView.touchDelegate = self;
    
    _initBottomHeight = _bottomView.frame.size.height;
    _initTextHeight = _textArea.frame.size.height;

    _maxTextHeight = ceilf(_textArea.font.lineHeight * _maxTextLines);
    
    _speakingIndicator.animationImages = @[[UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"chat_speaking_state_0" ofType:@"png"]], [UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"chat_speaking_state_1" ofType:@"png"]], [UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"chat_speaking_state_2" ofType:@"png"]]];
    _speakingIndicator.animationDuration = 1.0f;
    
    [self registerForKeyboardNotifications];
    
    NSString *title;
    if (_targetUnit.unitType == GotyeChatUnitTypeRoom) {
        title = _targetUnit.name;
    } else {
        title = @"";
    }
    
    _titleLabel.text = title;
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(applicationDidBecomActive:)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateChateBG) name:@"gotye_sdk_set_chatBG" object:nil];
    
    //ios 7 bug: 须设置delegate才能开启手势滑动返回的功能
#ifdef __IPHONE_7_0
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
#endif
    [_refreshHeaderView setState:EGOOPullRefreshLoading];
    [_msgListView setContentOffset:CGPointMake(0, - LOADING_OFFSET)];
    [self loadMore:5 containLastMsg:YES];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [GotyeAPI stopPlay];
    [GotyeAPI stopTalk];
    [self hideEverything];

    //push操作或者最小化操作都不需要释放
    if (self.parentViewController != nil && [GotyeSDKUIControl sharedInstance].sdkRootViewController != nil) {
        return;
    }
    
    [self exit];
}

- (void)changeToLandscapeMode
{
    _topView.frame = CGRectMake(0, 0, kSidebarWidth, UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? self.view.bounds.size.height : self.view.bounds.size.width);
    _topBarBG.image = topbarBGLandscape;
    
    CGFloat mainViewX = _topView.frame.size.width - 4;
    _chatContentView.frame = CGRectMake(mainViewX, 0, self.view.bounds.size.width - mainViewX, self.view.bounds.size.height - _keyboardOffset);
    
    _roomIconView.hidden = NO;
    _roomIconView.frame = CGRectMake((_topView.frame.size.width - _roomIconView.frame.size.width) / 2, 25, _roomIconView.frame.size.width, _roomIconView.frame.size.height);
    
    _titleLabel.frame = CGRectMake((_topView.frame.size.width - 85) / 2, _roomIconView.frame.origin.y + _roomIconView.frame.size.height + 10, 85, 40);
    _titleLabel.numberOfLines = 2;
    
    _backBtn.frame = CGRectMake(0, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 18, _topView.frame.size.width, 40);
    [_backBtn setBackgroundImage:nil forState:UIControlStateNormal];
    _backBtn.imageEdgeInsets = UIEdgeInsetsMake(14, 33, 13, 75);
    
    _greenLine0.hidden = NO;
    _greenLine0.frame = CGRectMake(0, _backBtn.frame.origin.y, _greenLine0.frame.size.width, _greenLine0.frame.size.height);
    
    _greenLine1.hidden = NO;
    _greenLine1.frame = CGRectMake(0, _backBtn.frame.origin.y + _backBtn.frame.size.height, _greenLine1.frame.size.width, _greenLine1.frame.size.height);
    
    _userListBtnLandscape.hidden = NO;
    _userListBtnLandscape.frame = CGRectMake(0, _backBtn.frame.origin.y + _backBtn.frame.size.height + _greenLine1.frame.size.height, _topView.frame.size.width, 40);
    
    _greenLine2.hidden = NO;
    _greenLine2.frame = CGRectMake(0, _userListBtnLandscape.frame.origin.y + _userListBtnLandscape.frame.size.height, _greenLine2.frame.size.width, _greenLine2.frame.size.height);
    
    _minimizeBtnLandscape.hidden = NO;
    _minimizeBtnLandscape.frame = CGRectMake(0, _userListBtnLandscape.frame.origin.y + _userListBtnLandscape.frame.size.height + _greenLine2.frame.size.height, _topView.frame.size.width, 40);
    
    _greenLine3.hidden = NO;
    _greenLine3.frame = CGRectMake(0, _minimizeBtnLandscape.frame.origin.y + _minimizeBtnLandscape.frame.size.height, _greenLine3.frame.size.width, _greenLine3.frame.size.height);
    
    _bgImageView.frame = CGRectMake(_chatContentView.frame.origin.x, 0, _chatContentView.frame.size.width, _chatContentView.bounds.size.height + _keyboardOffset);

    _morePanel.hidden = YES;
    _moreBtn.hidden = YES;
    
    [self adjustEmotiPanel:UIInterfaceOrientationLandscapeLeft];
}

- (void)changeToPortraitMode
{
    _topView.frame = topbarFramePortrait;
    _topBarBG.image = topbarBGPortrait;
    
    CGFloat mainViewY = _topView.frame.size.height;
    _chatContentView.frame = CGRectMake(0, mainViewY, self.view.bounds.size.width, self.view.bounds.size.height - mainViewY - _keyboardOffset);
    
    _backBtn.frame = backBtnFramePortrait;
    [_backBtn setBackgroundImage:backBtnBG forState:UIControlStateNormal];
    _backBtn.imageEdgeInsets = backBtnInsetsPortrait;
    _titleLabel.frame = titleFramePortrait;
    _titleLabel.numberOfLines = 1;

    _greenLine0.hidden = YES;
    _greenLine1.hidden = YES;
    _greenLine2.hidden = YES;
    _greenLine3.hidden = YES;
    _minimizeBtnLandscape.hidden = YES;
    _userListBtnLandscape.hidden = YES;
    _roomIconView.hidden = YES;
    
    _bgImageView.frame = CGRectMake(_chatContentView.frame.origin.x, _chatContentView.frame.origin.y -4, _chatContentView.frame.size.width, _chatContentView.bounds.size.height + _keyboardOffset + 4);
    
    _morePanel.hidden = NO;
    _moreBtn.hidden = NO;
    
    [self adjustEmotiPanel:UIInterfaceOrientationPortrait];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    [_msgListView reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self textViewDidChange:_textArea];
    [self listViewScrollToEnd:YES];
}

- (void)initPopMenu
{
    _menuController = [UIMenuController sharedMenuController];
    _copyItem = [[UIMenuItem alloc]initWithTitle:@"复制" action:@selector(copyBtnClicked:)];
    _prosecuteItem = [[UIMenuItem alloc]initWithTitle:@"举报" action:@selector(prosecuteBtnClicked:)];
}

//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
//初始化刷新视图
//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
#pragma mark
#pragma methods for creating and removing the header view

- (void)createHeaderView
{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:
                          CGRectMake(0.0f, 0.0f - self.view.bounds.size.height,
                                     self.view.frame.size.width, self.view.bounds.size.height) arrowImage:[UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"arrow" ofType:@"png"]] textColor:TEXT_COLOR];
    _refreshHeaderView.normalText = @"下拉查看更多";
    _refreshHeaderView.pullingText = @"松开查看更多";
    
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
	[_msgListView addSubview:_refreshHeaderView];
    
    [_refreshHeaderView refreshLastUpdatedDate];
}

//===============
//刷新delegate
#pragma mark -
#pragma mark data reloading methods that must be overide by the subclass

- (void)beginToReloadData:(EGORefreshPos)aRefreshPos
{
	
	//  should be calling your tableviews data source model to reload
	_isLoading = YES;
    
    if (aRefreshPos == EGORefreshHeader) {
        // pull down to refresh data
        [self loadMore:kGetHisttoryLimit containLastMsg:NO];
    }
}

#pragma mark -
#pragma mark method that should be called when the refreshing is finished

- (void)finishLoadingData
{
	
	//  model should call this when its done loading
	_isLoading = NO;
    
	if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_msgListView];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView != _msgListView) {
        return;
    }
    
    [self hideEverything];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView != _msgListView) {
        return;
    }
    
	if (_refreshHeaderView)
	{
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView != _msgListView) {
        return;
    }
    
	if (_refreshHeaderView)
	{
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}


#pragma mark -
#pragma mark EGORefreshTableDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
	[self beginToReloadData:aRefreshPos];
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
	
	return _isLoading; // should return if data source model is reloading
	
}

#pragma mark - private methods

- (void)loadMore:(NSUInteger)count containLastMsg:(BOOL)containLastMsg
{
    [GotyeAPI reqHistoryMessage:_targetUnit msgID:_lastMsgID count:count isInclude:containLastMsg];
}

- (void)applicationDidBecomActive:(NSNotification *)notification
{
    if (![GotyeAPI isOnline]) {
//        [_messageArray removeAllObjects];
    }
}

- (void)updateChateBG
{
//    _bgImageView.image = [GotyeSDKConfig sharedInstance].chatBG;
//    if ([GotyeSDKConfig sharedInstance].chatBG) {
//        UIImageView *bgView = [[UIImageView alloc]initWithImage:[GotyeSDKConfig sharedInstance].chatBG];
//        [_msgListView setBackgroundView:bgView];
//    } else {
//        [_msgListView setBackgroundView:nil];
//    }
}

- (void)exit
{
    if (_targetUnit.unitType == GotyeChatUnitTypeRoom) {
        [GotyeAPI leaveRoom:(GotyeRoom *)_targetUnit];
    }
    
//    [GotyeAPI removeListener:self];
}

- (void)enterRoom
{
    [[GotyeSDKUIControl sharedInstance]showHudInView:self.view animated:NO text:@"进入中..."];
    [GotyeAPI enterRoom:(GotyeRoom *)_targetUnit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)moveTextViewForKeyBoard:(NSNotification*)notify up:(BOOL)up
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
    
//    CGFloat yOffset = 0;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    if(!up)
        _keyboardOffset= 0;
    else
        _keyboardOffset = keyboardFrame.size.height;
    
    CGRect newFrame = _chatContentView.frame;
    newFrame.size.height = self.view.frame.size.height - (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? _topView.frame.size.height : 0) - _keyboardOffset;
    _chatContentView.frame = newFrame;

    if(animationDuration > 0)
    {
        [UIView commitAnimations];
    }
}


- (void)keyboardWillShow:(NSNotification*)notify
{
    
    if (!self.isViewLoaded || !self.view.window) {
        // viewController is invisible
        return;
    }
    
    [self hideEverythingButKeyboard];
    [self moveTextViewForKeyBoard:notify up:YES];
    [self listViewScrollToEnd:NO];
}

- (void)keyboardWillHide:(NSNotification*)notify
{
    [self moveTextViewForKeyBoard:notify up:NO];
}

- (void)keyboardDidHide:(NSNotification *)notify
{
}

- (void)resizeTextView:(CGFloat)newHeight
{
    //iPad设备中，如果系统版本小于7.0，输入框在第一次输入的时候会无法显示第一行字。
    //这是补丁。
    _textArea.frame = _textArea.frame;
    
    if (newHeight <= 0 || _textModeView.frame.origin.y < 0) {
        return;
    }
    
//    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newBottomFrame = _bottomView.frame;
        newBottomFrame.size.height = _initBottomHeight - _initTextHeight + newHeight;
        newBottomFrame.origin.y = _bottomView.superview.frame.size.height - newBottomFrame.size.height;
        _bottomView.frame = newBottomFrame;
        
        CGRect newTableViewFrame = _msgListView.frame;
        newTableViewFrame.size.height = _chatContentView.frame.size.height - _bottomView.frame.size.height;
        _msgListView.frame = newTableViewFrame;
    
        CGRect newFrame = _extraPanelView.frame;
        newFrame.origin.y = _bottomView.frame.origin.y - 15 - newFrame.size.height;
        _extraPanelView.frame = newFrame;
    
    [self listViewScrollToEnd:NO];
//    } completion:^(BOOL finished) {
//        if (finished) {
//        }
//    }];

}

- (void)showExtraPanel
{
    if (!_extraPanelView.hidden) {
        return;
    }
    
    [_showExtraBtn setSelected:YES];
    CGRect newFrame = _extraPanelView.frame;
    newFrame.origin.y = _bottomView.frame.origin.y - 10 - newFrame.size.height;
    _extraPanelView.frame = newFrame;
    
    _extraPanelView.hidden = NO;
    _extraPanelView.alpha = 0.0;
    
    [UIView animateWithDuration:0.15 animations:^{
        _extraPanelView.alpha = 1.0;
    } completion:nil];
}

- (void)hideExtraPanel
{
    if (_extraPanelView.hidden) {
        return;
    }
    
    [_showExtraBtn setSelected:NO];

    [UIView animateWithDuration:0.15 animations:^{
        _extraPanelView.alpha = 0;
    } completion:^(BOOL finished) {
        _extraPanelView.hidden = YES;
    }];
}

- (void)switchToTextMode:(BOOL)showKeyboard
{
    _isTextMode = YES;
    _textModeBtn.hidden = YES;
    _voiceModeBtn.hidden = NO;
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, _initBottomHeight);
    [UIView animateWithDuration:0.3 animations:^{
        _textModeView.transform = transform;
        _sendVoiceBtn.transform = transform;
    } completion:^(BOOL finished) {
        if (finished) {
            [self textViewDidChange:_textArea];
            //bug fix -- 在iPad中，如果系统版本低于7.0，UITextView长度过长会不显示文字
            if ([[[UIDevice currentDevice]systemVersion]floatValue] < 7.0) {
                _textArea.contentOffset = CGPointMake(0, 1);
                _textArea.contentOffset = CGPointMake(0, 0);
            }
            if (showKeyboard) {
                [_textArea becomeFirstResponder];
            }
        }
    }];

}

- (void)switchToVoiceMode
{
    _isTextMode = NO;
    _textModeBtn.hidden = NO;
    _voiceModeBtn.hidden = YES;
    
    [_textArea resignFirstResponder];
    [self hideEmoticonPanel];
    [self resizeTextView:_initTextHeight];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.3 animations:^{
        _textModeView.transform = transform;
        _sendVoiceBtn.transform = transform;
    } completion:nil];
}

- (void)showEmoticonPanel
{
//    if (![_textArea isFirstResponder] && _emoticonPanel && !_emoticonPanel.view.hidden) {
//        return;
//    }
    
    if(_emoticonPanel == nil)
    {
        _emoticonPanel = [[GotyeEmoticonPanel alloc] init];
        _emoticonPanel.textInput = _textArea;
        [self.view insertSubview:_emoticonPanel.view belowSubview:_topView];

        [_emoticonPanel.sendButton addTarget:self action:@selector(emoticonSendBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIView *emoticonView = _emoticonPanel.view;
    emoticonView.hidden = NO;

    emoticonView.frame = CGRectMake(_chatContentView.frame.origin.x, _chatContentView.frame.origin.y + _chatContentView.frame.size.height, _chatContentView.frame.size.width, emoticonView.frame.size.height);
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [_emoticonPanel changeToLandscapeMode];
    } else {
        [_emoticonPanel changeToPortraitMode];
    }
    
    if(!_isTextMode) {
        [self switchToTextMode:NO];
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGRect newFrame = _chatContentView.frame;
                         newFrame.size.height = self.view.frame.size.height - (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? _topView.frame.size.height : 0) - emoticonView.frame.size.height;
                         _chatContentView.frame = newFrame;
                         
                         newFrame = emoticonView.frame;
                         newFrame.origin.y = _chatContentView.frame.origin.y + _chatContentView.frame.size.height;
                         emoticonView.frame = newFrame;
                         
                         [self listViewScrollToEnd:NO];
                     }
                     completion:^(BOOL finished){
                         if (finished){
                         }
                     }
     ];
}

- (void)hideEmoticonPanel
{
    if (!_emoticonPanel || _emoticonPanel.view.hidden || !_emoticonPanel.view.superview) {
        return;
    }
    
    UIView *emoticonView = _emoticonPanel.view;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGRect newFrame = _chatContentView.frame;
                         newFrame.size.height = self.view.frame.size.height - (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? _topView.frame.size.height : 0);
                         _chatContentView.frame = newFrame;
                         
                         newFrame = emoticonView.frame;
                         newFrame.origin.y = _chatContentView.frame.origin.y + _chatContentView.frame.size.height;
                         emoticonView.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                         if (finished){
                             [emoticonView removeFromSuperview];
                             emoticonView.hidden = YES;
                             _emoticonPanel = nil;
                         }
                     }
     ];
}

- (void)adjustEmotiPanel:(UIInterfaceOrientation)orientation
{
    if (!_emoticonPanel || _emoticonPanel.view.hidden || !_emoticonPanel.view.superview) {
        return;
    }
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [_emoticonPanel changeToLandscapeMode];
    } else {
        [_emoticonPanel changeToPortraitMode];
    }
    
    UIView *emoticonView = _emoticonPanel.view;
    
    _emoticonPanel.pageControl.currentPage = 0;
    _emoticonPanel.emoticonView.contentOffset = CGPointZero;
    
    CGRect frame = _chatContentView.frame;
    frame.size.height = self.view.frame.size.height - (UIInterfaceOrientationIsPortrait(orientation) ? _topView.frame.size.height : 0) - emoticonView.frame.size.height;
    _chatContentView.frame = frame;
    
    frame = emoticonView.frame;
    frame.origin.x = _chatContentView.frame.origin.x;
    frame.origin.y = _chatContentView.frame.origin.y + _chatContentView.frame.size.height;
    frame.size.width = _chatContentView.frame.size.width;
    
    emoticonView.frame = frame;
}

#define SHAPE_HEIGHT (IS_IPAD ? 7 : 4)

- (void)showMorePanel
{
    _moreBtn.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        _morePanel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, _topView.frame.size.height - SHAPE_HEIGHT);
    }];
}

- (void)hideMorePanel
{
    _moreBtn.selected = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _morePanel.transform = CGAffineTransformIdentity;
    }];
}

- (void)hideEverything
{
    [self hidePopAction];
    [self hideExtraPanel];
    [self hideEmoticonPanel];
    [self hideMorePanel];
    [_textArea resignFirstResponder];
}

- (void)hideEverythingButKeyboard
{
    [self hidePopAction];
    [self hideExtraPanel];
    [self hideEmoticonPanel];
    [self hideMorePanel];
}

#pragma mark - Actions -

- (IBAction)moreBtnClicked:(id)sender
{
    UIButton *btn  = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self showMorePanel];
    } else {
        [self hideMorePanel];
    }
}

- (IBAction)exitBtnClicked:(id)sender
{    
    [[GotyeSDKUIControl sharedInstance]popViewControllerAnimated:YES];
}

- (IBAction)showUserListBtnClicked:(id)sender
{
    [self hideEverything];
    GotyeRoomUserListVC *roomUserListVC = [[GotyeRoomUserListVC alloc]initWithRoom:(GotyeRoom *)_targetUnit];
    [[GotyeSDKUIControl sharedInstance]pushViewController:roomUserListVC animated:YES];
}

- (IBAction)minimizeBtnClicked:(id)sender
{
    [[GotyeSDKUIControl sharedInstance]minimizeSDK];
}

- (IBAction)switchBtnClicked:(id)sender
{
    [self hideExtraPanel];
    if (_isTextMode) {
        [self switchToVoiceMode];
    } else {
        [self switchToTextMode:YES];
    }
}

- (IBAction)extraBtnClicked:(id)sender
{
    if (_extraPanelView.hidden) {
        [self showExtraPanel];
    } else {
        [self hideExtraPanel];
    }
}

- (IBAction)emotionBtnClicked:(id)sender
{
    [self hideExtraPanel];
    [_textArea resignFirstResponder];
    [self showEmoticonPanel];
}

- (IBAction)usePictureBtnClicked:(id)sender
{
    [self hideEverything];

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing = NO;
    
    if (IS_IPAD && IOS_VERSION_LESS_THAN_7_0) {
        _imagePopover = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
        [_imagePopover presentPopoverFromRect:CGRectMake(self.view.frame.size.width - 400, self.view.frame.size.height - _bottomView.frame.size.height - 450, 400.0, 400.0)
                                       inView:self.view
                     permittedArrowDirections:0
                                     animated:YES];
    } else {
        [self presentModalViewController:imagePicker animated:YES];
    }
    
}

- (IBAction)useCameraBtnClicked:(id)sender
{
    [self hideEverything];

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.delegate = self;
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        imagePicker.allowsEditing = NO;
        
        [self presentModalViewController:imagePicker animated:YES];
    } else {
        [[GotyeSDKUIControl sharedInstance]showAlertViewWithTitle:nil message:@"该设备不支持照相机！" delegate:nil];
    }
}

- (IBAction)sendVoiceBtnDown:(id)sender
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
        [GotyeAPI startTalkTo:_targetUnit whineMode:GotyeWhineModeDefault isRealTime:NO maxDuration:0];
        
        _speakingView.hidden = NO;
        [_speakingIndicator startAnimating];

        return;
    }
    
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            //                NSLog(@"permission : %d", granted);
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [GotyeAPI startTalkTo:_targetUnit whineMode:GotyeWhineModeDefault isRealTime:NO maxDuration:0];
                    
                    _speakingView.hidden = NO;
                    [_speakingIndicator startAnimating];
                });
            } else {
                NSString *appName =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];

                NSString *msg = [NSString stringWithFormat:@"请在%@的\"设置->隐私->麦克风\"选项中，允许%@访问你的手机麦克风", [UIDevice currentDevice].model, appName];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"无法录音" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

- (IBAction)sendVoiceBtnUp:(id)sender
{
    [GotyeAPI stopTalk];

    [_speakingIndicator stopAnimating];
    _speakingView.hidden = YES;
}

- (IBAction)cancelKeyboardBtnClicked:(id)sender
{
    [self hideEverything];
}

- (void)copyBtnClicked:(id)sender
{
    NSInteger tag = _actionIndex;
    DLog(@"copyBtnClicked: %d", tag);
    GotyeMessage *message = [self messageObjAtIndex:tag];
    if (message.type == GotyeMessageTypeText) {
        [UIPasteboard generalPasteboard].string = message.text;
    }
    
    [self hidePopAction];
}

- (void)prosecuteBtnClicked:(id)sender
{
    NSInteger tag = _actionIndex;
    DLog(@"prosecuteBtnClicked: %d", tag);
    [self hidePopAction];
    
    GotyeProsecuteVC *prosecuteView = [[GotyeProsecuteVC alloc]initWithMessage:[self messageObjAtIndex:tag]];
    [prosecuteView showInView:self.view];
}

- (void)avatarClicked:(id)sender
{
    DLog(@"avatar click %d", ((UIButton *)sender).tag);
    
    GotyeMessage *message = [self messageObjAtIndex:((UIView *)sender).tag];
    GotyeUserInfoVC *userInfo = [[GotyeUserInfoVC alloc]initWithUserAccount:message.sender.uniqueID];
    [userInfo showInView:self.view];
}

- (void)avatarDown:(id)sender
{
    [self hideEverything];
}

- (void)bubbleClicked:(id)sender
{
    [self hidePopAction];
    int tag = ((UIButton *)sender).tag;
    DLog(@"bubbleClicked click %d", tag);
    GotyeMessage *message = [self messageObjAtIndex:tag];
    switch (message.type) {
        case GotyeMessageTypeVoice:
            [self handleVoiceClick:message];
            break;
        case GotyeMessageTypeImage:
            [self handleImageClick:message];
            break;
        default:
            break;
    }
}

- (void)bubbleTouchDown:(id)sender
{
    [self hideEverything];
}

- (void)emoticonSendBtnClicked:(id)sender
{
    if (_textArea.text.length == 0) {
        return;
    }
    
    [self sendText:_textArea.text];
    [self hideEmoticonPanel];
}

- (void)refreshMessageList:(BOOL)scrollToEnd
{
    [_msgListView reloadData];
    if (scrollToEnd) {
        [self listViewScrollToEnd:NO];
    }
}

- (void)listViewScrollToEnd:(BOOL)animated
{
    if (_messageArray.count <= 0) {
        return;
    }
    
    [_msgListView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void)handleVoiceClick:(GotyeMessage *)message
{
    _lastClickVoice = message;
    NSString *voicePath = message.mediaObject.savedPath;
    if ([[NSFileManager defaultManager]fileExistsAtPath:voicePath]) {
        [self playOrStopVoice:message];
    } else {
        [self downloadVoice:message];
    }
}

- (void)handleImageClick:(GotyeMessage *)message
{
    for (UIView* subview in self.view.subviews) {
        if (subview.tag == kFullScreenImageTag) {
            return;
        }
        continue;
    }
    
    NSString *imgPath = message.mediaObject.savedPath;
    GotyeFullScreenImage *fullScreen;
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:imgPath]) {
        fullScreen = [[GotyeFullScreenImage alloc]initWithImage:[UIImage imageWithContentsOfFile:imgPath]];
    } else {
        fullScreen = [[GotyeFullScreenImage alloc]initWithThumb:[UIImage imageWithData:((GotyeImageObject *)message.mediaObject).thumbData] downloadURL:message.mediaObject.downloadURL downloadPath:message.mediaObject.savedPath];
    }
    
    fullScreen.view.tag = kFullScreenImageTag;
    [fullScreen showInView:self.view];
}

#define kCopyBtnTag         (100)
#define kProsecuteBtnTag    (200)
#define kDividerTag         (300)
#define kBgTag              (400)
#define kPopActionWidth     (131)
#define kPopActionHeight    (38)
#define kPopBtnHeight       (29)

- (void)handleSingleTap:(UITapGestureRecognizer *)tap
{
    DLog(@"single tap");
    [self hideEverything];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    DLog(@"long press %d state: %d", gestureRecognizer.view.tag, gestureRecognizer.state);
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    UIView *bubble = gestureRecognizer.view;
    GotyeMessage *message = [self messageObjAtIndex:bubble.tag];
    if ([message.sender.uniqueID isEqualToString:[GotyeSDKData sharedInstance].currentUser.uniqueID]
        && message.type != GotyeMessageTypeText) {
        return;
    }
    
    GotyeMessageBubbleCell *cell;
    UIView *temp = bubble.superview;
    while (![temp isKindOfClass:[GotyeMessageBubbleCell class]]) {
        temp = temp.superview;
    }
    cell = (GotyeMessageBubbleCell *)temp;
    
    [self decidePopContentAndFrameWithCell:cell atIndex:bubble.tag];
    _popActionView.tag = bubble.tag;
    _actionIndex = bubble.tag;
    
    [self showPopAction];
}

- (void)decidePopContentAndFrameWithCell:(GotyeMessageBubbleCell *)cell atIndex:(NSUInteger)index
{
    GotyeMessage *message = [self messageObjAtIndex:index];
    CGRect bubbleFrameInCell = cell.bubbleBtn.frame;

    if (bubbleFrameInCell.origin.y + cell.frame.origin.y - _msgListView.contentOffset.y < 50) { //反方向显示
        [_menuController setArrowDirection:UIMenuControllerArrowUp];
    } else {
        [_menuController setArrowDirection:UIMenuControllerArrowDown];
    }
    
    if ([message.sender.uniqueID isEqualToString:[GotyeSDKData sharedInstance].currentUser.uniqueID]) {
        _menuController.menuItems = @[_copyItem];
    } else if(message.type == GotyeMessageTypeText) {
        _menuController.menuItems = @[_copyItem, _prosecuteItem];
    } else {
        _menuController.menuItems = @[_prosecuteItem];
    }

    [_menuController setTargetRect:bubbleFrameInCell inView:cell];
}

- (void)showPopAction
{
    [_msgListView becomeFirstResponder];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)hidePopAction
{
    [_menuController setMenuVisible:NO animated:YES];
    _menuController.menuItems = nil;
}

- (void)playOrStopVoice:(GotyeMessage *)message
{
    if (message.type != GotyeMessageTypeVoice) {
        return;
    }
    
    NSString *newPath = message.mediaObject.savedPath;
    NSString *oldPath = [GotyeAPI currentPlayingFile];
    if ([newPath isEqualToString:oldPath]) {
        [GotyeAPI stopPlay];
    } else {
        [GotyeAPI startPlay:message.mediaObject.savedPath];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
    }
    
//    [self refreshMessageList:NO];
}

- (void)sensorStateChange:(NSNotification *)notification
{
    if ([[UIDevice currentDevice] proximityState] == YES) {
        DLog(@"Device is close to user");
        [GotyeAPI setUseSpeaker:NO];
    } else {
        DLog(@"Device is not close to user");
        [GotyeAPI setUseSpeaker:YES];
    }
}

- (void)downloadVoice:(GotyeMessage *)message
{
    
    if (message.type != GotyeMessageTypeVoice) {
        return;
    }
    
    NSString *downloadURL = message.mediaObject.downloadURL;
    
    if (downloadURL.length == 0) {
        return;
    }
    
    if ([_downloadingRes containsObject:downloadURL]) {
        return;
    }
    
    NSString *path = message.mediaObject.savedPath;
    
    GotyeVoiceCell *cell = (GotyeVoiceCell *)[_msgListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_messageArray indexOfObject:message] inSection:0]];
    [cell.progressIndicator startAnimating];
    
    [_downloadingRes addObject:downloadURL];
    [GotyeAPI downloadResWithURL:downloadURL saveTo:path];
}

- (BOOL)isDownloadingVoice:(GotyeMessage *)message
{
    return [_downloadingRes containsObject:message.mediaObject.downloadURL];
}

//- (void)stopAnimatingOfCurrentPlaying
//{
//    for (int index = 0; index < [_messageArray count]; ++index) {
//        GotyeMessage *message = _messageArray[index];
//        if(GotyeMessageTypeVoice == message.type && [message.mediaObject.savedPath isEqualToString:_player.filePath])
//        {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//            GotyeVoiceCell *cell = (GotyeVoiceCell *)[_msgListView cellForRowAtIndexPath:indexPath];
//            if(cell != nil)
//            {
//                [cell stopAnimating];
//            }
//            break;
//        }
//    }
//}

- (void)configureCell:(GotyeMessageBubbleCell *)cell atRow:(int)row;
{
    if (row < 0 || row >= _messageArray.count) {
        return;
    }
    
    GotyeChatMessageItem *chatMessageItem = _messageArray[row];
    GotyeMessage *msgObj = chatMessageItem.msgObj;
    
    if (msgObj == nil || cell == nil) {
        return;
    }
    
    NSString *accountName = msgObj.sender.uniqueID;
    GotyeSDKUserInfo *sender = [[GotyeSDKData sharedInstance]getUserWithAccount:accountName];
    
    if (sender == nil) {
        sender = [[GotyeSDKUserInfo alloc]initWithUniqueID:accountName];
    }
    
    UIImage *avatar = sender.userAvatar;
    
    if (avatar == nil) {
        avatar = [[GotyeImageManager sharedImageManager]getImageWithPath:sender.avatarURL];
        if (avatar == nil) {
            avatar = [GotyeSDKResource getDefaultAvatar];
        }
    }

    cell.backgroundColor = [UIColor clearColor];
    UIImage *maskedAvatar = [avatar maskWithImage:[GotyeSDKResource getAvatarMask]];
    [cell.avatarBtn setBackgroundImage:maskedAvatar forState:UIControlStateNormal];
    cell.avatarBtn.tag = row;
    [cell.avatarBtn addTarget:self action:@selector(avatarClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.avatarBtn addTarget:self action:@selector(avatarDown:) forControlEvents:UIControlEventTouchDown];
    
    cell.nameLabel.text = sender.name;
    
    cell.bubbleBtn.tag = row;
    [cell.bubbleBtn addTarget:self action:@selector(bubbleClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.bubbleBtn addTarget:self action:@selector(bubbleTouchDown:) forControlEvents:UIControlEventTouchDown];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.numberOfTouchesRequired = 1;
    [cell.bubbleBtn addGestureRecognizer:lpgr];
    
    if ([accountName isEqualToString:[GotyeSDKData sharedInstance].currentUser.uniqueID]) {
        cell.direction = GotyeMessageBubbleDirectionRight;
    } else {
        cell.direction = GotyeMessageBubbleDirectionLeft;
    }
    
    if (chatMessageItem.needToShowTime) {
        cell.timeButton.hidden = NO;
        NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:msgObj.date];
        NSString *dateFormat;
        NSInteger days = [GotyeTimeUtil dayIntervalBetween:[NSDate date] andDate:msgDate];
        switch (days) {
            case 0: //今天
                dateFormat = @"HH:mm";
                break;
            case 1: //昨天
                dateFormat = @"昨天 HH:mm";
                break;
            case 2:
                dateFormat = @"前天 HH:mm";
                break;
            default:
                dateFormat = @"yyyy年MM月dd日 HH:mm";
                break;
        }
        
        [cell.timeButton setTitle:[GotyeTimeUtil stringFromDate:msgDate format:dateFormat] forState:UIControlStateNormal];

    } else {
        cell.timeButton.hidden = YES;
    }
    
    cell.msgState = chatMessageItem.state;
    cell.msgType = msgObj.type;
    
    switch (msgObj.type) {
        case GotyeMessageTypeText:
        {
            GotyeTextCell *textCell = (GotyeTextCell *)cell;
            textCell.emotionLabel.textColor = (cell.direction == GotyeMessageBubbleDirectionLeft ? [[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorBubbleLeft] : [[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorBubbleRight]);
            
            //缓存已格式化的字符串
            if (chatMessageItem.formattedText) {
                textCell.emotionLabel.attributedString = chatMessageItem.formattedText;
            } else {
                textCell.emotionLabel.text = msgObj.text;
                chatMessageItem.formattedText = textCell.emotionLabel.attributedString;
            }
            
            //缓存计算好的大小
            if (CGSizeEqualToSize(chatMessageItem.textSize, CGSizeZero)) {
                [textCell.emotionLabel sizeToFit];
                chatMessageItem.textSize = textCell.emotionLabel.frame.size;
            } else {
                CGRect newFrame = textCell.emotionLabel.frame;
                newFrame.size = chatMessageItem.textSize;
                textCell.emotionLabel.frame = newFrame;
            }
        }
            break;
        case GotyeMessageTypeImage:
        {
            UIImage *image = [UIImage imageWithData:((GotyeImageObject *)msgObj.mediaObject).thumbData];
            ((GotyeImageCell *)cell).imageContent = image;
        }
            break;
        case GotyeMessageTypeVoice:
        {
            GotyeVoiceCell *voiceCell = ((GotyeVoiceCell *)cell);
            voiceCell.duration = ((GotyeVoiceObject *)(msgObj.mediaObject)).duration;
           
            if ([[GotyeAPI currentPlayingFile] isEqualToString:msgObj.mediaObject.savedPath]) {
                [voiceCell startAnimating];
            } else {
                [voiceCell stopAnimating];
                
                if ([self isDownloadingVoice:msgObj]) {
                    [cell.progressIndicator startAnimating];
                    cell.errorState.hidden = YES;
                } else {
                    [cell.progressIndicator stopAnimating];
                    cell.errorState.hidden = [[NSFileManager defaultManager]fileExistsAtPath:msgObj.mediaObject.savedPath];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)sendMessage:(GotyeMessage *)message
{
    [self addMessage:message isToSend:YES];
    [GotyeAPI sendMessage:message];
}
- (void)sendText:(NSString *)text
{
    GotyeMessage *textMsg = [GotyeMessage createTextMessageWithText:text sender:[GotyeSDKData sharedInstance].currentUser receiver:_targetUnit];
    [self sendMessage:textMsg];
    
    [_textArea setText:@""];
    [self textViewDidChange:_textArea];
}

- (void)sendImage:(UIImage *)image
{
    NSString *path = [[GotyeFileUtil getCacheDir]stringByAppendingPathComponent:[NSString stringWithFormat:@"%f", [[NSDate date]timeIntervalSince1970]]];
    GotyeMessage *imageMsg = [GotyeMessage createImageMessageWithImage:image savedTo:path sender:[GotyeSDKData sharedInstance].currentUser receiver:_targetUnit];

    [self sendMessage:imageMsg];

}

- (void)addMessage:(GotyeMessage *)message isToSend:(BOOL)isToSend
{
    [self hidePopAction];
    GotyeChatMessageItem *chatMessageItem = [[GotyeChatMessageItem alloc]init];
    chatMessageItem.msgObj = message;
    chatMessageItem.needToShowTime = (_messageArray.count == 0 || (message.date - [self messageObjAtIndex:_messageArray.count - 1].date) >= 5 * 60);
    if (isToSend) {
        chatMessageItem.state = GotyeChatMessageStateSending;
        [_sendMsgMap setObject:chatMessageItem forKey:message.uuid];
    } else {
        chatMessageItem.state = GotyeChatMessageStateReceived;
    }
    
    [_messageArray addObject:chatMessageItem];
    
    [self refreshMessageList:YES];
}

- (void)resetTimeShowing:(NSArray *)msgArray
{
    for (int index = 0; index < msgArray.count; ++index) {
        GotyeChatMessageItem *item = msgArray[index];
        if (index == 0) {
            item.needToShowTime = YES;
        } else {
            item.needToShowTime = (item.msgObj.date - [(GotyeChatMessageItem *)msgArray[index - 1]msgObj].date) >= 5 * 60;
        };
    }
}

- (GotyeMessage *)messageObjAtIndex:(NSInteger)index
{
    return ((GotyeChatMessageItem *)_messageArray[index]).msgObj;
}

- (void)showVoiceError:(NSString *)error
{
    [_speakingIndicator stopAnimating];
    _speakingView.hidden = YES;
    
    _voiceTooShortView.hidden = NO;
    _voiceError.text = error;
    
    double delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _voiceTooShortView.hidden = YES;
    });
}
#pragma mark - table view data source -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GotyeMessageType msgType = [self messageObjAtIndex:indexPath.row].type;
    
    static NSString *cellIdentifier;
    switch (msgType) {
        case GotyeMessageTypeText:
            cellIdentifier = @"GotyeTextCell";
            break;
        case GotyeMessageTypeImage:
            cellIdentifier = @"GotyeImageCell";
            break;
        case GotyeMessageTypeVoice:
            cellIdentifier = @"GotyeVoiceCell";
            break;
        default:
            cellIdentifier = @"";
            break;
    }
    
    GotyeMessageBubbleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [GotyeMessageBubbleCell cellWithType:msgType reuseIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atRow:indexPath.row];
    
    //ios 7中，点击事件会被srollview拦截造成延迟
    if (msgType != GotyeMessageTypeText) {
        for (id obj in cell.subviews)
        {
            if ([NSStringFromClass([obj class]) isEqualToString:@"UITableViewCellScrollView"])
            {
                UIScrollView *scroll = (UIScrollView *) obj;
                scroll.delaysContentTouches = NO;
                break;
            }
        }
    }
    
    return cell;
}

#pragma mark - table view delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

//当加载tableview时，需要预先计算所有的cell的高度，如果存在许多cell时，会有性能问题。
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GotyeMessage *msg = [self messageObjAtIndex:indexPath.row];
    NSString *heightKey = msg.uuid;
    NSNumber *cache = [_cachedCellHeight objectForKey:heightKey];
    if (cache) {
        return [cache intValue];
    }
    
    NSInteger height;
    GotyeMessageType msgType = msg.type;
    NSNumber *key = @(msgType);
    //这里直接重新创建一个cell而不是从tablview中取，在计算出高度后才能及时释放cell的内存。
    GotyeMessageBubbleCell *cell = [_cachedCellsForCalculatingHeight objectForKey:key];
    @autoreleasepool {
        if (!cell) {
            cell = [GotyeMessageBubbleCell cellWithType:msgType reuseIdentifier:nil];
            [_cachedCellsForCalculatingHeight setObject:cell forKey:key];
        }
        
        [self configureCell:cell atRow:indexPath.row];
        height = cell.cellHeight;
        cell = nil;
    }

    [_cachedCellHeight setObject:@(height) forKey:heightKey];
    
    return height;
}

//ios 7后支持预估cell的高度，这样就在需要显示时才真正计算高度，降低加载时间
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return kBubbleMinHeight + kItemMargin * 2;
//}

#pragma mark - text view delegate -

- (void)textViewDidBeginEditing:(UITextView *)textView
{
//    _textAreaBg.image = _bgOfTextAreaFocused;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
//    _textAreaBg.image = _bgOfTextAreaLostFocus;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        if (textView.text.length == 0) {
            return NO;
        }
        
        [self sendText:textView.text];
        [_textArea resignFirstResponder];
        
        return NO;
    }
    
    if (textView.text.length > 256) {
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (IOS_VERSION_LESS_THAN_7_0) {
        int numberOfLines = round(textView.contentSize.height/textView.font.lineHeight);
        if (numberOfLines < _maxTextLines) {
            textView.scrollEnabled = NO;
        } else {
            textView.scrollEnabled = YES;
        }
    } else {
        //ios 7又一bug,输入多行文字时，最后一行有可能会显示不完全
        CGRect line = [textView caretRectForPosition:
                       textView.selectedTextRange.start];
        CGFloat overflow = line.origin.y + line.size.height
        - ( textView.contentOffset.y + textView.bounds.size.height
           - textView.contentInset.bottom - textView.contentInset.top );
        if ( overflow > 0 ) {
            // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
            // Scroll caret to visible area
            CGPoint offset = textView.contentOffset;
            offset.y += overflow + 7; // leave 7 pixels margin
            // Cannot animate with setContentOffset:animated: or caret will not appear
//            [UIView animateWithDuration:.2 animations:^{
                [textView setContentOffset:offset];
//            }];
        }
    }
    
    CGFloat fixedWidth = _textArea.frame.size.width;
    
    CGSize newSize = [_textArea sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGFloat newHeight;
    if (floor(newSize.height / textView.font.lineHeight) <= 1) {
        newHeight = _initTextHeight;
    } else {
        newHeight = ceilf(fminf(newSize.height, _maxTextHeight));
    }
    
    [self resizeTextView:newHeight];
}

#pragma mark - image picker delegate -

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (IS_IPAD && IOS_VERSION_LESS_THAN_7_0) {
        [_imagePopover dismissPopoverAnimated:YES];
    } else {
        [picker dismissModalViewControllerAnimated:YES];
    }
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self sendImage:image];
}


#pragma mark - navigation delegate -

//解决iOS 7中进入相册会出现状态栏的bug
//又是坑爹的
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

//#pragma mark - alert view delegate -
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 0) {
//        [self exitBtnClicked:nil];
//    }
//}

#pragma mark - chat delegate -

- (void)onSendMessage:(GotyeMessage *)message result:(GotyeStatusCode)code
{
    GotyeChatMessageItem *msgItem = _sendMsgMap[message.uuid];
    [_sendMsgMap removeObjectForKey:message.uuid];
    
    DLog(@"onsend: %d\n%@", code, [message debugDescription]);
    //发送成功，缓存已发送的语音或图片，这样就无需再去下载

    switch (code) {
        case GotyeStatusCodeOK:
        {
            msgItem.state = GotyeStatusCodeOK;
            
            if (message.type == GotyeMessageTypeImage || message.type == GotyeMessageTypeVoice) {
                NSString *rename = [GotyeFileUtil resPathForURL:message.mediaObject.downloadURL];
                NSError *err = nil;
                [[NSFileManager defaultManager]moveItemAtPath:message.mediaObject.savedPath toPath:rename error:&err];
                if (err == nil) {
                    DLog(@"重命名成功");
                    message.mediaObject.savedPath = rename;
                }
            }
            
            break;
        }
        case GotyeStatusCodeForbidden:
        {
            //需要重新计算高度
            [_cachedCellHeight removeObjectForKey:msgItem.msgObj.uuid];
            msgItem.state = GotyeChatMessageStateForbidden;
            
            [self refreshMessageList:YES];
            break;
        }
        default:
            msgItem.state = GotyeChatMessageStateSendFailed;
            break;
    }
}

/**
 * 收到消息时的回调
 * @param message 收到的消息的引用
 */
- (void)onReceiveMessage:(GotyeMessage *)message
{
    DLog(@"onReceiveMessage %@", [message debugDescription]);
    if (message.type == GotyeMessageTypeVoice || message.type == GotyeMessageTypeImage) {
        message.mediaObject.savedPath = [GotyeFileUtil resPathForURL:message.mediaObject.downloadURL];
    }
    
    [self addMessage:message isToSend:NO];
}

- (void)onReceiveVoiceMessageFrom:(GotyeChatUnit *)sender to:(GotyeChatUnit *)receiver
{
    
}

- (void)onGetHistoryMessages:(NSArray *)msgList before:(NSString *)msgID target:(GotyeChatUnit *)target isInclude:(BOOL)isInclude result:(GotyeStatusCode)status
{
    DLog(@"获取历史消息: %d", msgList.count);
//    [self finishLoadingData];

    if (status != GotyeStatusCodeOK) {
        DLog(@"状态不对：%@", [GotyeStatusMessage statusMessage:status]);
        [self finishLoadingData];
        return;
    }
    
    if (msgID != _lastMsgID) {
        DLog(@"msgID不一致");
        [self finishLoadingData];
        return;
    }
    
    if (target != _targetUnit) {
        DLog(@"拉取目标不一致");
        [self finishLoadingData];
        return;
    }
    
    if (msgList.count == 0) {
        [self finishLoadingData];
        return;
    }
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc]init];
    NSUInteger row = 0;
    for (GotyeMessage *msg in msgList) {
        if (msg.type == GotyeMessageTypeVoice || msg.type == GotyeMessageTypeImage) {
            msg.mediaObject.savedPath = [GotyeFileUtil resPathForURL:msg.mediaObject.downloadURL];
        }
        
        GotyeChatMessageItem *item = [[GotyeChatMessageItem alloc]init];
        item.msgObj = msg;
        item.state = GotyeChatMessageStateReceived;
        [_messageArray insertObject:item atIndex:0];
        [indexPaths addObject:[NSIndexPath indexPathForRow:row++ inSection:0]];
    }
    
    _lastMsgID = [[msgList lastObject]messageID];
    
    [self resetTimeShowing:[_messageArray subarrayWithRange:NSMakeRange(0, msgList.count)]];

    if (_messageArray.count == msgList.count) {
        [self refreshMessageList:YES];
    } else {
        CGFloat distanceToBottom = _msgListView.contentSize.height + _msgListView.contentInset.top;
        [self refreshMessageList:NO];
        [_msgListView setContentOffset:CGPointMake(0, _msgListView.contentSize.height - distanceToBottom) animated:NO];
    }
    
    [self finishLoadingData];
}

#pragma mark - recorder delegate -

- (void)onStartTalkTo:(GotyeChatUnit *)target whineMode:(GotyeWhineMode)mode isRealTime:(BOOL)isRealTime
{
    DLog(@"onRecordStart");
}

- (void)onStopTalkTo:(GotyeChatUnit *)target whineMode:(GotyeWhineMode)mode isRealTime:(BOOL)isRealTime filePath:(NSString *)filePath duration:(long)recordedDuration status:(GotyeStatusCode)status
{
    if (status != GotyeStatusCodeOK) {
        if (status != GotyeStatusCodeVoiceTimeOver) {
            [self showVoiceError:@"录音错误"];
            return;
        }
        
        [self showVoiceError:@"说话时间太长"];
    }
    
    //少于1秒不发送
    if (recordedDuration >= 1000) {
        GotyeMessage *voiceMessage =  [GotyeMessage createVoiceMessageWith:filePath duration:recordedDuration sender:[GotyeSDKData sharedInstance].currentUser receiver:_targetUnit];
        
        [self sendMessage:voiceMessage];
    } else if (status == GotyeStatusCodeOK){
        [self showVoiceError:@"说话时间太短"];
    }
}

#pragma mark - player delegate -

/**
 * 播放开始的回调
 */
- (void)onStartPlay:(NSString *)filePath
{
    DLog(@"onPlayStart");
    [self refreshMessageList:NO];
}

/**
 * 播放中的回调
 *
 */
- (void)onPlaying:(NSString *)filePath position:(long)position
{
    
}

/**
 * 播放结束的回调
 */
- (void)onStopPlay:(NSString *)filePath status:(GotyeStatusCode)status
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [GotyeAPI setUseSpeaker:YES];
    
    DLog(@"onPlayStop:%@", [GotyeStatusMessage statusMessage:status]);
    [self refreshMessageList:NO];
}

#pragma mark - room delegate -

- (void)onEnterRoom:(GotyeRoom *)room lastMsgID:(NSString *)lastMsgID result:(GotyeStatusCode)status
{
    DLog(@"onEnterRoom:%@ lastMsgID:%@ result: %d", room.uniqueID, lastMsgID, status);
    
    [[GotyeSDKUIControl sharedInstance]hideHudInView:self.view animated:NO];
    
    if (status != GotyeStatusCodeOK && status != GotyeStatusCodeTimeout) {
        [[GotyeSDKUIControl sharedInstance]showAlertViewWithTitle:nil message:[GotyeStatusMessage statusMessage:status] delegate:self];
        return;
    }
    
    _lastMsgID = lastMsgID;
    [_messageArray removeAllObjects];
    [self refreshMessageList:NO];
    
    [_refreshHeaderView setState:EGOOPullRefreshLoading];
    [self loadMore:5 containLastMsg:YES];
}

- (void)onLeaveRoom:(GotyeRoom *)room result:(GotyeStatusCode)status
{
    
}

#pragma mark - user delegate -

- (void)onGetUserInfo:(GotyeUser *)user result:(GotyeStatusCode)status
{
    if (status != GotyeStatusCodeOK) {
        return;
    }
    
    [self refreshMessageList:NO];
}

#pragma mark downlaod delegate -

- (void)onDownloadRes:(NSString *)downloadURL path:(NSString *)savedPath result:(GotyeStatusCode)status
{
    if ([_lastClickVoice.mediaObject.downloadURL isEqualToString:downloadURL]) {
        [self playOrStopVoice:_lastClickVoice];
    }
    
    [_downloadingRes removeObject:downloadURL];
    
    if (status != GotyeStatusCodeOK) {
        return;
    }
    
    [self refreshMessageList:NO];
}

#pragma mark - login delegate -

- (void)onLoginResp:(GotyeStatusCode)statusCode account:(NSString *)account appKey:(NSString *)appKey
{
    if (statusCode != GotyeStatusCodeOK) {
        return;
    }
    
    [self enterRoom];
}

- (void)onLogout:(GotyeStatusCode)error account:(NSString *)account appKey:(NSString *)appKey
{
    if (error == GotyeStatusCodeOK) {
        return;
    }
    
    [self exit];
}

#pragma mark - gesture deleget - 

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint position = [touch locationInView:self.view];
    if (position.x >= _textModeBtn.frame.origin.x + _textModeBtn.contentEdgeInsets.left) {
        return NO;
    }
    
    return YES;
}

#pragma mark - table view touch delegate - 

- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    DLog(@"tableview touch began");
    [self hideEverything];
}

@end
