//
//  XTCalendar.h
//  日历
//
//  Created by 叶慧伟 on 16/4/21.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTCalendar : UIView

- (instancetype)initWithHeraderBackGroundColor:(UIColor *)color andFrame:(CGRect)totalFrame;

//设置头部的高度,建议暂时不要用这个属性，因为日期高度是写死的，改这个很麻烦
@property (nonatomic, assign)CGFloat headerViewHeight;

//当天字体色
@property (nonatomic, strong)UIColor *todayColor;
//当天背景色
@property (nonatomic, strong)UIColor *todayBackColor;
//之前天数颜色
@property (nonatomic, strong)UIColor *beforeDayColor;
//之前天数背景色
@property (nonatomic, strong)UIColor *beforeDayBackColor;
//空白天数颜色
@property (nonatomic, strong)UIColor *emptyColor;

@end
