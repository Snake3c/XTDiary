/********************************************************************
 文件名称 : RequestUtil.m 文件
 作   者 : Caffrey
 创建时间 : 16/4/14
 文件描述 : 类
 *********************************************************************/

#import "RequestUtil.h"


@implementation RequestUtil

- (instancetype)init
{
    self = [super init];
    if (self) {
        _identifer = nil;
        _requestType = REQUEST_HTTP_GET;
        _info = nil;
    }
    return self;
}

@end
