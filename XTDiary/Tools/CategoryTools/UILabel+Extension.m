//
//  UILabel+Extension.m
//  基础框架
//
//  Created by 叶慧伟 on 16/3/31.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "UILabel+Extension.h"

@implementation UILabel (Extension)

+ (instancetype)labelWithFontSize:(CGFloat)size textColor:(UIColor *)color{
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = color;
    label.numberOfLines = 0;
    [label sizeToFit];
    return label;
}

@end
