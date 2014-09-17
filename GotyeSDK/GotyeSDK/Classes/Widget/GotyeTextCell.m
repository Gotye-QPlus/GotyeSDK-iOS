//
//  GotyeTextCell.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-14.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeTextCell.h"
#import "GotyeEmotionLabel.h"

@implementation GotyeTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //文字标签设置
//        DLog(@"create text cell");
//        _emotionLabel = [[GotyeEmotionLabel alloc]init];
//        _emotionLabel.font = [UIFont systemFontOfSize:kChatTextSize];
//        _emotionLabel.backgroundColor = [UIColor clearColor];
//        _emotionLabel.constraintedWidth = kContentWidthMax;
//        _emotionLabel.userInteractionEnabled = NO;
        
//        [self.bubbleBtn addSubview:_emotionLabel];
    }
    
    return self;
}

- (UIView *)bubbleContentView
{
    return self.emotionLabel;
}

- (NSUInteger)bubbleContentWidth
{
    return self.emotionLabel.frame.size.width;
}

- (NSUInteger)bubbleContentHeight
{
    return self.emotionLabel.frame.size.height;
}

- (NSUInteger)bubbleInsetHorizontal
{
    return (IS_IPAD ? 15 : 10);
}

- (NSUInteger)bubbleInsetVertical
{
    return (IS_IPAD ? 15 : 10);
}

- (GotyeEmotionLabel *)emotionLabel
{
    if (!_emotionLabel) {
        _emotionLabel = [[GotyeEmotionLabel alloc]init];
        _emotionLabel.font = [UIFont systemFontOfSize:kChatTextSize];
        _emotionLabel.backgroundColor = [UIColor clearColor];
        _emotionLabel.constraintedWidth = kContentWidthMax;
        _emotionLabel.userInteractionEnabled = NO;
    }
    
    return _emotionLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    if (self.direction == GotyeMessageBubbleDirectionRight) {
//        self.emotionLabel.textColor = @"white";
//    } else {
//        self.emotionLabel.textColor = @"black";
//    }
}

@end
