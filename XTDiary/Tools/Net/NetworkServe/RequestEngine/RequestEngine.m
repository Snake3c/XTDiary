/********************************************************************
 文件名称 :  requestEngine.m 文件
 作   者 : Caffrey
 创建时间 :16/4/29.
 文件描述 : 类
 ********************************************************************/

#import "RequestEngine.h"

#import "TaskSack.h"
#import "ResponseUtil.h"
#import "RequestUtil.h"
#import "RequestResultBlock.h"

#import "HttpResult.h"

#import "AFHTTPSessionManager.h"

#import <AFNetworking.h>

@interface RequestEngine () {
    AFHTTPSessionManager *manager;
}
@end

@implementation RequestEngine

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = ERRAND_TIMEOUT_INTERVAL;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];//设置返回数据为NSData
        manager.operationQueue.maxConcurrentOperationCount = ERRAND_MAX_OPERATION_COUNT;//最大并发数
        [manager.requestSerializer setHTTPShouldHandleCookies:YES];
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    return self;
}

+ (id)sharedInstance {
    
    static RequestEngine *sharedInstance = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)cancelOperation:(NSURLSessionTask *)operation {
    [operation cancel];
}

- (void)cancelAllOperations {
    NSOperationQueue *operationQueue = manager.operationQueue;
    [operationQueue cancelAllOperations];
}

#pragma mark ---------------------发送任务--------------------

- (void)getMethodToServiceOfService:(TaskSack *)taskSack {
    if (taskSack.cancelTask) {
        return;
    }
    
    NSMutableString *paramsStr = [NSMutableString string];
    [paramsStr appendString:@"?"];
    
    NSDictionary *paramsDic = taskSack.requestUtil.parameters;
    [paramsDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
        if (key || ![key isEqualToString:@""]) {
            [paramsStr appendFormat:@"%@=%@&",key,value];
        }
    }];
    
    NSString *url = [[NSString alloc]initWithFormat:@"%@%@",taskSack.requestUtil.ipUrl,paramsStr];
    
//    [CookieManager setCookieToAFNManager:manager];
    taskSack.operation = [manager GET:url
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                                  [CookieManager saveCookieWithUrl:url];
                                  HttpResult *httpResult = [[HttpResult alloc]init];
                                  [httpResult resultOfTaskSack:taskSack
                                                responseObject:responseObject
                                                         error:nil];
                                  httpResult = nil;
                              }
                              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                  [CookieManager saveCookieWithUrl:url];
                                  HttpResult *httpResult = [[HttpResult alloc]init];
                                  [httpResult resultOfTaskSack:taskSack
                                                responseObject:nil
                                                         error:error];
                                  httpResult = nil;
                              }
                          ];
}

- (void)postMethodToServiceOfService:(TaskSack *)taskSack
{
    if (taskSack.cancelTask) {
        return;
    }
    
    NSString *url = [[NSString alloc]initWithFormat:@"%@",taskSack.requestUtil.ipUrl];
    
    NSDictionary *parameters = taskSack.requestUtil.parameters;
//    [CookieManager setCookieToAFNManager:manager];
    taskSack.operation = [manager POST:url
                            parameters:parameters
                              progress:nil
                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                                   [CookieManager saveCookieWithUrl:url];
                                   HttpResult *httpResult = [[HttpResult alloc] init];
                                   
                                   [httpResult resultOfTaskSack:taskSack
                                                 responseObject:responseObject
                                                          error:nil];
                                   
                                   httpResult = nil;
                               }
                               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                   [CookieManager saveCookieWithUrl:url];
                                   HttpResult *httpResult = [[HttpResult alloc] init];
                                   
                                   [httpResult resultOfTaskSack:taskSack
                                                 responseObject:nil
                                                          error:error];
                                   
                                   httpResult = nil;
                               }
                          ];
    
}

- (void)uploadMethodToServiceOfService:(TaskSack *)taskSack
{
    if (taskSack.cancelTask) {
        return;
    }
    
    NSString *url = [[NSString alloc]initWithFormat:@"%@",taskSack.requestUtil.ipUrl];
    
    NSDictionary *parameters = taskSack.requestUtil.parameters;
    NSArray *files = taskSack.requestUtil.uploadFiles;
//    [CookieManager setCookieToAFNManager:manager];
    taskSack.operation = [manager POST:url
                            parameters:parameters
             constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                 [files enumerateObjectsUsingBlock:^(NSDictionary *file, NSUInteger idx, BOOL * _Nonnull stop) {
                     NSData *fileData = file[@"data"];
                     if (fileData && fileData != (id)kCFNull && [fileData isKindOfClass:[NSData class]]) {
                         [formData appendPartWithFileData:fileData
                                                     name:file[@"name"]
                                                 fileName:file[@"fileName"]
                                                 mimeType:file[@"mimeType"]];
                     }
                 }];
             }
                              progress:nil
                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                                   [CookieManager saveCookieWithUrl:url];
                                   HttpResult *httpResult = [[HttpResult alloc] init];
                                   
                                   [httpResult resultOfTaskSack:taskSack
                                                 responseObject:responseObject
                                                          error:nil];
                                   
                                   httpResult = nil;
                               }
                               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                   [CookieManager saveCookieWithUrl:url];
                                   HttpResult *httpResult = [[HttpResult alloc] init];
                                   
                                   [httpResult resultOfTaskSack:taskSack
                                                 responseObject:nil
                                                          error:error];
                                   
                                   httpResult = nil;
                               }
                          ];
    
}

@end
