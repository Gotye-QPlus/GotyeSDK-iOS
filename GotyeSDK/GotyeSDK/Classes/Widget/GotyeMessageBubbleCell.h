//
//  GotyeMessageBubbleCell.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-14.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GotyeMessage.h"
#import "GotyeChatMessageItem.h"

#define GotyeBubbleText             (100)
#define GotyeBubbleImage            (200)
#define GotyeBubbleVoiceDuration    (300)

#define kChatTextSize           (IS_IPAD ? 25 : 15)
#define kNameTextSize           (IS_IPAD ? 20 : 11)

#define kBubbleAppIconHeight (IS_IPAD ? 81 : 54)
#define kBubbleSysMinHeight   (IS_IPAD ? 54 : 36)
#define kBubbleMinHeight      (IS_IPAD ? 63 : 41)
#define kBubbleMinWidth       (IS_IPAD ? 99 : 48)
//#define kBubbleCommaOffset   (IS_IPAD ? 81 : 54)
#define kBubbleCommaLenth    (IS_IPAD ? 14 : 9)
#define kBubbleBlankOffset   (IS_IPAD ? 75 : 50)

#define kItemMargin        (IS_IPAD ? 12 : 6)
#define kHeadImgSize        (IS_IPAD ? 63 : 40)
#define kCellInset          (IS_IPAD ? 25 : 15)
#define kMarginBetweenHeadAndBubble (IS_IPAD ? 16: 8)
#define kMaxNameLength      (IS_IPAD ? 80 : 60)

#define kNameTextHeight     (IS_IPAD ? 23 : 12)
#define kAvatarNameOffset   (10)

#define kVoiceIconWidth     (IS_IPAD ? 21 : 12)
#define kVoiceIconHeight    (IS_IPAD ? 32 : 22)

#define kTimeTextHeight     (IS_IPAD ? 34 : 15)
#define kTimeMinWidth       (37)
#define kTimeTextFont       (IS_IPAD ? 20 : 12)

#define kAddFrdBgWidth      (IS_IPAD ? 240 : 160)
#define kAddFrdBgHeight     (IS_IPAD ? 315 : 220)
#define kInvFrdBgWidth      (IS_IPAD ? 250 : 149)
#define kInvFrdBgHeight     (IS_IPAD ? 150 : 110)
#define kFrdHeadSize        (IS_IPAD ? 159 : 106)
#define kFrdHeadOffset      (IS_IPAD ? 30 : 20)
#define kAddBtnWidth        (IS_IPAD ? 167 : 111)
#define kAddBtnHeight       (IS_IPAD ? 53 : 35)

#define kContentWidthMax    ([[UIScreen mainScreen]bounds].size.width - kCellInset - kHeadImgSize - kMarginBetweenHeadAndBubble - kBubbleCommaLenth - [self bubbleInsetHorizontal] * 2 - kBubbleBlankOffset)

#define GOTYE_FORBIDDEN_TEXT (@"您已被禁言，如需恢复请与管理员联系!")

typedef enum
{
    GotyeMessageBubbleDirectionLeft,
    GotyeMessageBubbleDirectionRight
}GotyeMessageBubbleDirection;

@interface GotyeMessageBubbleCell : UITableViewCell

@property(nonatomic, strong) UIButton *avatarBtn;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UIButton *bubbleBtn;
@property(nonatomic) GotyeMessageBubbleDirection direction;
@property(nonatomic) GotyeMessageType msgType;
@property(nonatomic, strong) UIActivityIndicatorView *progressIndicator;
@property(nonatomic, strong) UIImageView *errorState;
@property(nonatomic, strong) UIButton *timeButton;
@property(nonatomic) GotyeChatMessageState msgState;

+ (GotyeMessageBubbleCell *)cellWithType:(GotyeMessageType)type reuseIdentifier:(NSString *)reuseIdentifier;

- (UIView *)bubbleContentView;
- (NSUInteger)bubbleContentWidth;
- (NSUInteger)bubbleContentHeight;
- (NSUInteger)bubbleInsetHorizontal;
- (NSUInteger)bubbleInsetVertical;

- (NSUInteger)cellHeight;

@end
