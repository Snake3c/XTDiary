/********************************************************************
 文件名称 : AsyncQueue.h 文件
 作   者 : Caffrey
 创建时间 : 16/3/17
 文件描述 : 类
 *********************************************************************/

#import <Foundation/Foundation.h>
#import "TaskSack.h"

@interface ErrandManager : NSObject
+ (instancetype)shareInstance;

- (void)addAsyncToQueue:(TaskSack *)networkRequest;
- (void)finishRequest:(TaskSack *)taskSack;
- (void)cancelRequestOfRequestId:(NSString *)identifer;
- (void)cancelRequestOfGroupId:(NSString *)groupId;
- (void)cancelAllRequests;

- (void)addGroupMonitorWithGroupId:(NSString *)groupId handleBlock:(GroupRequestFinish)handleBlock;

@property (nonatomic, assign) NSUInteger networkActivityRetainCount;

@end
