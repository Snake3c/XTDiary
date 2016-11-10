/********************************************************************
 文件名称 : ResponseUtil.h 文件
 作   者 : Caffrey
 创建时间 : 16/4/14
 文件描述 : 类
 *********************************************************************/

#import <Foundation/Foundation.h>
#import "ErrandCommon.h"

@interface ResponseUtil : NSObject
@property (nonatomic, assign) RESPONSE_STATE state;  //请求状态

@property (nonatomic, copy)  NSData *responseData; //数据包
@property (nonatomic, strong) id responseJson;   //rawJson
@property (nonatomic, strong) id responseResult; //
@property (nonatomic, copy) NSError *error;      //错误描述
@property (nonatomic, copy) NSString *respDesc;  //返回错误话术.
@property (nonatomic, copy) NSString *respCode;  //返回错误码.
@end
