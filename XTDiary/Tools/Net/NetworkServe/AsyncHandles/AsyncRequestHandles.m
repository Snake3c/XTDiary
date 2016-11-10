/********************************************************************
 文件名称 :  AsyncHandles.m 文件
 作   者 : Caffrey
 创建时间 :16/4/29.
 文件描述 : 类
 ********************************************************************/

#import "AsyncRequestHandles.h"
#import "ResponseHandle.h"
#import "ErrandManager.h"
#import "TaskSack.h"
#import "ModelHeader.h"

#define kServiceAddress @"https://m.chaincar.com/"

@implementation AsyncRequestHandles

//获取首页公告
+ (void)getHomeNoticeWithParamters:(NSDictionary *)parameters
                           groupId:(NSString *)groupId
                        identifier:(NSString *)identifier
                         callBlock:(ResultBlock )resultBlock {
    [AsyncRequestHandles hanedleVerifyLogin:parameters
                                 identifier:identifier
                                    groupId:groupId
                                  callBlock:resultBlock
                                      chars:@"content/notice/titles.json"
                                requestType:REQUEST_HTTP_POST
                                     handle:^ResponseUtil *(ResponseUtil *responseUtil, NSDictionary *dic) {
                                         
                                        
                                         
                                         return responseUtil;
                                     }];
}


//  上传图片
//+ (void)uploadImageWithParamters:(NSDictionary *)parameters
//                       imageInfo:(NSDictionary *)imageInfo
//                      identifier:(NSString *)identifier
//                         groupId:(NSString *)groupId
//                       callBlock:(ResultBlock )resultBlock {
//    [AsyncRequestHandles uploadHanedle:parameters
//                             fileArray:@[imageInfo]
//                            identifier:identifier
//                               groupId:groupId
//                             callBlock:resultBlock
//                                 chars:@"shareItem/upload.html"
//                                handle:^ResponseUtil *(ResponseUtil *responseUtil, NSDictionary *dic) {
//                                    responseUtil.responseResult = [[ResponseHandle modelArrayWithJSON:dic[@"data"] class:[DTITItemModel class]] firstObject];;
//
//                                    return responseUtil;
//                                }];
//}

//  获取模板详情
//+ (void)getItemDetailWithParamters:(NSDictionary *)parameters
//                        identifier:(NSString *)identifier
//                           groupId:(NSString *)groupId
//                         callBlock:(ResultBlock )resultBlock {
//    [AsyncRequestHandles hanedleVerifyLogin:parameters
//                      identifier:identifier
//                         groupId:groupId
//                       callBlock:resultBlock
//                           chars:@"item/getDetail.html"
//                     requestType:REQUEST_HTTP_POST
//                          handle:^ResponseUtil *(ResponseUtil *responseUtil, NSDictionary *dic) {
//
//                              responseUtil.responseResult = [ResponseHandle modelWithJSON:dic[@"data"] class:[DTITItemDetailModel class]];
//
//                              return responseUtil;
//                          }];
//}

//  获取分类模板
//+ (void)getItemsByTagWithParamters:(NSDictionary *)parameters
//                        identifier:(NSString *)identifier
//                           groupId:(NSString *)groupId
//                         callBlock:(ResultBlock )resultBlock {
//    [AsyncRequestHandles hanedleVerifyLogin:parameters
//                      identifier:identifier
//                         groupId:groupId
//                       callBlock:resultBlock
//                           chars:@"item/getByTag.html"
//                     requestType:REQUEST_HTTP_POST
//                          handle:^ResponseUtil *(ResponseUtil *responseUtil, NSDictionary *dic) {
//
//                              responseUtil.responseResult = [ResponseHandle modelArrayWithJSON:dic[@"data"] class:[DTITItemModel class]];
//
//                              return responseUtil;
//                          }];
//}

#pragma mark ----------------------------------------- 业务处理封装 ----------------------------------------

+ (void)hanedle:(NSDictionary *)parameters
     identifier:(NSString *)identifier
        groupId:(NSString *)groupId
      callBlock:(ResultBlock )resultBlock
          chars:(NSString *)chars
    requestType:(REQUEST_TYPE)type
         handle:(HandleBlock )block {
    
    FinishBlock successfulBlock = ^(ResponseUtil *responseUtil) {
        NSDictionary *dic = responseUtil.responseJson;
        if ([ResponseHandle responseVerifyWithResponseUtil:responseUtil dic:dic]) {
            block(responseUtil,dic);
            return YES;
        } else {
            return NO;
        }
    };
    
    FailBlock failBlock = ^(ResponseUtil *responseUtil) {
        
    };
    
    NSString *ipUrl = [kServiceAddress stringByAppendingString:chars];
    
    TaskSack *taskSack = [TaskSack taskOfIpUrl:ipUrl
                                       ipParam:parameters
                                         files:nil
                                   resultBlock:resultBlock
                                  successBlock:successfulBlock
                                     failBlock:failBlock
                                    identifier:identifier
                                       groupId:groupId
                                   requestType:type];
    
    [[ErrandManager shareInstance] addAsyncToQueue:taskSack];
}

