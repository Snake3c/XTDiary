//
//  UIImage+Compress.h
//  基础框架
//
//  Created by 叶慧伟 on 16/3/31.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compress)
//根据宽度压缩图片
- (UIImage *)scaleImageToWidth:(CGFloat)width;

- (UIImage *)scaleImageToSize:(CGSize)size;

@end
