//
//  QPlusFullScreenImage.m
//  QPlus
//
//  Created by Peter on 12-7-5.
//  Copyright (c) 2012年 AiLiao. All rights reserved.
//

#import "GotyeViewController.h"
#import "GotyeFullScreenImage.h"
#import "GotyeSDKUIControl.h"
#import "GotyeAPI.h"

@interface GotyeFullScreenImage()
{
    __strong GotyeFullScreenImage *_retained_self;
    
    NSString *_downloadURL;
    NSString *_downloadPath;
}

@end

@implementation GotyeFullScreenImage

- (IBAction)cancelBtnClick:(id)sender
{
    [self hide];
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *) contextInfo 
{  
    [[GotyeSDKUIControl sharedInstance]hideHudInView:self.view animated:NO];
    NSString *message;  
    NSString *title;  
    if (!error) {  
        title = @"成功提示";
        message = @"成功保存到相册";
    } else {  
        title = @"失败提示";  
        message = [error domain];
    }
    
    [[GotyeSDKUIControl sharedInstance]showAlertViewWithTitle:title message:message delegate:nil];
}

- (IBAction)saveImage:(id)sender
{
    [[GotyeSDKUIControl sharedInstance]showHudInView:self.view animated:NO text:nil];
    
    UIImageWriteToSavedPhotosAlbum(_image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark - View lifecycle

- (id)initWithImage:(UIImage *)imageShow
{
    if (self = [super init]) {
        _image = imageShow;
    }
    return self;
}

- (id)initWithThumb:(UIImage *)thumb downloadURL:(NSString *)url downloadPath:(NSString *)path
{
    if (self = [super init]) {
        _image = thumb;
        _downloadURL = url;
        _downloadPath = path;
    }
    
    return self;
}

- (id)init {
    return [self initWithImage:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_fullScreenImage setImage:_image];
    _fullScreenImage.contentMode = UIViewContentModeScaleAspectFit;
    
//    if (_image.size.width <= self.view.frame.size.width && _image.size.height <= self.view.frame.size.height) {
//        _fullScreenImage.contentMode = UIViewContentModeCenter;
//    } else {
//        _fullScreenImage.contentMode = UIViewContentModeScaleAspectFit;
//    }
}

- (void)showInView:(UIView *)view
{
    _retained_self = self;
    
    if (_downloadURL.length && _downloadPath.length) {
        [GotyeAPI addListener:self type:GotyeAPIListenerTypeDownload];
        [GotyeAPI downloadResWithURL:_downloadURL saveTo:_downloadPath];
    }
    
    self.view.frame = view.bounds;
    [[GotyeSDKUIControl sharedInstance]showFullScreenView:self.view inView:view];
}

- (void)hide
{
    [[GotyeSDKUIControl sharedInstance]hideFullScreenView:self.view];
    [GotyeAPI removeListener:self];
    _retained_self = nil;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    _fullScreenImage.contentMode = UIViewContentModeScaleAspectFit;
//    if (_image.size.width <= self.view.frame.size.width && _image.size.height <= self.view.frame.size.height)
//    {
//        _fullScreenImage.contentMode = UIViewContentModeCenter;
//    } else {
//        _fullScreenImage.contentMode = UIViewContentModeScaleAspectFit;
//    }
    
    [_fullScreenImage setImage:_image];
}

#pragma mark - download delegate -

- (void)onDownloadRes:(NSString *)downloadURL path:(NSString *)savedPath result:(GotyeStatusCode)status
{
    if (![downloadURL isEqualToString:_downloadURL]) {
        return;
    }
    
    if (status != GotyeStatusCodeOK) {
        return;
    }
    
    self.image = [UIImage imageWithContentsOfFile:savedPath];
    
}

@end
