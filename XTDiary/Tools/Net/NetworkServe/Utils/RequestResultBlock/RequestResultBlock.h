/********************************************************************
 文件名称 : TaskCallBackBlock.h 文件
 作   者 : Caffrey
 创建时间 : 16/4/14
 文件描述 : 类
 *********************************************************************/

#import <Foundation/Foundation.h>
#import "ResponseUtil.h"

typedef BOOL (^FinishBlock )(ResponseUtil *response);
typedef void (^FailBlock )(ResponseUtil *response);
typedef void (^ResultBlock )(ResponseUtil *response);

@interface RequestResultBlock : NSObject

@property(nonatomic, copy) FinishBlock successBlock;
@property(nonatomic, copy) FailBlock failBlock;
@property(nonatomic, copy) ResultBlock resultBlock;

/**
 *  重置block
 */
- (void)resetBlock;
@end
