//
//  XTCalendarHeaderView.h
//  日历
//
//  Created by 叶慧伟 on 16/4/19.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTCalendarHeaderView : UIView

@property (nonatomic, copy)void (^plusBlock)();
@property (nonatomic, copy)void (^reduceBlock)();

- (void)changMonthInHeader:(NSInteger)offsetMonth;

@end
