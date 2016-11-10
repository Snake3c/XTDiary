//
//  UIButton+Repeat.h
//  避免多次重复点击！
//
//  Created by 叶慧伟 on 16/4/25.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Repeat)

//防止重复点击
- (void)repeatTouch:(NSTimeInterval)delay block:(void(^)())operation;

@end
