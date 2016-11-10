/********************************************************************
 文件名称 : ResponseHandle.h 文件
 作   者 : Caffrey
 创建时间 : 16/3/18
 文件描述 : 类
 *********************************************************************/

#import <Foundation/Foundation.h>
#import "ResponseUtil.h"

@interface ResponseHandle : NSObject

+ (BOOL)responseVerifyWithResponseUtil:(ResponseUtil *)responseUtil dic:(NSDictionary *)dic;
+ (BOOL)responseVerifyAndVerifyLoginWithResponseUtil:(ResponseUtil *)responseUtil dic:(NSDictionary *)dic;

+ (NSMutableArray *)modelArrayWithJSON:(id)json class:(Class)modelClass;

+ (id)modelWithJSON:(id)json class:(Class)modelClass;
@end
