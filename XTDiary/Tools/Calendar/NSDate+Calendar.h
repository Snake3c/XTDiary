//
//  NSDate+Calendar.h
//  日历
//
//  Created by 叶慧伟 on 16/4/18.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Calendar)

//当周的第几天
+ (NSInteger )getCurrentDateWeekly:(NSDate *)date;

//当前月份有多少天
+ (NSInteger)numOfDaysInOffsetMonth:(NSInteger)offsetMonth;

//选中月份的第一天
+ (NSDate *)firstDayoffsetMonth:(NSInteger)offsetMonth;

//获取其他月份时间
+ (NSDate *)getCurrentDateoffsetMonth:(NSInteger)offsetMonth;

//转成string
+ (NSString *)changeDateToString:(NSDate *)date andDateFormat:(NSString *)dateFormat;

@end
