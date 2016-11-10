//
//  XTCalendarView.m
//  日历
//
//  Created by 叶慧伟 on 16/4/6.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "XTCalendarView.h"
#import "NSDate+Calendar.h"
#import "CalendarModel.h"
#import "XTCollectionCell.h"

#define itemWidth 45

NSInteger const lineMarkTag = 222222;
static NSString *const calendarCollectionID = @"calendarCollectionID";

@interface XTCalendarView ()<UICollectionViewDelegate, UICollectionViewDataSource>{
    NSInteger mOffestMonth;
    NSString *curretnsetMonth;
}

@property (nonatomic, strong)NSMutableArray *datas;
@property (nonatomic, strong)UICollectionView *calendarCollection;

@end

@implementation XTCalendarView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        _datas = [NSMutableArray array];
        [self initCollection];
        [self creatDataOffsetMonth:0];
    }
    return self;
}

- (void)initCollection{
    
    [self addSubview:self.calendarCollection];
}

- (void)creatDataOffsetMonth:(NSInteger)offsetMonth{
    
    mOffestMonth = offsetMonth - 1;
    //这个月的第一天是当周的第几天
    NSInteger currentDay = [NSDate getCurrentDateWeekly:[NSDate firstDayoffsetMonth:offsetMonth]];
    
    NSInteger dayCountInMonth = [NSDate numOfDaysInOffsetMonth:offsetMonth];
    
    [_datas removeAllObjects];
    
    NSArray *weekArr = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    
    for (int i = 0; i < 7; i ++) {
         CalendarModel *calen = [[CalendarModel alloc]init];
         calen.text = weekArr[i];
        [_datas addObject:calen];
    }
    
    for (int i = 0; i < (dayCountInMonth + currentDay - 1); i ++) {
        
        CalendarModel *calen = [[CalendarModel alloc]init];
        
        //偏移天数
        NSInteger offsetDay = currentDay - 2;
        
        if (i > offsetDay) {
            
            calen.text = [[NSNumber numberWithInteger:(i - offsetDay)] stringValue];
            
             NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            NSDateComponents *dateComp = [[NSDateComponents alloc]init];
            
            [dateComp setYear:0];
            [dateComp setMonth:offsetMonth];
            [dateComp setDay:(i - offsetDay) - [NSDate changeDateToString:[NSDate getCurrentDateoffsetMonth:0] andDateFormat:@"dd"].integerValue];
            
            NSDate *newDate = [calendar dateByAddingComponents:dateComp toDate:[NSDate date] options:0];
            
            calen.date = newDate;
            
            if ([newDate timeIntervalSinceDate:[NSDate date]] <= 0) {
                calen.isBeforeDay = YES;
            }
        }
        
        [_datas addObject:calen];
        
        if (offsetMonth == 0 && [[NSDate changeDateToString:[NSDate getCurrentDateoffsetMonth:0] andDateFormat:@"dd"] integerValue] == (i - offsetDay - 1)) {
            calen.isToday = YES;
        }
        
        [self.calendarCollection reloadData];
    }
    
    //自适应宽高
    NSInteger count = 0;
    if (_datas.count % 7 == 0) {
        
        count = _datas.count / 7;
    }else{
    
        count = _datas.count / 7 + 1;
        
        NSInteger offsetCount = _datas.count % 7;
        
        //多出的用来填充collection
        for (int i = 0; i <(7 - offsetCount); i ++ ) {
            CalendarModel *calendar = [[CalendarModel alloc]init];
            
            [_datas addObject:calendar];
        }
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, itemWidth * count)];
    [self.calendarCollection setFrame:CGRectMake(0, 0, self.bounds.size.width, itemWidth * count)];
}

- (void)drawLineOnCalendar:(NSInteger)index{
  
    //重绘时删除
    if (index == 0) {
        for (UIView *lineView in self.subviews) {
            if (lineView.tag == lineMarkTag) {
                [lineView removeFromSuperview];
            }
        }
    }
    
    if (index <= 7) {
        UIView *HlineView = [[UIView alloc]initWithFrame:CGRectMake(index * self.bounds.size.width / 7 , 0, 1, self.bounds.size.height)];
        HlineView.backgroundColor = [UIColor darkGrayColor];
        HlineView.tag = lineMarkTag;
        [self addSubview:HlineView];
    }
    if (index % 7 == 0) {
        UIView *VlineView = [[UIView alloc]initWithFrame:CGRectMake(0, itemWidth * index / 7, self.bounds.size.width, 1)];
        VlineView.backgroundColor = [UIColor darkGrayColor];
        VlineView.tag = lineMarkTag;
        [self addSubview:VlineView];
    }
    //画最后一条线
    if (index == 0) {
        UIView *lastLineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 1)];
        lastLineView.backgroundColor = [UIColor darkGrayColor];
        lastLineView.tag = lineMarkTag;
        [self addSubview:lastLineView];
    }
}

#pragma mark --delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    XTCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:calendarCollectionID forIndexPath:indexPath];
    cell.calendar = _datas[indexPath.item];
    if (_datas.count > 0) {
        [self drawLineOnCalendar:indexPath.item];
    }
    cell.todayColor = self.todayColor;
    cell.todayBackColor = self.todayBackColor;
    cell.beforeDayColor = self.beforeDayColor;
    cell.beforeDayBackColor = self.beforeDayBackColor;
    cell.emptyColor = self.emptyColor;
    
    return cell;
}

- (UICollectionView *)calendarCollection{
    if (_calendarCollection == nil) {
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc]init];
        flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowlayout.minimumLineSpacing = 0;
        flowlayout.minimumInteritemSpacing = 0;
        flowlayout.itemSize = CGSizeMake(self.bounds.size.width / 7 , itemWidth);
        _calendarCollection = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:flowlayout];
        _calendarCollection.backgroundColor = [UIColor clearColor];
        
        [_calendarCollection registerClass:[XTCollectionCell class] forCellWithReuseIdentifier:calendarCollectionID];
        _calendarCollection.delegate = self;
        _calendarCollection.dataSource = self;
    }
    return _calendarCollection;
}

@end
