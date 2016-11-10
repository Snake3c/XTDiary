/********************************************************************
 文件名称 :  requestEngine.h 文件
 作   者 : Caffrey
 创建时间 :16/4/29.
 文件描述 : 类
********************************************************************/

#import <Foundation/Foundation.h>

@class ResponseUtil,RequestUtil,TaskSack;

@interface RequestEngine : NSObject

+ (id)sharedInstance;
- (void)cancelAllOperations;
- (void)cancelOperation:(NSURLSessionTask *)operation;
- (void)getMethodToServiceOfService:(TaskSack *)taskSack;
- (void)postMethodToServiceOfService:(TaskSack *)taskSack;

- (void)uploadMethodToServiceOfService:(TaskSack *)taskSack;
@end
