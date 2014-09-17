//
//  QPlusTimeUtil.m
//  CSClient
//
//  Created by ouyang on 13-4-2.
//  Copyright (c) 2013年 AiLiao. All rights reserved.
//

#import "GotyeTimeUtil.h"

@implementation GotyeTimeUtil

+ (NSDate *)begginingOfDay:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSMonthCalendarUnit | NSDayCalendarUnit |NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:date];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    return [cal dateFromComponents:components];
    
}

+ (NSDate *)endOfDay:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(  NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:date];
    
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    
    return [cal dateFromComponents:components];
    
}

+ (NSInteger)dayIntervalBetween:(NSDate *)date andDate:(NSDate *)anotherDate
{
    NSDate *beginingOfdate = [self begginingOfDay:date];
    NSDate *beginingOfAnotherDate = [self begginingOfDay:anotherDate];
    NSTimeInterval oneDay = 24 * 60 * 60;

    return [beginingOfdate timeIntervalSinceDate:beginingOfAnotherDate] / oneDay;
}

//+ (BOOL)isToday:(NSDate *)date
//{
//    NSDate *today = [NSDate date];
//    NSDate *begining = [self begginingOfDay:today];
//    NSDate *end = [self endOfDay:today];
//    if ([date timeIntervalSinceDate:begining] < 0 || [date timeIntervalSinceDate:end] > 0) {
//        return NO;
//    }
//    
//    return YES;
//}
//
//+ (BOOL)isYesterday:(NSDate *)date
//{
//    NSDate *today = [NSDate date];
//    NSTimeInterval oneDay = 24 * 60 * 60;
//    NSDate *beginingOfYesterday = [[self begginingOfDay:today]dateByAddingTimeInterval: - oneDay];
//    NSDate *endOfYesterday = [[self endOfDay:today]dateByAddingTimeInterval: - oneDay];
//    
//    if ([date timeIntervalSinceDate:beginingOfYesterday] < 0 || [date timeIntervalSinceDate:endOfYesterday] > 0) {
//        return NO;
//    }
//    
//    return YES;
//}


+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSLocale *local = [[NSLocale alloc]initWithLocaleIdentifier:[[NSLocale preferredLanguages] objectAtIndex:0]];
    [formatter setLocale:local];
    
    return [formatter stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSLocale *local = [[NSLocale alloc]initWithLocaleIdentifier:[[NSLocale preferredLanguages] objectAtIndex:0]];
    [formatter setLocale:local];
    
    return [formatter dateFromString:string];
}

@end
