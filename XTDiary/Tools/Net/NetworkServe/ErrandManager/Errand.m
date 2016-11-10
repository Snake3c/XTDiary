/********************************************************************
 文件名称 :  Errand.m 文件
 作   者 : Caffrey
 创建时间 :16/4/29.
 文件描述 : 类
 ********************************************************************/

#import "Errand.h"
#import "RequestEngine.h"

@implementation Errand

+ (void)errand:(TaskSack *)taskSack {
    switch (taskSack.requestUtil.requestType) {
        case REQUEST_HTTP_GET: {
            RequestEngine *requestEngine = [RequestEngine sharedInstance];
            [requestEngine getMethodToServiceOfService:taskSack];
        } break;
        case REQUEST_HTTP_POST: {
            RequestEngine *requestEngine = [RequestEngine sharedInstance];
            [requestEngine postMethodToServiceOfService:taskSack];
        } break;
        case REQUEST_HTTP_POST_UPLOAD: {
            RequestEngine *requestEngine = [RequestEngine sharedInstance];
            [requestEngine uploadMethodToServiceOfService:taskSack];
        } break;
        default:
            break;
    }

}
+ (void)cancelErrand:(TaskSack *)taskSack {

    RequestEngine *requestEngine = [RequestEngine sharedInstance];
    [requestEngine cancelOperation:taskSack.operation];
}
+ (void)cancelAllErrands {
    RequestEngine *requestEngine = [RequestEngine sharedInstance];
    [requestEngine cancelAllOperations];
}
@end
