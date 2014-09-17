//
//  GotyeImageManager.m
//  GotyeSDK
//
//  Created by ouyang on 13-12-16.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeImageManager.h"
#import "GotyeImageCache.h"
#import "GotyeSDKResource.h"
#import "GotyeFileUtil.h"
#import "GotyeAPI.h"
#import "NSString+MD5.h"

@interface GotyeImageManager()
{
    NSMutableArray *_downloadingImage;
    NSMutableArray *_badURLs;
}
@end

@implementation GotyeImageManager

+ (GotyeImageManager *)sharedImageManager
{
    static GotyeImageManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GotyeImageManager alloc]init];
    });
    
    return instance;
}

- (id)init
{
    if (self = [super init]) {
    }
    
    return self;
}

- (void)initialize
{
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeDownload];
}

- (UIImage *)getImageWithPath:(NSString *)path
{
    if (path.length == 0) {
        return nil;
    }
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        return [self getLocalImageWithPath:path];
    } else {
        return [self getHttpImageWithURL:path];
    }
}

- (UIImage *)getHttpImageWithURL:(NSString *)url
{
    NSString *fullPath = [GotyeFileUtil resPathForURL:url];

    UIImage *image = [self getLocalImageWithPath:fullPath];
    if (image != nil) {
        return image;
    }
    
    if (!_downloadingImage) {
        _downloadingImage = [[NSMutableArray alloc]init];
    }
    
    if (!_badURLs) {
        _badURLs = [[NSMutableArray alloc]init];
    }
    
    if (![_downloadingImage containsObject:url] && ![_badURLs containsObject:url]) {
        [_downloadingImage addObject:url];
        [GotyeAPI downloadResWithURL:url saveTo:fullPath];
    }
    
    return nil;
}

- (UIImage *)getLocalImageWithPath:(NSString *)path
{
    NSString *key = path;
    UIImage *image = [[GotyeImageCache sharedImageCache]imageForKey:key];
    
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:path];
        if (image != nil) {
            [[GotyeImageCache sharedImageCache]setImage:image forKey:key];
        }
    }
    
    return image;
}

- (void)clearCache
{
    [[GotyeImageCache sharedImageCache]clear];
}

- (void)uninitialize
{
    [self clearCache];
    [GotyeAPI removeListener:self];
}

#pragma mark - download delegate -

- (void)onDownloadRes:(NSString *)downloadURL path:(NSString *)savedPath result:(GotyeStatusCode)status
{
    [_downloadingImage removeObject:downloadURL];
    
    if (status != GotyeStatusCodeOK) {
        DLog(@"下载失败 %@", downloadURL);
        [_badURLs addObject:downloadURL];
        return;
    }
    
    DLog(@"下载成功: %@", downloadURL);
    NSString *path = [GotyeFileUtil resPathForURL:downloadURL];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (image == nil) {
        [_badURLs addObject:downloadURL];
    }
}

@end
