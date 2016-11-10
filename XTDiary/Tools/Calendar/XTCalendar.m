//
//  XTCalendar.m
//  日历
//
//  Created by 叶慧伟 on 16/4/21.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "XTCalendar.h"
#import "XTCalendarHeaderView.h"
#import "XTCalendarView.h"

@interface XTCalendar ()

@property (nonatomic, strong)XTCalendarHeaderView *headerView;
@property (nonatomic, strong)XTCalendarView *calendarView;

@property (nonatomic, assign)NSInteger offsetMonth;

@end

@implementation XTCalendar

- (instancetype)initWithHeraderBackGroundColor:(UIColor *)color andFrame:(CGRect)totalFrame{
    if (self = [super initWithFrame:totalFrame]) {
        self.headerView.backgroundColor = color;
        [self setUI];
    }
    return self;
}

- (void)setUI{
    
    [self addSubview:self.headerView];
    [self addSubview:self.calendarView];
    
    [self.headerView changMonthInHeader:self.offsetMonth];
    
    __weak typeof(self) weakself = self;
    self.headerView.plusBlock = ^(){
        
        weakself.offsetMonth ++;
        [weakself.headerView changMonthInHeader:weakself.offsetMonth];
        [weakself.calendarView creatDataOffsetMonth:weakself.offsetMonth];
    };
    
    self.headerView.reduceBlock = ^(){
        
        weakself.offsetMonth --;
        [weakself.headerView changMonthInHeader:weakself.offsetMonth];
        [weakself.calendarView creatDataOffsetMonth:weakself.offsetMonth];
    };
}

- (void)setHeaderViewHeight:(CGFloat)headerViewHeight{
    _headerViewHeight = headerViewHeight;
    
    [self.headerView setFrame:CGRectMake(0, 0, self.frame.size.width, headerViewHeight)];
    [self.calendarView setFrame:CGRectMake(0, headerViewHeight, self.frame.size.width,  self.frame.size.height - headerViewHeight)];
}

- (void)setTodayColor:(UIColor *)todayColor{
    _todayColor = todayColor;
    
    self.calendarView.todayColor = todayColor;
}

- (void)setTodayBackColor:(UIColor *)todayBackColor{
    _todayBackColor = todayBackColor;
    
    self.calendarView.todayBackColor = todayBackColor;
}

- (void)setBeforeDayColor:(UIColor *)beforeDayColor{
    _beforeDayColor = beforeDayColor;
    
    self.calendarView.beforeDayColor = beforeDayColor;
}

- (void)setBeforeDayBackColor:(UIColor *)beforeDayBackColor{
    _beforeDayBackColor = beforeDayBackColor;
    
    self.calendarView.beforeDayBackColor = beforeDayBackColor;
}

- (void)setEmptyColor:(UIColor *)emptyColor{
    _emptyColor = emptyColor;
    
    self.calendarView.emptyColor = emptyColor;
}

- (XTCalendarHeaderView *)headerView{
    if (_headerView == nil) {
            _headerView = [[XTCalendarHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width + 1, self.frame.size.height * 0.15)];
    }
    return _headerView;
}

- (XTCalendarView *)calendarView{
    if (_calendarView == nil) {
             _calendarView = [[XTCalendarView alloc]initWithFrame:CGRectMake(0, self.frame.size.height * 0.15, self.frame.size.width, self.frame.size.height * 0.85)];
    }
    return _calendarView;
}

@end
