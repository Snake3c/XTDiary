//
//  CalendarModel.h
//  日历
//
//  Created by 叶慧伟 on 16/4/18.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarModel : NSObject

@property (nonatomic, copy)NSString *text;
@property (nonatomic, strong)NSDate *date;

@property (nonatomic, assign)BOOL isToday;
@property (nonatomic, assign)BOOL isBeforeDay;

@end
