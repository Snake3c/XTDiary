/********************************************************************
 文件名称 : HttpResult.m 文件
 作   者 : Caffrey
 创建时间 : 2016-6-16
 文件描述 : 类
 *********************************************************************/

#import "HttpResult.h"

//system

//modle
#import "RequestUtil.h"
#import "ResponseUtil.h"
#import "RequestResultBlock.h"
#import "TaskSack.h"

//other
//#import "ErrandError.h"
#import "ErrandManager.h"

#define ErrandErrorDomain @"com.errand"


@interface HttpResult()
{
    
}

@end

@implementation HttpResult

#pragma mark ---------------------退出清空--------------------
#pragma mark 释放
- (void)dealloc
{
    
}

#pragma mark ---------------------初始化----------------------
#pragma mark 初始化
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

#pragma mark ---------------------System---------------------
#pragma mark ---------------------功能函数--------------------
#pragma mark ---------------------手势事件--------------------
#pragma mark ---------------------按钮事件--------------------
#pragma mark ---------------------代理方法--------------------
#pragma mark ---------------------属性相关--------------------
#pragma mark ---------------------接口API--------------------

- (void)resultOfTaskSack:(TaskSack *)taskSack
          responseObject:(id)responseObject
                   error:(NSError *)error {
    
    if (!taskSack.cancelTask) {
        ResponseUtil *respsonseUtil = [[ResponseUtil alloc]init];
        taskSack.responseUtil = respsonseUtil;
        
        
        
        if (responseObject) {
            
            if ([responseObject isKindOfClass:[NSData class]]) {
                respsonseUtil.responseData = responseObject;
            }
            
            respsonseUtil.responseJson = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                         options:NSJSONReadingMutableLeaves
                                                                           error:nil];
            //DLog(@"\n**************%@***************\n%@\n",taskSack.identifier,respsonseUtil.responseJson);
        } else {
            //DLog(@"***********接口请求失败:responseObject为空***********");
        }
        
        respsonseUtil.error = error;
        
        
        if (error) {
            NSString *title = @"********错误信息!**********";
            
            if (error.code == NSURLErrorTimedOut) {
                
                title = @"请求超时!";
            }
            
            if (error.code == NSURLErrorNotConnectedToInternet) {
                
                title = @"没有网络连接!";
            }
            
            if (error.localizedDescription) {
                
                title = error.localizedDescription;
            }
            
            respsonseUtil.respDesc = [title copy];
        }
        
        if (!error && !taskSack.cancelTask) {
            BOOL dealState = taskSack.requestResultBlock.successBlock(respsonseUtil);
            
            if (dealState) {
                [self successOfRespsonseUtil:respsonseUtil];
            } else {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"data verify fail"                                                                      forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:ErrandErrorDomain
                                                     code:ERRAND_ERROR_DATA_VERIFY_FAIL
                                                 userInfo:userInfo];
                respsonseUtil.error = error;
                
                error = nil;
                
                [self failOfRespsonseUtil:respsonseUtil];
            }
        } else {
            taskSack.requestResultBlock.failBlock(respsonseUtil);
            
            [self failOfRespsonseUtil:respsonseUtil];
        }
        
        if (!taskSack.cancelTask) {
            taskSack.requestResultBlock.resultBlock(taskSack.responseUtil);
        }
    }
    
    [taskSack.requestResultBlock resetBlock];
    
    [[ErrandManager shareInstance] finishRequest:taskSack];
}

- (void)successOfRespsonseUtil:(ResponseUtil *)responseUtil {
    responseUtil.state = RESPONSE_STATE_SUCCESS;
}

- (void)failOfRespsonseUtil:(ResponseUtil *)responseUtil {
    responseUtil.state = RESPONSE_STATE_FAIL;
}

@end
