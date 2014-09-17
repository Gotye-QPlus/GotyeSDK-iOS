//
//  GotyeFileUtil.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-13.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GotyeFileUtil : NSObject

+ (NSString *)getRootDir;
+ (NSString *)getCacheDir;
+ (NSString *)resPathForURL:(NSString *)url;

@end
