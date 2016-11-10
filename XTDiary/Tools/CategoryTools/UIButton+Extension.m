//
//  UIButton+Extension.m
//  基础框架
//
//  Created by 叶慧伟 on 16/3/31.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "UIButton+Extension.h"

@implementation UIButton (Extension)

+ (instancetype)buttonWithTitleColor:(UIColor *)tcolor titleFontSize:(CGFloat)size buttonColor:(UIColor *)bcolor state:(UIControlState)state{
    UIButton *button = [[UIButton alloc]init];
    [button setTitleColor:tcolor forState:state];
    button.backgroundColor = bcolor;
    button.titleLabel.font = [UIFont systemFontOfSize:size];
    return button;
}

@end