+ (void)hanedleVerifyLogin:(NSDictionary *)parameters
     identifier:(NSString *)identifier
        groupId:(NSString *)groupId
      callBlock:(ResultBlock )resultBlock
          chars:(NSString *)chars
    requestType:(REQUEST_TYPE)type
         handle:(HandleBlock )block {
    
    FinishBlock successfulBlock = ^(ResponseUtil *responseUtil) {
        NSDictionary *dic = responseUtil.responseJson;
        if ([ResponseHandle responseVerifyAndVerifyLoginWithResponseUtil:responseUtil dic:dic]) {
            block(responseUtil,dic);
            return YES;
        } else {
            return NO;
        }
    };
    
    FailBlock failBlock = ^(ResponseUtil *responseUtil) {
        
    };
    
    NSString *ipUrl = [kServiceAddress stringByAppendingString:chars];
    
    TaskSack *taskSack = [TaskSack taskOfIpUrl:ipUrl
                                       ipParam:parameters
                                         files:nil
                                   resultBlock:resultBlock
                                  successBlock:successfulBlock
                                     failBlock:failBlock
                                    identifier:identifier
                                       groupId:groupId
                                   requestType:type];
    
    [[ErrandManager shareInstance] addAsyncToQueue:taskSack];
}

+ (void)uploadHanedle:(NSDictionary *)parameters
            fileArray:(NSArray *)fileArray
           identifier:(NSString *)identifier
              groupId:(NSString *)groupId
            callBlock:(ResultBlock )resultBlock
                chars:(NSString *)chars
               handle:(HandleBlock )block {
    
    FinishBlock successfulBlock = ^(ResponseUtil *responseUtil) {
        NSDictionary *dic = responseUtil.responseJson;
        if ([ResponseHandle responseVerifyWithResponseUtil:responseUtil dic:dic]) {
            //responseUtil = block(responseUtil,dic);
            block(responseUtil,dic);
            return YES;
        } else {
            return NO;
        }
    };
    
    FailBlock failBlock = ^(ResponseUtil *responseUtil) {
        
    };
    
    NSString *ipUrl = [kServiceAddress stringByAppendingString:chars];
    
    TaskSack *taskSack = [TaskSack taskOfIpUrl:ipUrl
                                       ipParam:parameters
                                         files:fileArray
                                   resultBlock:resultBlock
                                  successBlock:successfulBlock
                                     failBlock:failBlock
                                    identifier:identifier
                                       groupId:groupId
                                   requestType:REQUEST_HTTP_POST_UPLOAD];
    
    [[ErrandManager shareInstance] addAsyncToQueue:taskSack];
}

#pragma mark --- 取消单个网络请求 ----
+ (void)cancelRequestForIdentifier:(NSString *)identifier {
    
    [[ErrandManager shareInstance] cancelRequestOfRequestId:identifier];
}

#pragma mark --- 取消所有网络请求 ----
+ (void)cancelAllRequest {
    
    [[ErrandManager shareInstance] cancelAllRequests];
}

#pragma mark --- 取消组网络请求 ----
+ (void)cancelRequestWithGroupId:(NSString *)groupId {
    [[ErrandManager shareInstance] cancelRequestOfGroupId:groupId];
}

#pragma mark --- 添加组监控 ----
+ (void)addRequestGroupMonitorWithGroupId:(NSString *)groupId handleBlock:(GroupRequestFinish)block {
    [[ErrandManager shareInstance] addGroupMonitorWithGroupId:groupId handleBlock:block];
}

//+ (NSDictionary *)addCommonParam:(NSDictionary *)param {
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setValuesForKeysWithDictionary:param];
//    [params setObject:@((NSInteger)[[NSDate date] timeIntervalSince1970] * 1000) forKey:@"trans_time"];
//    
//    [params setObject:@"ios" forKey:@"client_type"];
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    [params setObject:[infoDictionary objectForKey:@"CFBundleShortVersionString"] forKey:@"client_version"];
//    return params;
//}
@end
