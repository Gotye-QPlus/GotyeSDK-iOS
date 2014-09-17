//
//  QPlusFullScreenImage.h
//  QPlus
//
//  Created by Peter on 12-7-5.
//  Copyright (c) 2012年 AiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GotyeDownloadDelegate.h"

@class GotyeViewController;

@interface GotyeFullScreenImage : GotyeViewController <GotyeDownloadDelegate>
{
    IBOutlet UIImageView *_fullScreenImage;
}

@property (nonatomic, strong) UIImage *image;

- (id)initWithImage:(UIImage*)imageShow;
- (id)initWithThumb:(UIImage *)thumb downloadURL:(NSString *)url downloadPath:(NSString *)path;

- (void)showInView:(UIView *)view;
- (void)hide;

@end
