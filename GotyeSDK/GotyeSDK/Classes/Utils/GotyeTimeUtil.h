//
//  QPlusTimeUtil.h
//  CSClient
//
//  Created by ouyang on 13-4-2.
//  Copyright (c) 2013年 AiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GotyeTimeUtil : NSObject

+ (NSDate *)begginingOfDay:(NSDate *)date;
+ (NSDate *)endOfDay:(NSDate *)date;

//date - anotherDate的天数，负数表示date比anotherDate要早
+ (NSInteger)dayIntervalBetween:(NSDate *)date andDate:(NSDate *)anotherDate;

//+ (BOOL)isToday:(NSDate *)date;
//+ (BOOL)isYesterday:(NSDate *)date;
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format;
+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format;

@end
