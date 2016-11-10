/********************************************************************
 文件名称 : ResponseHandle.m 文件
 作   者 : Caffrey
 创建时间 : 16/3/18
 文件描述 : 类
 *********************************************************************/

#import "ResponseHandle.h"
#import "NSObject+PreventModel.h"
//#import "NSObject+YYModel.h"

@implementation ResponseHandle

+ (BOOL)responseVerifyWithResponseUtil:(ResponseUtil *)responseUtil dic:(NSDictionary *)dic {
    if (!dic) {
        return NO;
    }
    
    NSString *msg = dic[@"msg"];
    NSInteger code = [dic[@"code"] integerValue];
    responseUtil.respCode = [NSString stringWithFormat:@"%ld",(long)code];
    responseUtil.respDesc = msg;
    return code == 0;
}

+ (BOOL)responseVerifyAndVerifyLoginWithResponseUtil:(ResponseUtil *)responseUtil dic:(NSDictionary *)dic {
    if (!dic) {
        return NO;
    }
    
    NSString *msg = dic[@"msg"];
    NSInteger code = [dic[@"code"] integerValue];
    responseUtil.respCode = [NSString stringWithFormat:@"%ld",(long)code];
    responseUtil.respDesc = msg;
//网络错误代码
//    if (code == 3000) {
//        [[RFMemberCenterDataManager sharedManager] logout];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginViewViewNotification object:@(NO)];
//    }
    return code == 0;
}

+ (NSMutableArray *)modelArrayWithJSON:(id)json class:(Class)modelClass {
    NSArray *dataArray = [NSArray modelArrayWithClass:modelClass json:json];
    return  [dataArray mutableCopy];
}

+ (id)modelWithJSON:(id)json class:(Class)modelClass {
    return [modelClass modelWithJSON:json];
}
@end
