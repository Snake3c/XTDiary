//
//  NSString+Regex.h
//  基础框架
//
//  Created by 叶慧伟 on 16/7/6.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Regex)
//校验手机号
+ (BOOL)isMobileNumber:(NSString *)mobileNum;
//判断由字符和数字组成
+ (BOOL)isNumAndChar:(NSString *)str;
//校验E-Mail
+ (BOOL)isEmailNumber:(NSString *)EmailNum;
@end
