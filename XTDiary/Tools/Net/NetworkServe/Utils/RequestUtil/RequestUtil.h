/********************************************************************
 文件名称 : RequestUtil.h 文件
 作   者 : Caffrey
 创建时间 : 16/4/14
 文件描述 : 类
 *********************************************************************/

#import <Foundation/Foundation.h>
#import "ErrandCommon.h"

@interface RequestUtil : NSObject

@property (nonatomic, copy) NSString *ipUrl;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSDictionary *paramenterDic;
@property (nonatomic, strong) NSArray *uploadFiles;
@property (nonatomic, copy) NSString *identifer;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, assign) REQUEST_TYPE requestType;
@property (nonatomic, strong) id info;

@end
