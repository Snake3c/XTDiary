//
//  NetworkRequest.m
//  myNetworkRequest
//
//  Created by newtouch on 14-7-14.
//  Copyright (c) 2014年 qiaoqiao.wu. All rights reserved.
//

#import "NetworkRequest.h"

#import <CommonCrypto/CommonHMAC.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>

#define TIMEOUTSECOND 15

@implementation NetworkRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.receiveData = [NSMutableData data];
    }
    return self;
};

-(void)cancleConnectionRequest:(NSURLConnection *)connection{

    NSData *data = [NSData data];
    [self.receiveData setData:data];
    
}
-(void)cancel:(NetworkRequest *)networkRequest
{
    [networkRequest.async cancel];
}
//+(void)requestDataWithUrl:(NSString *)url
//                   parameters:(id )parameters
//                successfulBlock:(FinishedBlock )finshedBlock
//                      failBlock:(FailerBlock )failBlock
//{
//    NetworkRequest *networkRequest = [[NetworkRequest alloc]init];
//    networkRequest.finishLoadingBlock = finshedBlock;
//    networkRequest.failWithErrorBlock = failBlock;
//    
//    NSData *dataRequest = [parameters dataUsingEncoding:NSUTF8StringEncoding];
// 
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//    request.timeoutInterval = TIMEOUTSECOND;
////    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
//    
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:[[NSNumber numberWithInteger:[dataRequest length]] stringValue] forHTTPHeaderField:@"Content-Length"];
//    [request setHTTPBody:dataRequest];
//    
//     NSURLConnection *asynConnection = [[NSURLConnection alloc] initWithRequest:request  delegate:networkRequest];
//    networkRequest.async = asynConnection;
//    [asynConnection start];
//    
//}

/*
+(NetworkRequest *)requestGetDataWithInterfacePath:(NSString *)path
                            parameters:(id)parameters
                              userInfo:(id)info
                       successfulBlock:(FinishBlock)finshedBlock
                             failBlock:(FailBlock)failBlock
{
    NetworkRequest *networkRequest = [[NetworkRequest alloc]init];
    networkRequest.finishLoadingBlock = finshedBlock;
    networkRequest.failWithErrorBlock = failBlock;
    
    NSString *requestStr = [NSString stringWithFormat:@"%@?%@",path,parameters];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestStr]];
    request.timeoutInterval = TIMEOUTSECOND;
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *asynConnection = [[NSURLConnection alloc] initWithRequest:request  delegate:networkRequest];
    networkRequest.async = asynConnection;
    [asynConnection start];
//    DLog(@"%@" ,asynConnection ? @"连接创建成功" : @"连接创建失败" );
     [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    return networkRequest;
}
*/


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    if (!self.receiveData) {
    
        self.receiveData = [[NSMutableData alloc]init];
        
    } else {
        
        [self.receiveData setLength:0];
        
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{

    if (self.finishLoadingBlock)
    {
        self.finishLoadingBlock(self.receiveData);
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [self.receiveData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    if (self.failWithErrorBlock) {
        self.failWithErrorBlock(error);
    }
}


/*
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
   
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        
        [[challenge sender]  useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        
        [[challenge sender]  continueWithoutCredentialForAuthenticationChallenge: challenge];
    }
}
*/

+ (BOOL )connectedToNetwork {
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;

}

//dictionary 转 json
-(NSString *)cStrWithDic:(NSMutableDictionary *)dictionary
{
    NSData *json = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    
    NSString *string = [[NSString alloc] initWithData:json
                                             encoding:NSUTF8StringEncoding];
    
    return string;
}


@end
