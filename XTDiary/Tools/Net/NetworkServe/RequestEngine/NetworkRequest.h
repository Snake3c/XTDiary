//
//  NetworkRequest.h
//  myNetworkRequest
//
//  Created by newtouch on 14-7-14.
//  Copyright (c) 2014年 qiaoqiao.wu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FinishedBlock)(id receiveJSON);
typedef void (^FailerBlock)(NSError *error);
typedef Boolean (^finishblock)(id datastr);

@interface NetworkRequest : NSObject
<NSURLConnectionDataDelegate>

/**
 POST请求
 */
//+(void)requestDataWithUrl:(NSString *)url
//                           parameters:(id )parameters
//                      successfulBlock:(FinishedBlock )finshedBlock
//                            failBlock:(FailerBlock )failBlock;
/**
GET请求
 *
+(NetworkRequest *)requestGetDataWithInterfacePath:(NSString *)path
                            parameters:(id)parameters
                              userInfo:(id)info
                       successfulBlock:(FinishBlock)finshedBlock
                             failBlock:(FailBlock)failBlock;
*/
 

-(void)cancleConnectionRequest:(NSURLConnection *)connection;

-(void)cancel:(NetworkRequest *)networkRequest;

@property (nonatomic ,strong) NSURLConnection *async;

@property (nonatomic ,strong) NSMutableData *receiveData;
@property (nonatomic ,strong) FinishedBlock finishLoadingBlock;
@property (nonatomic ,strong) FailerBlock failWithErrorBlock;
@property (nonatomic ,strong) finishblock finishBlock;

@property (nonatomic ,assign) Boolean isHiddenLoading;

+ (BOOL )connectedToNetwork;
@end
