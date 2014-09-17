//
//  GotyeVoiceCell.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-15.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeMessageBubbleCell.h"

@interface GotyeVoiceCell : GotyeMessageBubbleCell

@property(nonatomic) NSUInteger duration;

- (void)startAnimating;
- (void)stopAnimating;

@end
