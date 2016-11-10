/********************************************************************
 文件名称 :  TaskSack.m 文件
 作   者 : Caffrey
 创建时间 :16/4/28.
 文件描述 : 类
 ********************************************************************/

#import "TaskSack.h"


@implementation TaskSack

+ (TaskSack *)taskOfIpUrl:(NSString *)ipUrl
                  ipParam:(NSDictionary *)ipParam
                    files:(NSArray *)files
              resultBlock:(ResultBlock )resultBlock
             successBlock:(FinishBlock )successBlock
                failBlock:(FailBlock )failBlock
               identifier:(NSString *)identifier
                  groupId:(NSString *)groupId
              requestType:(REQUEST_TYPE )requestType {
    
    RequestResultBlock *requestResultBlock = [[RequestResultBlock alloc] init];
    
    requestResultBlock.resultBlock = resultBlock;
    requestResultBlock.successBlock = successBlock;
    requestResultBlock.failBlock = failBlock;
    
    RequestUtil *requestUtil = [[RequestUtil alloc] init];
    requestUtil.ipUrl = ipUrl;
    requestUtil.identifer = identifier;
    requestUtil.groupId = groupId;
    requestUtil.parameters = ipParam;
    requestUtil.uploadFiles = files == nil ? (id)kCFNull : files;
    requestUtil.requestType = requestType;
    
    TaskSack *task = [[TaskSack alloc] init];
    task.identifier = identifier;
    task.requestUtil = requestUtil;
    task.groupId = groupId;
    task.requestResultBlock = requestResultBlock;
    
    return task;
}

@end
