//
//  NSString+Regex.m
//  基础框架
//
//  Created by 叶慧伟 on 16/7/6.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "NSString+Regex.h"

@implementation NSString (Regex)

//校验手机号
+ (BOOL)isMobileNumber:(NSString *)mobileNum{
    
    NSString * MOBILE = @"^((0|)(13[0-9])|(15[^4,\\D])|(18[0-9])|(198))\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    return [regextestmobile evaluateWithObject:mobileNum];
}

//判断由字符和数字组成
+ (BOOL)isNumAndChar:(NSString *)str{
   
    NSString * inputStr = @"^\\w+$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", inputStr];
    
    return [regextestmobile evaluateWithObject:str];
}

//校验E-Mail
+ (BOOL)isEmailNumber:(NSString *)EmailNum{

    NSString * EMAIL = @"[\\w!#$%&'*+/=?^_`{|}~-]+(?:\\.[\\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\\w](?:[\\w-]*[\\w])?\\.)+[\\w](?:[\\w-]*[\\w])?";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", EMAIL];
    
    return [regextestmobile evaluateWithObject:EmailNum];
}

@end
