//
//  EmotionLabel.h
//  Jacky <newbdez33@gmail.com>
//
//  Created by Jacky on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTAttributedTextContentView.h"

@interface GotyeEmotionLabel : DTAttributedTextContentView {
}

@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) NSString *replacedText;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic) NSUInteger constraintedWidth;
@property(nonatomic, copy) NSString *textColor;

@end
