//
//  NSString+MD5.h
//  基础框架
//
//  Created by 叶慧伟 on 16/7/1.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)

+ (NSString *)md5:(NSString *)str;
+ (NSString *)md5HexDigest:(NSString*)input;

@end
