//
//  UIImage+Compress.m
//  基础框架
//
//  Created by 叶慧伟 on 16/3/31.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "UIImage+Compress.h"

@implementation UIImage (Compress)

- (UIImage *)scaleImageToWidth:(CGFloat)width{
    if (self.size.width < width) {
        return self;
    }
    CGFloat height = width * self.size.height / self.size.width;
    CGSize s = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(s);
    [self drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *resuleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resuleImage;
}

- (UIImage *)scaleImageToSize:(CGSize)size{
    if (CGSizeEqualToSize(self.size, size)) {
        return self;
    }
    CGFloat scaleFactor = 0.0;
    CGFloat widthFactor = size.width / self.size.width;
    CGFloat heightFactor = size.height / self.size.height;
    if (widthFactor < heightFactor) {
        scaleFactor = heightFactor;
    }else{
        scaleFactor = widthFactor;
    }
    scaleFactor = MIN(scaleFactor, 1.0);
    CGFloat targetWidth = self.size.width * scaleFactor;
    CGFloat targetHeight = self.size.height *scaleFactor;
    
    size = CGSizeMake(floorf(targetWidth), floorf(targetHeight));
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, ceilf(targetWidth), ceilf(targetHeight))];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    if (resultImage == nil) {
        resultImage = self;
    }
    UIGraphicsEndImageContext();
    return resultImage;
}

@end
