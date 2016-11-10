//
//  NSDate+Calendar.m
//  日历
//
//  Created by 叶慧伟 on 16/4/18.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "NSDate+Calendar.h"

@implementation NSDate (Calendar)

+ (NSInteger)getCurrentDateWeekly:(NSDate *)date{
    return [[NSCalendar currentCalendar]ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:date];
}

+ (NSInteger)numOfDaysInOffsetMonth:(NSInteger)offsetMonth{
    return [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[self getCurrentDateoffsetMonth:offsetMonth]].length;
}

+ (NSDate *)firstDayoffsetMonth:(NSInteger)offsetMonth{
    NSDate *starDate = nil;
    BOOL isFirstDay = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth startDate:&starDate interval:NULL forDate:[self getCurrentDateoffsetMonth:offsetMonth]];
    NSAssert1(isFirstDay, @"失败%@", self);
    return starDate;
}

+ (NSDate *)getCurrentDateoffsetMonth:(NSInteger)offsetMonth{
    //创建阳历
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *adCompets = [[NSDateComponents alloc]init];
    
    [adCompets setYear:0];
    [adCompets setMonth:offsetMonth];
    [adCompets setDay:0];
    
    NSDate *date = [calendar dateByAddingComponents:adCompets toDate:[NSDate date] options:0];
    
    return date;
}

+ (NSString *)changeDateToString:(NSDate *)date andDateFormat:(NSString *)dateFormat{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:dateFormat];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

@end
