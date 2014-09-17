//
//  GotyeEmotionLabel.m
//  Jacky <newbdez33@gmail.com>
//
//  Created by Jacky on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GotyeEmotionLabel.h"
#import "GotyeSDKResource.h"
//#import "NSAttributedString+HTML.h"

@interface GotyeEmotionLabel()

+ (NSDictionary *)getEmotions;

@end

@implementation GotyeEmotionLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
//        self.shouldDrawLinks = NO;
        self.shouldLayoutCustomSubviews = NO;
    }
    
    return self;
}

+ (NSDictionary *)getEmotions {
    static NSDictionary *ems;
    if (!ems) {
//        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emotions" ofType:@"plist"];
//        ems = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSMutableDictionary *temp = [[NSMutableDictionary alloc]init];
        for (int index = 1; index < 100; ++index) {
            NSString *imgPath = [GotyeSDKResource pathForResource:[NSString stringWithFormat:@"smiley_%d", index] ofType:@"png"];
            [temp setObject: imgPath forKey:[NSString stringWithFormat:@"s%d", index]];
        }
        
        ems = temp;
        temp = nil;
    }
    
    return ems;
    
}

- (void)setText:(NSString *)text {
    if (text == _text || [text isEqualToString:_text]) {
        return;
    }
    
    _text = [text copy];
    self.attributedString = [self formateText];
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
    if (attributedString == self.attributedString) {
        return;
    }
    
    [super setAttributedString:attributedString];
//    [self sizeToFit];
}

- (void)setConstraintedWidth:(NSUInteger)constraintedWidth
{
    _constraintedWidth = constraintedWidth;
//    if (self.attributedString) {
//        [self sizeToFit];
//    }
}

- (void)sizeToFit
{
    CGSize suggestedSize = [self suggestedFrameSizeToFitEntireStringConstraintedToWidth:_constraintedWidth];
    CGRect frame = self.frame;
    frame.size = suggestedSize;
    self.frame = frame;
}

- (NSAttributedString *)formateText
{
    NSString *replaced;
    NSMutableString *formatedResponse = [NSMutableString string];
    
    NSScanner *emotionScanner = [NSScanner scannerWithString:_text];
    
    [emotionScanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    while ([emotionScanner isAtEnd] == NO) {
        
        if([emotionScanner scanUpToString:@"[" intoString:&replaced]) {
            [formatedResponse appendString:replaced];
        }
        if(![emotionScanner isAtEnd]) { //scanner的位置没有在末尾说明字符串含有"["
            [emotionScanner scanString:@"[" intoString:nil];
            replaced = @"";
            [emotionScanner scanUpToString:@"]" intoString:&replaced];
            
            if ([replaced rangeOfString:@"["].location != NSNotFound) {
                [formatedResponse appendString:@"["];
                if ([emotionScanner isAtEnd] == NO) {
                    [emotionScanner setScanLocation:formatedResponse.length];
                    continue;
                }
            }
            
            BOOL hasEndFlag = [emotionScanner scanString:@"]" intoString:nil];

            //TODOif replace contains '[' then reset scanner location to this newer '[' and scan again.
            NSString *em = [[GotyeEmotionLabel getEmotions] valueForKey:replaced];
            em = [em stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (em) {
                [formatedResponse appendFormat:@"<img src='%@' />", [NSString stringWithFormat:@"file://%@/",em]];
            }else {
                [formatedResponse appendFormat:@"[%@%@", replaced, (hasEndFlag ? @"]" : @"")];
            }
        }
        
    }
    
    //NSLog(@"formatedResponse: %@", formatedResponse);
    [formatedResponse replaceOccurrencesOfString:@"\n" withString:@"<br />" options:0 range:NSMakeRange(0, formatedResponse.length)];

    self.replacedText = formatedResponse;

    return [self createAttributedString];
}

- (void)setTextColor:(NSString *)textColor
{
    if (textColor == _textColor || [textColor isEqualToString:_textColor]) {
        return;
    }
    
    _textColor = [textColor copy];
    if (self.replacedText != nil) {
        self.attributedString = [self createAttributedString];
    }
}

- (NSAttributedString *)createAttributedString
{
    NSData *data = [[NSString stringWithFormat:@"<p style='font-size:%fpt'>%@</p>", _font.pointSize, self.replacedText] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGSize:CGSizeMake(_font.lineHeight, _font.lineHeight)], DTMaxImageSize, @"System", DTDefaultFontFamily, _textColor, DTDefaultTextColor, nil];
    
    return [[NSAttributedString alloc] initWithHTML:data options:options documentAttributes:nil];
}

@end
