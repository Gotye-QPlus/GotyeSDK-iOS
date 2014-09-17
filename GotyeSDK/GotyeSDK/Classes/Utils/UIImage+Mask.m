//
//  UIImage+Mask.m
//  GotyeAPI
//
//  Created by ouyang on 14-2-26.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "UIImage+Mask.h"

@implementation UIImage (Mask)

- (UIImage *) maskWithImage:(const UIImage *) maskImage
{
    const CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    const CGImageRef maskImageRef = maskImage.CGImage;
    
    CGFloat realWidth = maskImage.size.width * maskImage.scale;
    CGFloat realHeight = maskImage.size.height * maskImage.scale;
    
    const CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, realWidth, realHeight, 8, 0, colorSpace, CGImageGetBitmapInfo(maskImageRef));
    CGColorSpaceRelease(colorSpace);
    
    if (! mainViewContentContext)
    {
        return self;
    }
    
    CGFloat originalWidth = self.size.width * self.scale;
    CGFloat originalHeight = self.size.height * self.scale;
    
    CGFloat ratio = realWidth / originalWidth;
    
    if (ratio * originalHeight < realHeight)
    {
        ratio = realHeight / originalHeight;
    }
    
    const CGRect maskRect  = CGRectMake(0, 0, realWidth, realHeight);
    
    const CGRect imageRect  = CGRectMake(-((originalWidth * ratio) - realWidth) / 2,
                                         -((originalHeight * ratio) - realHeight) / 2,
                                         originalWidth * ratio,
                                         originalHeight * ratio);
    
    CGContextClipToMask(mainViewContentContext, maskRect, maskImageRef);
    CGContextDrawImage(mainViewContentContext, imageRect, self.CGImage);
    
    CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage *theImage = [UIImage imageWithCGImage:newImage];
    
    CGImageRelease(newImage);
    
    return theImage;
    
}

- (UIImage *)maskWithImage:(const UIImage *)maskImage width:(NSUInteger)width height:(NSUInteger)height
{
    CGFloat realWidth = round(width * maskImage.scale);
    CGFloat realHeight = round(height * maskImage.scale);
    
    UIGraphicsBeginImageContext(CGSizeMake(realWidth, realHeight));
    [maskImage drawInRect:CGRectMake(0, 0, realWidth, realHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//
    return [self maskWithImage:newImage];
//    return maskImage;
}

@end
