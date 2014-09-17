//
//  GotyeUserGridCell.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-22.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeUserGridCell.h"
#import "GotyeSDkSkin.h"
#import "UIColor+HTML.h"

#define kNameFont       (IS_IPAD ? 20 : 12)

@implementation GotyeUserGridCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        
        _avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_avatarBtn];
        
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.numberOfLines = 1;
        _nameLabel.font = [UIFont systemFontOfSize:kNameFont];
        _nameLabel.textAlignment = UITextAlignmentCenter;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorUserListName]];
        [self addSubview:_nameLabel];
    }
    
    return self;
}

@end
