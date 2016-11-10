//
//  UIGestureRecognizer+block.h
//  基础框架
//
//  Created by 叶慧伟 on 16/5/9.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^XTGesBlock)();

@interface UIGestureRecognizer (block)

+ (instancetype)actionBlock:(XTGesBlock)block;
- (instancetype)initWithActionBlock:(XTGesBlock)block;

@end
