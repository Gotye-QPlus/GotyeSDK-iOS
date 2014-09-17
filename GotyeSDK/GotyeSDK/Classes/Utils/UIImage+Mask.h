//
//  UIImage+Mask.h
//  GotyeAPI
//
//  Created by ouyang on 14-2-26.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Mask)

- (UIImage *)maskWithImage:(const UIImage *) maskImage;
- (UIImage *)maskWithImage:(const UIImage *)maskImage width:(NSUInteger)width height:(NSUInteger)height;

@end
