//
//  UIButton+Repeat.m
//  避免多次重复点击！
//
//  Created by 叶慧伟 on 16/4/25.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "UIButton+Repeat.h"

@implementation UIButton (Repeat)

- (void)repeatTouch:(NSTimeInterval)delay block:(void (^)())operation{
    
    self.userInteractionEnabled = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.userInteractionEnabled = YES;
        
        operation();
    });
}

@end
