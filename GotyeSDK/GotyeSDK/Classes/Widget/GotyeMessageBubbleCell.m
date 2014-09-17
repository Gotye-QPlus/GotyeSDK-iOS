//
//  GotyeMessageBubbleCell.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-14.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeMessageBubbleCell.h"
#import "GotyeSDKResource.h"
#import "GotyeMessage.h"
#import "GotyeSDKData.h"
#import "GotyeImageManager.h"
#import "GotyeEmotionLabel.h"
#import "GotyeImageManager.h"
#import "GotyeTextCell.h"
#import "GotyeImageCell.h"
#import "GotyeVoiceCell.h"
#import "GotyeSDKConstants.h"
#import "UIColor+HTML.h"
#import "GotyeSDkSkin.h"

#define GOTYE_ITEM_MIN_HEIGHT ((_nameLabel.hidden ? bubbleHeight : MAX(bubbleHeight, kHeadImgSize + kAvatarNameOffset + kNameTextHeight)))

@interface GotyeMessageBubbleCell()
{
    UIView *_forbiddenView;
}
@end

@implementation GotyeMessageBubbleCell

+ (GotyeMessageBubbleCell *)cellWithType:(GotyeMessageType)type reuseIdentifier:(NSString *)reuseIdentifier
{
    switch (type) {
        case GotyeMessageTypeText:
            return [[GotyeTextCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        case GotyeMessageTypeImage:
            return [[GotyeImageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        case GotyeMessageTypeVoice:
            return [[GotyeVoiceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        default:
            break;
    }
        
    return nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        _timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _timeButton.hidden = YES;
//        _timeButton.titleLabel.font = kTimeTextFont;
//        [_timeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        _timeButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
//        
//        UIImage *timeBG = [[[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"chat_time_bg" ofType:@"png"]]stretchableImageWithLeftCapWidth:19 topCapHeight:8];
//        [_timeButton setBackgroundImage:timeBG forState:UIControlStateNormal];
//        [self.contentView addSubview:_timeButton];
//        
//        _avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.contentView addSubview:_avatarBtn];
//        
//        _nameLabel = [[UILabel alloc]init];
//        _nameLabel.numberOfLines = 1;
//        _nameLabel.font = [UIFont systemFontOfSize:kNameTextSize];
//        _nameLabel.textAlignment = UITextAlignmentCenter;
//        
//        [self.contentView addSubview:_nameLabel];
//
//        _bubbleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.contentView addSubview:_bubbleBtn];
//        
//        _progressIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        [self.contentView addSubview:_progressIndicator];
        
//        _errorState = [UIImageView alloc];
//        UIImage *image = [[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"error" ofType:@"png"] completion:nil];
////        _errorState.image = image;
//        _errorState.hidden = YES;
//        [self.contentView addSubview:_errorState];
        
    }
    
    return self;
}

#define LEFT_BUBBLE_LeftCapWidth (IS_IPAD ? 50 : 25)
#define LEFT_BUBBLE_TopCapHeight (IS_IPAD ? 40 : 30)

#define RIGHT_BUBBLE_LeftCapWidth (IS_IPAD ? 50 : 25)
#define RIGHT_BUBBLE_TopCapHeight (IS_IPAD ? 40 : 30)

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    
    [self.contentView addSubview:self.timeButton];
    [self.contentView addSubview:self.avatarBtn];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.bubbleBtn];
    [self.contentView addSubview:self.progressIndicator];
    
    [self.bubbleBtn addSubview:[self bubbleContentView]];
    
    NSUInteger bubbleContentWidth = [self bubbleContentWidth];
    NSUInteger bubbleContentHeight = [self bubbleContentHeight];
    
    NSUInteger bubbleWidth = MAX(bubbleContentWidth + kBubbleCommaLenth + [self bubbleInsetHorizontal] * 2, kBubbleMinWidth);
    NSUInteger bubbleHeight = MAX(bubbleContentHeight + [self bubbleInsetVertical] * 2, kBubbleMinHeight);

//    CGRect newFrame = self.frame;
//    newFrame.size.height = [self cellHeight];
//    self.frame = newFrame;
    
    NSInteger headXOffset, nameXOffset, bubbleXOffset, bubbleContentXOffset, indicatorXOffset;
    UIImage *bubbleBG;
    
    switch (_direction) {
        case GotyeMessageBubbleDirectionLeft:
            headXOffset = kCellInset;
            nameXOffset = kCellInset - (kMaxNameLength - kHeadImgSize) / 2;
            bubbleXOffset = headXOffset + kHeadImgSize + kMarginBetweenHeadAndBubble;
            bubbleBG = [[[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"chat_bubble_left" ofType:@"png"]]stretchableImageWithLeftCapWidth:LEFT_BUBBLE_LeftCapWidth topCapHeight:LEFT_BUBBLE_TopCapHeight];
            bubbleContentXOffset = kBubbleCommaLenth + (bubbleWidth - kBubbleCommaLenth - [self bubbleContentWidth]) / 2;
            indicatorXOffset = bubbleXOffset + bubbleWidth + 5;

            break;
        case GotyeMessageBubbleDirectionRight:
            headXOffset = self.frame.size.width - kCellInset - kHeadImgSize;
            nameXOffset = self.frame.size.width - (kCellInset - (kMaxNameLength - kHeadImgSize) / 2) - kMaxNameLength;
            bubbleXOffset = headXOffset - kMarginBetweenHeadAndBubble - bubbleWidth;
            bubbleBG = [[[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"chat_bubble_right" ofType:@"png"]]stretchableImageWithLeftCapWidth:RIGHT_BUBBLE_LeftCapWidth topCapHeight:RIGHT_BUBBLE_TopCapHeight];
            bubbleContentXOffset = (bubbleWidth - kBubbleCommaLenth - [self bubbleContentWidth]) / 2;
            indicatorXOffset = bubbleXOffset - 5 - _progressIndicator.frame.size.width;
            break;
        default:
            return;
    }
    
    NSInteger timeHeight = 0;
    if (!_timeButton.hidden) {
        [_timeButton sizeToFit];
        _timeButton.frame = CGRectMake((self.frame.size.width - _timeButton.frame.size.width) / 2, kItemMargin, MAX(kTimeMinWidth, _timeButton.frame.size.width), kTimeTextHeight);
        timeHeight = _timeButton.frame.size.height + kItemMargin * 2;

    }
    
    _avatarBtn.frame = CGRectMake(headXOffset, kItemMargin + timeHeight, kHeadImgSize, kHeadImgSize);
    _nameLabel.frame = CGRectMake(nameXOffset, _avatarBtn.frame.origin.y + _avatarBtn.frame.size.height + kAvatarNameOffset, kMaxNameLength, kNameTextHeight);
    _bubbleBtn.frame = CGRectMake(bubbleXOffset, _avatarBtn.frame.origin.y, bubbleWidth, bubbleHeight);
    [_bubbleBtn setBackgroundImage:bubbleBG forState:UIControlStateNormal];
    
    [self bubbleContentView].frame = CGRectMake(ceil(bubbleContentXOffset), ceilf((float)((bubbleHeight - [self bubbleContentHeight])) / 2.0f), [self bubbleContentWidth], [self bubbleContentHeight]);
    CGRect bubbleFrame = _bubbleBtn.frame;
    _progressIndicator.frame = CGRectMake(indicatorXOffset, bubbleFrame.origin.y + (bubbleFrame.size.height - _progressIndicator.frame.size.height) / 2, _progressIndicator.frame.size.width, _progressIndicator.frame.size.height);
    _errorState.frame = _progressIndicator.frame;
    
    if (_forbiddenView != nil && _forbiddenView.hidden == NO) {
        _forbiddenView.frame = CGRectMake((self.frame.size.width - _forbiddenView.frame.size.width) / 2, _bubbleBtn.frame.origin.y + GOTYE_ITEM_MIN_HEIGHT + kItemMargin, MAX(kTimeMinWidth, _forbiddenView.frame.size.width), kTimeTextHeight);
    }
}

#define STATUS_LABEL_INSET (IS_IPAD ? 20 : 10)

- (void)setMsgState:(GotyeChatMessageState)msgState
{
    _msgState = msgState;
    
    switch (_msgState) {
        case GotyeChatMessageStateForbidden:
            if (_forbiddenView == nil) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.titleLabel.font = [UIFont systemFontOfSize:kTimeTextFont];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                button.contentEdgeInsets = UIEdgeInsetsMake(0, STATUS_LABEL_INSET, 0, STATUS_LABEL_INSET);
                [button setTitle:GOTYE_FORBIDDEN_TEXT forState:UIControlStateNormal];
                UIImage *buttonBG = [[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"chat_time_bg" ofType:@"png"]];
                buttonBG = [buttonBG stretchableImageWithLeftCapWidth:buttonBG.size.width / 2 topCapHeight:buttonBG.size.height / 2];
                [button setBackgroundImage:buttonBG forState:UIControlStateNormal];
                [button sizeToFit];
                
                _forbiddenView = button;
                [self.contentView addSubview:_forbiddenView];
            } else {
                _forbiddenView.hidden = NO;
            }

            break;
        default:
            [_forbiddenView removeFromSuperview];
            _forbiddenView = nil;
            break;
    }

}

- (UIView *)bubbleContentView
{
    return nil;
}

- (NSUInteger)bubbleContentWidth
{
    return kBubbleMinWidth - kBubbleCommaLenth - [self bubbleInsetHorizontal] * 2;
}

- (NSUInteger)bubbleContentHeight
{
    return kBubbleMinHeight - [self bubbleInsetVertical] * 2;
}

- (NSUInteger)bubbleInsetHorizontal
{
    return (IS_IPAD ? 8 : 5);
}

- (NSUInteger)bubbleInsetVertical
{
    return (IS_IPAD ? 8 : 5);
}

- (UIButton *)avatarBtn
{
    if (!_avatarBtn) {
        _avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    
    return _avatarBtn;
}

- (UIButton *)timeButton
{
    if (!_timeButton) {
        _timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _timeButton.hidden = YES;
        _timeButton.userInteractionEnabled = NO;
        _timeButton.titleLabel.font = [UIFont systemFontOfSize:kTimeTextFont];
        [_timeButton setTitleColor:[UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorTime]] forState:UIControlStateNormal];
        _timeButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        
//        UIImage *timeBG = [[[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"chat_time_bg" ofType:@"png"]]stretchableImageWithLeftCapWidth:19 topCapHeight:8];
//        [_timeButton setBackgroundImage:timeBG forState:UIControlStateNormal];
    }
    
    return _timeButton;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.numberOfLines = 1;
        _nameLabel.font = [UIFont systemFontOfSize:kNameTextSize];
        _nameLabel.textAlignment = UITextAlignmentCenter;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorChatName]];
    }
    
    return _nameLabel;
}

- (UIButton *)bubbleBtn
{
    if (!_bubbleBtn) {
        _bubbleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    
    return _bubbleBtn;
}

- (UIActivityIndicatorView *)progressIndicator
{
    if (!_progressIndicator) {
        _progressIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _progressIndicator;
}

- (NSUInteger)cellHeight
{
    NSUInteger bubbleHeight = MAX([self bubbleContentHeight] + [self bubbleInsetVertical] * 2, kBubbleMinHeight);
    return GOTYE_ITEM_MIN_HEIGHT + kItemMargin * 2 + (self.timeButton.hidden ? 0 : kTimeTextHeight + kItemMargin * 2) + (_forbiddenView != nil && _forbiddenView.hidden == NO ? kTimeTextHeight + kItemMargin : 0);
}

@end
