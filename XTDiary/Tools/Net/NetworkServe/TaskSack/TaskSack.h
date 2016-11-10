/********************************************************************
 文件名称 :  TaskSack.h 文件
 作   者 : Caffrey
 创建时间 :16/4/28.
 文件描述 : 类
********************************************************************/

#import <Foundation/Foundation.h>
#import "RequestResultBlock.h"
#import "RequestUtil.h"
#import "ResponseUtil.h"
#import "ErrandCommon.h"

@interface TaskSack : NSObject

@property (nonatomic, strong) ResultBlock resultBlock;
@property (nonatomic, strong) RequestUtil *requestUtil;
@property (nonatomic, strong) ResponseUtil *responseUtil;
@property (nonatomic, strong) RequestResultBlock *requestResultBlock;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, assign) Boolean cancelTask;
@property (nonatomic, strong) NSURLSessionTask *operation;

+ (TaskSack *)taskOfIpUrl:(NSString *)ipUrl
                  ipParam:(NSDictionary *)ipParam
                    files:(NSArray *)files
              resultBlock:(ResultBlock )resultBlock
             successBlock:(FinishBlock )successBlock
                failBlock:(FailBlock )failBlock
               identifier:(NSString *)identifier
                  groupId:(NSString *)groupId
              requestType:(REQUEST_TYPE )requestType;

@end
