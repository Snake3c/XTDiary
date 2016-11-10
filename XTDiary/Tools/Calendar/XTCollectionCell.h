//
//  XTCollectionCell.h
//  日历
//
//  Created by 叶慧伟 on 16/4/19.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarModel.h"

@interface XTCollectionCell : UICollectionViewCell

@property (nonatomic, strong)UILabel *titleLabel;

@property (nonatomic, strong)CalendarModel *calendar;

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
