/********************************************************************
 文件名称 : HttpResult.h 文件
 作   者 : Caffrey
 创建时间 : 2016-4-16
 文件描述 : 处理http返回结果类
 *********************************************************************/

#import <Foundation/Foundation.h>

//system

//modle
@class ResponseUtil,RequestUtil,TaskSack;

//other

@interface HttpResult : NSObject
{
    
}

#pragma mark ---------------------退出清空--------------------
#pragma mark ---------------------初始化----------------------
#pragma mark ---------------------System---------------------
#pragma mark ---------------------功能函数--------------------
#pragma mark ---------------------手势事件--------------------
#pragma mark ---------------------按钮事件--------------------
#pragma mark ---------------------代理方法--------------------
#pragma mark ---------------------属性相关--------------------
#pragma mark ---------------------接口API--------------------

- (void)resultOfTaskSack:(TaskSack *)taskSack
          responseObject:(id)responseObject
                   error:(NSError *)error;


@end
