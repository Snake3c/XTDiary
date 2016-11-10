//
//  NSString+MD5.m
//  基础框架
//
//  Created by 叶慧伟 on 16/7/1.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

//md5 32位加密 （大写）
//lowercase 小写 uppercaseString 大写
+ (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[32];
    CC_MD5( cStr, (int)strlen(cStr), result );
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

/*
 得到的结果是 32位的MD5。。
 如果想得到16位的话，要这么做。
 NSString *md5String = [self md5HexDigest:String];
 //取中间16位
 subString = [md5String substringWithRange:NSMakeRange(8, 16)];
 
 查看了相关资料。发现一个问题，32位的和16位的 区别就是，32位的MD5 其实是在16位MD5 的前面和后面各加了8位。
 
 */
+ (NSString *)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    
    //取32位中间的16位md5值
    NSString *subString = [ret substringWithRange:NSMakeRange(8, 16)];
    
    return subString;
}


@end
