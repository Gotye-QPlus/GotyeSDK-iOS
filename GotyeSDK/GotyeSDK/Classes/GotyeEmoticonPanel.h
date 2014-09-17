//
//  GotyeEmoticonPanel.h
//  Gotye
//
//  Created by Peter on 12-7-9.
//  Copyright (c) 2012年 AiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GotyeViewController.h"

@interface GotyeEmoticonPanel : GotyeViewController <UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *emoticonView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;

@property (nonatomic, retain) IBOutlet UIButton *sendButton;

@property (nonatomic, retain) UITextView *textInput;

@end
