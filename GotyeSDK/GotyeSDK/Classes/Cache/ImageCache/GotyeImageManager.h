//
//  GotyeImageManager.h
//  GotyeSDK
//
//  Created by ouyang on 13-12-16.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GotyeDownloadDelegate.h"

@interface GotyeImageManager : NSObject <GotyeDownloadDelegate>

+ (GotyeImageManager *)sharedImageManager;

- (UIImage *)getImageWithPath:(NSString *)path;
- (void)clearCache;

- (void)initialize;
- (void)uninitialize;

@end
