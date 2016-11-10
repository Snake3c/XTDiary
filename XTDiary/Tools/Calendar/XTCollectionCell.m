//
//  XTCollectionCell.m
//  日历
//
//  Created by 叶慧伟 on 16/4/19.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "XTCollectionCell.h"

@implementation XTCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame: frame]) {
        [self addSubview:self.titleLabel];
    }
    return self;
}

#pragma mark -- setter
- (void)setCalendar:(CalendarModel *)calendar{
    _calendar = calendar;
    
    self.titleLabel.text = calendar.text;
    
    if (calendar.isToday) {
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor lightGrayColor];
    }else{
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.backgroundColor = [UIColor whiteColor];
    }
    
    if (calendar.text.length == 0) {
        self.titleLabel.text  = @"";
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor colorWithRed:240/255 green:240/255 blue:240/255 alpha:0.1];
    }
    if ([self.titleLabel.text isEqualToString:@"六"] || [self.titleLabel.text isEqualToString:@"日"]) {
        self.titleLabel.textColor = [UIColor redColor];
    };
    
    if (calendar.isBeforeDay) {
        self.titleLabel.textColor = [UIColor lightGrayColor];
    }
    
}

- (void)setTodayColor:(UIColor *)todayColor{
    _todayColor = todayColor;
    
    if (self.calendar.isToday && todayColor != nil) {
        self.titleLabel.textColor = todayColor;
    }
}

- (void)setTodayBackColor:(UIColor *)todayBackColor{
    _todayBackColor = todayBackColor;
    
    if (self.calendar.isToday && todayBackColor != nil) {
        self.titleLabel.backgroundColor = todayBackColor;
    }
}

- (void)setBeforeDayColor:(UIColor *)beforeDayColor{
    _beforeDayColor = beforeDayColor;
    
    if (self.calendar.isBeforeDay && beforeDayColor != nil) {
        self.titleLabel.textColor = beforeDayColor;
    }
}

- (void)setBeforeDayBackColor:(UIColor *)beforeDayBackColor{
    _beforeDayBackColor = beforeDayBackColor;
    
    if (self.calendar.isBeforeDay && beforeDayBackColor != nil) {
        self.titleLabel.backgroundColor = beforeDayBackColor;
    }
}

- (void)setEmptyColor:(UIColor *)emptyColor{
    _emptyColor = emptyColor;
    
    if (self.calendar.text.length == 0 && emptyColor != nil) {
        self.titleLabel.backgroundColor = emptyColor;
    }
}

- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc]initWithFrame:self.bounds];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end
