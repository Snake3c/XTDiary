/********************************************************************
 文件名称 : AsyncQueue.m 文件
 作   者 : Caffrey
 创建时间 : 16/3/17
 文件描述 : 类
 *********************************************************************/

#import "ErrandManager.h"
#import "Errand.h"
#import <UIKit/UIKit.h>

static CFMutableDictionaryRef requestQueque;
static CFMutableDictionaryRef requestGroupQueque;
static CFMutableDictionaryRef groupMonitorQueque;

@implementation ErrandManager {
    Boolean isMineCancel;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _networkActivityRetainCount = 0;
    }
    return self;
}

+ (instancetype)shareInstance {
    static ErrandManager *shareAsyncQueue = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^ {
        shareAsyncQueue = [[self alloc] init];
        requestQueque = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        requestGroupQueque = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        groupMonitorQueque = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    });
    
    return shareAsyncQueue;
}

- (void)addAsyncToQueue:(TaskSack *)taskSack {
    
    isMineCancel = YES;
    
    [self cancelRequestOfRequestId:taskSack.identifier];
    
    isMineCancel = NO;
    
    NSString *identifier = taskSack.identifier;
    CFDictionarySetValue(requestQueque, (__bridge const void *)(identifier), (__bridge const void *)(taskSack));
    
    [self addGroupRequest:taskSack];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    _networkActivityRetainCount++;
    
    [Errand errand:taskSack];
}

-(void)cancelRequestOfRequestId:(NSString *)identifer {
    
    TaskSack *taskSack = CFDictionaryGetValue(requestQueque, (__bridge const void *)(identifer));
    
    if (taskSack) {
        taskSack.cancelTask = YES;
        CFDictionaryRemoveValue(requestQueque, (__bridge const void *)(identifer));
        [self hiddenNetworkActivity];
    } else if (!isMineCancel) {
        DBLog(@"取消的请求ID不存在!");
    }
}

- (void)cancelRequestOfGroupId:(NSString *)groupId {
    if (!groupId || [groupId isEqualToString:@""]) return;
    
    NSMutableDictionary *groupDic = CFDictionaryGetValue(requestGroupQueque, (__bridge const void *)(groupId));
    
    if (groupDic) {
        
        NSArray *groupTasks = [groupDic allValues];
        __weak typeof(self) ws = self;
        [groupTasks enumerateObjectsUsingBlock:^(TaskSack *groupTask, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!groupTask) {
                return ;
            }
            [ws cancelRequestOfGroupId:groupTask.identifier];
        }];
        [groupDic removeAllObjects];
        CFDictionaryRemoveValue(requestGroupQueque, (__bridge const void *)(groupId));
        groupDic = nil;
        
        
    }
    
    [self finishGroup:groupId  state:GROUP_RESPONSE_STATE_CANCEL];
}

- (void)finishRequest:(TaskSack *)taskSack
{
    NSString *identifier = taskSack.identifier;
    CFDictionaryRemoveValue(requestQueque, (__bridge const void *)(identifier));
    
    [self hiddenNetworkActivity];
    [self finishGroupRequest:taskSack];
}

-(void)hiddenNetworkActivity
{
    if (_networkActivityRetainCount > 0) {
        
        _networkActivityRetainCount--;
    }
    
    if (_networkActivityRetainCount==0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)cancelAllRequests {
    NSArray *requsts = [((__bridge NSDictionary *)(requestQueque)) allValues];;
    
    [requsts enumerateObjectsUsingBlock:^(TaskSack *taskSack, NSUInteger idx, BOOL * _Nonnull stop) {
        taskSack.cancelTask = YES;
    }];
    
    CFDictionaryRemoveAllValues(requestQueque);
}

- (void)addGroupRequest:(TaskSack *)taskSack {
    if (!taskSack.groupId || [taskSack.groupId isEqualToString:@""]) {
        return;
    }
    
    NSMutableDictionary *groupDic = CFDictionaryGetValue(requestGroupQueque, (__bridge const void *)(taskSack.groupId));
    
    if (groupDic) {
        TaskSack *groupTask = groupDic[taskSack.identifier];
        if (groupTask) {
            [groupDic removeObjectForKey:taskSack.identifier];
        }
        
    } else {
        groupDic = [NSMutableDictionary dictionary];
        CFDictionarySetValue(requestGroupQueque, (__bridge const void *)(taskSack.groupId), (__bridge const void *)(groupDic));
    }
    
    [groupDic setObject:taskSack forKey:taskSack.identifier];
}

- (void)finishGroupRequest:(TaskSack *)taskSack {
    if (!taskSack.groupId || [taskSack.groupId isEqualToString:@""]) {
        return;
    }
    NSMutableDictionary *groupDic = CFDictionaryGetValue(requestGroupQueque, (__bridge const void *)(taskSack.groupId));
    
    if (groupDic) {
        TaskSack *groupTask = groupDic[taskSack.identifier];
        if (groupTask) {
            [groupDic removeObjectForKey:taskSack.identifier];
        }
        
        if (groupDic.count == 0) {
            [self finishGroup:taskSack.groupId state:GROUP_RESPONSE_STATE_FINISH];
        }
        
    } else {
        [self finishGroup:taskSack.groupId state:GROUP_RESPONSE_STATE_NONE];
    }
    
}

- (void)finishGroup:(NSString *)groupId state:(GROUP_RESPONSE_STATE)state{
    if (!groupId || [groupId isEqualToString:@""]) return;
    
    NSMutableArray *monitorArray = CFDictionaryGetValue(groupMonitorQueque, (__bridge const void *)(groupId));
    
    if (monitorArray)  {
        [monitorArray enumerateObjectsUsingBlock:^(GroupRequestFinish block, NSUInteger idx, BOOL * _Nonnull stop) {
            if (block) {
                block(state);
            }
        }];
        [monitorArray removeAllObjects];
        CFDictionaryRemoveValue(groupMonitorQueque, (__bridge const void *)(groupId));
        monitorArray = nil;
    }
    
}

- (void)addGroupMonitorWithGroupId:(NSString *)groupId handleBlock:(GroupRequestFinish)handleBlock {
    if (!groupId || [groupId isEqualToString:@""]) return;
    if (!handleBlock) return;
    
    NSMutableArray *monitorArray = CFDictionaryGetValue(groupMonitorQueque, (__bridge const void *)(groupId));
    
    if (!monitorArray)  {
        monitorArray = [NSMutableArray array];
        CFDictionarySetValue(groupMonitorQueque, (__bridge const void *)(groupId), (__bridge const void *)(monitorArray));
    }
    
    [monitorArray addObject:[handleBlock copy]];
}

@end
