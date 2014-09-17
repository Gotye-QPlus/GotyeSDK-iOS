//
//  GotyeImageCell.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-14.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeImageCell.h"
#import "UIImage+Mask.h"
#import "GotyeSDKResource.h"

@interface GotyeImageCell()
{
    UIImageView *_imgView;
}
@end

@implementation GotyeImageCell

NSUInteger minWidth;
NSUInteger minHeight;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        _imgView = [[UIImageView alloc]init];
//        _imgView.contentMode = UIViewContentModeScaleAspectFit;
//        [self.bubbleBtn addSubview:_imgView];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            minWidth = (IS_IPAD ? 100 : 60);
            minHeight = (IS_IPAD ? 100 : 60);
        });
    }
    
    return self;
}

- (UIView *)bubbleContentView
{
    return [self imgView];
}


- (NSUInteger)bubbleContentWidth
{
    CGFloat imageWidth = self.imageContent.size.width / 2;
    CGFloat imageHeight = self.imageContent.size.height / 2;
    
    if (imageWidth < minWidth) {
        imageHeight = imageHeight / imageWidth * minWidth;
        imageWidth = minWidth;
    }
    
    if (imageHeight < minHeight) {
        imageWidth = imageWidth / imageHeight * minHeight;
        imageHeight = minHeight;
    }
    
    return MIN(imageWidth, kContentWidthMax) ;
}

- (NSUInteger)bubbleContentHeight
{
    return self.imageContent.size.height / self.imageContent.size.width * [self bubbleContentWidth];
}

- (NSUInteger)bubbleInsetHorizontal
{
    return 5;
}

- (NSUInteger)bubbleInsetVertical
{
    return 5;
}

- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc]init];
        _imgView.contentMode = UIViewContentModeScaleToFill;
    }
    
    return _imgView;
}

- (void)layoutSubviews
{
    [self imgView].image = [self.imageContent maskWithImage:[GotyeSDKResource getAvatarMask] width:[self bubbleContentWidth] height:[self bubbleContentHeight]];
    
    [super layoutSubviews];
}

@end
