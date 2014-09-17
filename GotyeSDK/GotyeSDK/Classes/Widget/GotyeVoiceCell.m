//
//  GotyeVoiceCell.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-15.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeVoiceCell.h"
#import "GotyeImageManager.h"
#import "GotyeSDKResource.h"
#import "UIColor+HTML.h"
#import "GotyeSDkSkin.h"

@interface GotyeVoiceCell()
{
    UIImageView *_voiceIcon;
    UILabel *_durationLabel;
    UIView *_voiceContentView;
}
@end

@implementation GotyeVoiceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        _voiceContentView = [[UIView alloc]init];
//
//        _voiceIcon = [[UIImageView alloc]init];
//        _voiceIcon.animationDuration = 1.0f;
//        _voiceIcon.contentMode = UIViewContentModeScaleAspectFit;
//        [_voiceContentView addSubview:_voiceIcon];
//
//        _durationLabel = [[UILabel alloc]init];
//        _durationLabel.font = [UIFont systemFontOfSize:kChatTextSize];
//        _durationLabel.backgroundColor = [UIColor clearColor];
//
//        [_voiceContentView addSubview:_durationLabel];
//        _voiceContentView.userInteractionEnabled = NO;
//        
//        [self.bubbleBtn addSubview:_voiceContentView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    

    [[self voiceContentView]addSubview:[self voiceIcon]];
    [[self voiceContentView] addSubview:[self durationLabel]];
    [[self durationLabel] sizeToFit];
    if (self.direction == GotyeMessageBubbleDirectionRight) {
        [self durationLabel].textColor = [UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorBubbleDurationRight]];
    } else {
        [self durationLabel].textColor = [UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorBubbleDurationLeft]];
    }

    NSInteger iconXOffset, labelXOffset;
    NSString *voiceIconImg;
    NSArray *animations;
    
    switch (self.direction) {
        case GotyeMessageBubbleDirectionLeft:
            iconXOffset = 0;
            labelXOffset = [self bubbleContentWidth] - _durationLabel.frame.size.width;
            voiceIconImg = @"chat_bubble_anim_voice_left2";
            animations = @[[[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"chat_bubble_anim_voice_left0" ofType:@"png"]], [[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"chat_bubble_anim_voice_left1" ofType:@"png"]], [[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"chat_bubble_anim_voice_left2" ofType:@"png"]]];
            break;
        case GotyeMessageBubbleDirectionRight:
            iconXOffset = [self bubbleContentWidth] - kVoiceIconWidth;
            labelXOffset = 0;
            voiceIconImg = @"chat_bubble_anim_voice_right2";
            animations = @[[[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"chat_bubble_anim_voice_right0" ofType:@"png"]], [[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"chat_bubble_anim_voice_right1" ofType:@"png"]], [[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"chat_bubble_anim_voice_right2" ofType:@"png"]]];
            break;
        default:
            return;
    }
    
    NSInteger iconYOffset = ([self bubbleContentHeight] - kVoiceIconHeight) / 2;
    NSInteger labelYOffset = ([self bubbleContentHeight] - _durationLabel.frame.size.height) / 2;
    
    _voiceIcon.frame = CGRectMake(iconXOffset, iconYOffset, kVoiceIconWidth, kVoiceIconHeight);
    _voiceIcon.image = [[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:voiceIconImg ofType:@"png"]];
    _voiceIcon.animationImages = animations;
    
    _durationLabel.frame = CGRectMake(labelXOffset, labelYOffset, _durationLabel.frame.size.width, _durationLabel.frame.size.height);
}

- (UIView *)bubbleContentView
{
    return [self voiceContentView];
}

- (NSUInteger)bubbleContentWidth
{
    int minLength = MAX(kBubbleMinWidth - [self bubbleInsetHorizontal] * 2 - kBubbleCommaLenth, 20 + kVoiceIconWidth + 10);
    return 100 * (self.duration > kMaxVoiceLenth ? kMaxVoiceLenth : self.duration) / kMaxVoiceLenth + minLength;
}

- (UIView*)voiceContentView
{
    if (!_voiceContentView) {
        _voiceContentView = [[UIView alloc]init];
        _voiceContentView.userInteractionEnabled = NO;
    }
    
    return _voiceContentView;
}

- (void)startAnimating
{
    //WTF!! 直接调用在tableview reloaddata的时候会不起作用
    dispatch_async(dispatch_get_main_queue(), ^{
        [_voiceIcon startAnimating];
    });
}

- (void)stopAnimating
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_voiceIcon stopAnimating];
    });
}

- (void)setDuration:(NSUInteger)duration
{
    _duration = (duration < 1000 ? 1000 : duration);
    [self durationLabel].text = [NSString stringWithFormat:@"%d''", _duration / 1000];
}

- (UILabel *)durationLabel
{
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc]init];
        _durationLabel.font = [UIFont systemFontOfSize:kChatTextSize];
        _durationLabel.backgroundColor = [UIColor clearColor];
    }
    
    return _durationLabel;
}

- (UIImageView *)voiceIcon
{
    if (!_voiceIcon) {
        _voiceIcon = [[UIImageView alloc]init];
        _voiceIcon.animationDuration = 1.0f;
        _voiceIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _voiceIcon;
}

@end
