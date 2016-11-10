//
//  UIGestureRecognizer+block.m
//  基础框架
//
//  Created by 叶慧伟 on 16/5/9.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "UIGestureRecognizer+block.h"
#import <objc/runtime.h>

static const int target_key;

@implementation UIGestureRecognizer (block)

+ (instancetype)actionBlock:(XTGesBlock)block{
    return [[self alloc]initWithActionBlock:block];
}

- (instancetype)initWithActionBlock:(XTGesBlock)block{
    self = [self init];
    [self addActionBlock:block];
    [self addTarget:self action:@selector(invoke:)];
    return self;
}

- (void)addActionBlock:(XTGesBlock)block{
    if (block) {
        objc_setAssociatedObject(self, &target_key, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)invoke:(id)sender{
    XTGesBlock block = objc_getAssociatedObject(self, &target_key);
    if (block) {
        block(sender);
    }
}

@end
