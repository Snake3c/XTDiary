/********************************************************************
 文件名称 :  Errand.h 文件
 作   者 : Caffrey
 创建时间 :16/4/29.
 文件描述 : 类
********************************************************************/

#import <Foundation/Foundation.h>
#import "TaskSack.h"
#import "ErrandCommon.h"

@interface Errand : NSObject

+ (void)errand:(TaskSack *)taskSack;
+ (void)cancelErrand:(TaskSack *)taskSack;
+ (void)cancelAllErrands;

@end
