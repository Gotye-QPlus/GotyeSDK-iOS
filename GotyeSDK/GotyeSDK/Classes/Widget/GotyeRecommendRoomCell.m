//
//  GotyeRecommendRoomCell.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-8.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeRecommendRoomCell.h"

@implementation GotyeRecommendRoomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define ICON_TITLE_MARGIN (IS_IPAD ? 20 : 10)
#define BOTTOM_INSET      (IS_IPAD ? 32 : 15)

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_roomNameLabel sizeToFit];
    
    CGRect labelFrame = _roomNameLabel.frame;
    CGRect iconFrame = _roomIcon.frame;
    labelFrame.origin.x = iconFrame.origin.x + iconFrame.size.width + ICON_TITLE_MARGIN;
    labelFrame.origin.y = (_roomNameLabel.superview.frame.size.height - labelFrame.size.height) / 2;
    _roomNameLabel.frame = labelFrame;
    
    iconFrame.origin.y = labelFrame.origin.y;
    _roomIcon.frame = iconFrame;
    
    CGRect rootFrame = _rootView.frame;
    NSInteger bottomInset;
    if (_divider.hidden) {
        bottomInset = BOTTOM_INSET - 3;
    } else {
        bottomInset = BOTTOM_INSET;
    }
    
    rootFrame.origin.y = self.contentView.frame.size.height - rootFrame.size.height - bottomInset;
    _rootView.frame = rootFrame;
}

@end
