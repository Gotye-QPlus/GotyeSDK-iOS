//
//  GotyeOrdinaryRoomCell.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-8.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeOrdinaryRoomCell.h"

@implementation GotyeOrdinaryRoomCell

@synthesize roomNameLabel = _roomNameLabel;
@synthesize roomImageView = _roomImageView;
@synthesize enterButton = _enterButton;

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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _bottomDivider.frame = CGRectMake(_roomImageView.frame.origin.x + 15 + _roomImageView.frame.size.width, _bottomDivider.frame.origin.y, self.frame.size.width - (_roomImageView.frame.origin.x + 15 + _roomImageView.frame.size.width), _bottomDivider.frame.size.height);
    _roomNameLabel.frame = CGRectMake(_bottomDivider.frame.origin.x, _roomNameLabel.frame.origin.y, _enterButton.frame.origin.x - 20 - _bottomDivider.frame.origin.x, _roomNameLabel.frame.size.height);
}

@end
