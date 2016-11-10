/********************************************************************
 文件名称 : ResponseUtil.m 文件
 作   者 : Caffrey
 创建时间 : 16/4/14
 文件描述 : 类
 *********************************************************************/

#import "ResponseUtil.h"


@implementation ResponseUtil

- (instancetype)init
{
    self = [super init];
    if (self) {
        //状态和数据初始化.
        _state = RESPONSE_STATE_WAITEXE;
        _responseJson = nil;
        _responseResult = nil;
        _error = nil;
        _respDesc = nil;
        _respCode = nil;
    }
    return self;
}



@end
