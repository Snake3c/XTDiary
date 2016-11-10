//
//  XTCalendarHeaderView.m
//  日历
//
//  Created by 叶慧伟 on 16/4/19.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "XTCalendarHeaderView.h"
#import "XTCalendarView.h"
#import "NSDate+Calendar.h"

#define BTNHeight 20

@interface XTCalendarHeaderView()

@property (nonatomic, strong)UIButton *pulsBtn;
@property (nonatomic, strong)UIButton *reduceBtn;
@property (nonatomic, strong)UILabel *titleLabel;

@end

@implementation XTCalendarHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor purpleColor];
        
        [self addSubview:self.pulsBtn];
        [self addSubview:self.reduceBtn];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)puluBtnClick{
    if (self.plusBlock) {
        self.plusBlock();
    }
}

- (void)reduceBtnClick{
    if (self.reduceBlock) {
        self.reduceBlock();
    }
}

- (void)changMonthInHeader:(NSInteger)offsetMonth{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |
    NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateCom = [calendar components:unitFlags fromDate:date];
    NSArray *monthArr = @[@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",
                          @"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec"];
    NSInteger month = dateCom.month - 1;
    
    NSInteger currentMonth = (month + offsetMonth) % 12;
    if (currentMonth < 0) {
        currentMonth = 12 + currentMonth;
    }
    NSString *monthStr = [[NSString alloc]initWithString:[monthArr objectAtIndex:currentMonth]];
    
    self.titleLabel.text = monthStr;
}

- (UIButton *)pulsBtn{
    if (_pulsBtn == nil) {
        _pulsBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width - 25, (self.bounds.size.height - BTNHeight) / 2, BTNHeight, BTNHeight)];
        [_pulsBtn setImage:[UIImage imageNamed:@"plusacc"] forState:UIControlStateNormal];
        [_pulsBtn addTarget:self action:@selector(puluBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pulsBtn;
}

- (UIButton *)reduceBtn{
    if (_reduceBtn == nil) {
        _reduceBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, (self.bounds.size.height - BTNHeight) / 2, BTNHeight, BTNHeight)];
        [_reduceBtn setImage:[UIImage imageNamed:@"reduceacc"] forState:UIControlStateNormal];
        [_reduceBtn addTarget:self action:@selector(reduceBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reduceBtn;
}

- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc]initWithFrame:self.bounds];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

@end
