/********************************************************************
 文件名称 : TaskCallBackBlock.m 文件
 作   者 : Caffrey
 创建时间 : 16/4/14
 文件描述 : 类
 *********************************************************************/

#import "RequestResultBlock.h"

@implementation RequestResultBlock

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self resetBlock];
    }
    return self;
}

- (void)resetBlock
{
    _successBlock = nil;
    _failBlock = nil;
    _resultBlock = nil;
}

@end
