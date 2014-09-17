//
//  GotyeFileUtil.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-13.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeFileUtil.h"
#import "NSString+MD5.h"
#import "GotyeSDKConfig.h"

@implementation GotyeFileUtil

+ (NSString *)getRootDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootPath = [[[paths objectAtIndex:0]stringByAppendingPathComponent:@"GotyeSDK"]stringByAppendingPathComponent:[GotyeSDKConfig sharedInstance].userAccount];
    return rootPath;
}

+ (NSString *)getCacheDir
{
    
    NSString *cacheDir = [[self getRootDir]stringByAppendingPathComponent:@"Cache"];
    if (![[NSFileManager defaultManager]fileExistsAtPath:cacheDir]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return cacheDir;
}

+ (NSString *)resPathForURL:(NSString *)url
{
   return [[GotyeFileUtil getCacheDir]stringByAppendingPathComponent:[url MD5String]];
}

@end
