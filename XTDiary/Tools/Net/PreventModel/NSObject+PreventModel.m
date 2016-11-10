//
//  NSObject+PreventModel.m
//  NewCreate
//
//  Created by 叶慧伟 on 16/10/16.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "NSObject+PreventModel.h"
#import "PreventClassInfo.h"
#import <objc/message.h>

#define force_inline __inline__ __attribute__((always_inline))




//  Foundation框架里的常用类枚举
typedef NS_ENUM(NSUInteger, PreventEncodingNSType) {
    PreventEncodingTypeNSUnknown = 0,
    PreventEncodingTypeNSString,
    PreventEncodingTypeNSMutableString,
    PreventEncodingTypeNSValue,
    PreventEncodingTypeNSNumber,
    PreventEncodingTypeNSDecimalNumber,
    PreventEncodingTypeNSData,
    PreventEncodingTypeNSMutableData,
    PreventEncodingTypeNSDate,
    PreventEncodingTypeNSURL,
    PreventEncodingTypeNSArray,
    PreventEncodingTypeNSMutableArray,
    PreventEncodingTypeNSDictionary,
    PreventEncodingTypeNSMutableDictionary,
    PreventEncodingTypeNSSet,
    PreventEncodingTypeNSMutableSet,
};

//  根据Class 获取Foundation框架中的类型枚举
static force_inline PreventEncodingNSType PreventClassGetNSType(Class cls){
    if (!cls) return PreventEncodingTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSMutableString class]])        return PreventEncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]])               return PreventEncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]])        return PreventEncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]])               return PreventEncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]])                return PreventEncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]])          return PreventEncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]])                 return PreventEncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]])                 return PreventEncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]])                  return PreventEncodingTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]])         return PreventEncodingTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]])                return PreventEncodingTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]])    return PreventEncodingTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]])           return PreventEncodingTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]])           return PreventEncodingTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]])                  return PreventEncodingTypeNSSet;
    return PreventEncodingTypeNSUnknown;
}

//  判断是否是 c number
static force_inline BOOL PreventEncodingTypeIsCNumber(PreventEncodingType type){
    switch (type & PreventEncodingTypeMask) {
        case PreventEncodingTypeBool:
        case PreventEncodingTypeInt8:
        case PreventEncodingTypeUInt8:
        case PreventEncodingTypeInt16:
        case PreventEncodingTypeUInt16:
        case PreventEncodingTypeInt32:
        case PreventEncodingTypeUInt32:
        case PreventEncodingTypeInt64:
        case PreventEncodingTypeUInt64:
        case PreventEncodingTypeFloat:
        case PreventEncodingTypeDouble:
        case PreventEncodingTypeLongDouble: return YES;
        default: return NO;
    }
}

//  转换NSNumber
static force_inline NSNumber *PreventNSNumberCreateFromID(__unsafe_unretained id value){
    //  字符集，用来判断value为字符串时，value中是否有字符 '.';
    static NSCharacterSet *dot;
    //  value是字符串时，用来修正value的值
    static NSDictionary *dic;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //  包含 '.' 字符的字符集
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        //  value是字符串，并且值如下左侧，右侧是修正值
        dic = @{
                @"TRUE" :   @(YES),
                @"True" :   @(YES),
                @"true" :   @(YES),
                @"FALSE" :  @(NO),
                @"False" :  @(NO),
                @"false" :  @(NO),
                @"YES" :    @(YES),
                @"Yes" :    @(YES),
                @"yes" :    @(YES),
                @"NO" :     @(NO),
                @"No" :     @(NO),
                @"no" :     @(NO),
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull
                };
    });
    
    //  是否为空
    if (!value || value == (id)kCFNull) return nil;
    //  如果是NSNumber直接返回
    if ([value isKindOfClass:[NSNumber class]]) return value;
    
    //  如果是字符串
    if ([value isKindOfClass:[NSString class]]) {
        //  获取字符串修正值
        NSNumber *number = dic[value];
        if (number) {
            if (number == (id)kCFNull) return nil;
            return number;
        }
        //  走到这里说明不在修正范围
        
        //  是否存在 ‘.’
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cString = ((NSString *)value).UTF8String;
            if (!cString) return nil;
            
            double num = atof(cString);
            //  判断浮点数是否是数字或者是否无穷大/小
            if (isnan(num) || isinf(num)) return nil;
            
            return @(num);
        } else {
            const char *cString = ((NSString *)value).UTF8String;
            if (!cString) return nil;
            
            return @(atoll(cString));
        }
    }
    
    return nil;
}

//  字符串转NSDate
static force_inline NSDate *PreventNSDateFromString(__unsafe_unretained NSString *string) {
    typedef NSDate * (^PreventNSDateParserBlock)(NSString *string);
#define kParserNum 34
    static PreventNSDateParserBlock blocks[kParserNum + 1] = {0};
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            /**
             *  长度为 10 的日期字符串解析 2014-01-20 ----> yyyy-MM-dd
             */
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIC"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            //  长度 10
            formatter.dateFormat = @"yyyy-MM-dd";
            blocks[10] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
        
        {
            /**
             *  2014-01-20 12:24:48
             *  2014-01-20T12:24:48   // Google
             *  2014-01-20 12:24:48.000
             *  2014-01-20T12:24:48.000
             */
            
            //  长度 19
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIC"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIC"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            
            //  长度 23
            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
            formatter3.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIC"];
            formatter3.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter3.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
            formatter4.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIC"];
            formatter4.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter4.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            
            blocks[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                }
                else
                {
                    return [formatter2 dateFromString:string];
                }
            };
            
            blocks[23] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter3 dateFromString:string];
                }
                else
                {
                    return [formatter4 dateFromString:string];
                }
            };
        }
        
        {
            /**
             *  2014-01-20T12:24:48Z        // Github, Apple
             *  2014-01-20T12:24:48+0800    // Facebook
             *  2014-01-20T12:24:48+12:00   // Google
             *  2014-01-20T12:24:48.000Z
             *  2014-01-20T12:24:48.000+0800
             *  2014-01-20T12:24:48.000+12:00
             */
            
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            
            blocks[20] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[24] = ^(NSString *string) {
                return [formatter dateFromString:string]? [formatter dateFromString:string] : [formatter2 dateFromString:string];
            };
            blocks[25] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[28] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
            blocks[29] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
        
        {
            /**
             *  Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
             *  Fri Sep 04 00:12:21.000 +0800 2015
             */
            
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z yyyy";
            
            blocks[30] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[34] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
    });
    
    if (!string) return nil;
    if (string.length > kParserNum) return nil;
    PreventNSDateParserBlock parserBlock = blocks[string.length];
    if (!parserBlock) return nil;
    return parserBlock(string);
    
#undef kParserNum
}

//  获取Block的真是类型Class
static force_inline Class PreventNSBlockClass() {
    static Class cls;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //  获取一个block
        void (^block)(void) = ^{};
        //  获取block的Class
        cls = ((NSObject *)block).class;
        //  循环找到Block的superClass
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    
    return cls;
}

/**
 *  获取 ISO 格式的date formatter
 *  ISO8601 formatter 格式示例：
 *
 *  2010-07-09T16:13:30+12:00
 *  2011-01-11T11:11:11+0000
 *  2011-01-26T19:06:43Z
 *
 *  length: 20/24/25
 *
 */
static force_inline NSDateFormatter *PreventISODateFormatter() {
    static NSDateFormatter *formatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    
    return formatter;
}

/**
 *  根据keyPaths在dictionary中取出value
 *
 *  @param dic      存储数据的Dictionary
 *  @param keyPaths 存储keyPaths的Array
 *
 *  @return 返回取出的值 或者 nil
 */
static force_inline id PreventValueForKeyPath(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *keyPaths) {
    id value = nil;
    
    //  根据keyPaths循环遍历dic,准确的说是 循环“拨开”dic这个“洋葱”
    for (NSUInteger i = 0, max = keyPaths.count; i < max ; i++) {
        //  根据key获取value
        value = dic[keyPaths[i]];
        //  如果当前不是最后一层
        if (i + 1 < max) {
            //  如果当前层还是字典
            if ([value isKindOfClass:[NSDictionary class]]) {
                //  把value赋值给dic用于后续的循环
                dic = value;
            }
            else
            {
                //  如果当前层不是字典，但当前层又不是最后一层，就返回nil，说明有错误
                return nil;
            }
        }
    }
    
    return value;
}

/**
 *  根据keyPaths或者key取值。
 *
 *  @param dic       存储数据的Dictionary
 *  @param multiKeys 两种类型：一、数组里存的是个字符串，则直接取值；二、数组里存的是数组，则按照keyPaths方式取值
 *
 *  @return 返回取出的值 或者 nil
 */
static force_inline id PreventValueForMultiKeys(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *multiKeys) {
    id value = nil;
    
    for (id key in multiKeys) {
        if ([key isKindOfClass:[NSString class]]) {
            //  如果是字符串，直接取出value
            value = dic[key];
            if (value) break;
        } else if ([value isKindOfClass:[NSArray class]]) {
            //  如果是数组，则按照keyPaths方式取值
            value = PreventValueForKeyPath(dic, (NSArray *)key);
            if (value) break;
        }
    }
    
    return value;
}

/**
 *  属性描述实体类
 */
@interface _PreventModelPropertyMeta : NSObject {
    @package
    
    /**
     *  属性名字
     */
    NSString *_name;
    /**
     *  属性的类型编码枚举值
     */
    PreventEncodingType _type;
    /**
     *  属性的Foundation类型
     */
    PreventEncodingNSType _nsType;
    /**
     *  是否是c语言数值类型
     */
    BOOL _isCNumber;
    /**
     *  属性变量的数据类型
     */
    Class _cls;
    /**
     *  属性变量是容器时 NSArray/NSSet/NSDictionary时，容器中元素对应的CLASS
     */
    Class _genericCls;
    /**
     *  属性的getter setter 方法
     */
    SEL _getter;
    SEL _setter;
    /**
     *  属性KVC
     */
    BOOL _isKVCCompatible;
    /**
     *  结构体类型是否支持归档
     */
    BOOL _isStructAvailableForKeyedArchiver;
    
    /**
     *  有没有根据一个JSON字典，获取对应配置的Class类型
     */
    BOOL _hasCustomClassFromDictionary;
    
    /**
     *  属性映射的json key
     */
    NSString *_mappedToKey;
    /**
     *  属性映射的json keyPath
     */
    NSArray *_mappedToKeyPath;
    /**
     *  属性映射是个数组，即一个属性映射多个json key
     */
    NSArray *_mappedToKeyArray;
    
    /**
     *  描述哪一个属性实例
     */
    PreventClassPropertyInfo *_info;
    /**
     *  每一个'属性描述对象'使用next指针，串联'另一个属性描述对象' 主要针对多个实体映射同一个json key
     */
    _PreventModelPropertyMeta *_next;
}

@end

@implementation _PreventModelPropertyMeta

+ (instancetype)metaWithClassInfo:(PreventClassInfo *)classInfo propertyInfo:(PreventClassPropertyInfo *)propertyInfo generic:(Class)generic {
    
    // support pseudo generic class with protocol name
    if (!generic && propertyInfo.protocols) {
        for (NSString *protocol in propertyInfo.protocols) {
            Class cls = objc_getClass(protocol.UTF8String);
            if (cls) {
                generic = cls;
                break;
            }
        }
    }
    
    _PreventModelPropertyMeta *meta = [self new];
    
    meta->_name = propertyInfo.name;
    meta->_type = propertyInfo.type;
    meta->_info = propertyInfo;
    meta->_genericCls = generic;
    
    if ((meta->_type & PreventEncodingTypeMask) == PreventEncodingTypeObject) {
        meta->_nsType = PreventClassGetNSType(propertyInfo.cls);
    } else {
        meta->_isCNumber = PreventEncodingTypeIsCNumber(meta->_type);
    }
    
    if ((meta->_type & PreventEncodingTypeMask) == PreventEncodingTypeStruct) {
        static NSSet *types = nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet *typeMSet = [NSMutableSet set];
            // 32 bit
            [typeMSet addObject:@"{CGSize=ff}"];
            [typeMSet addObject:@"{CGPoint=ff}"];
            [typeMSet addObject:@"{CGRect={CGPoint=ff}{CGSize=ff}}"];
            [typeMSet addObject:@"{CGAffineTransform=ffffff}"];
            [typeMSet addObject:@"{UIEdgeInsets=ffff}"];
            [typeMSet addObject:@"{UIOffset=ff}"];
            // 64 bit
            [typeMSet addObject:@"{CGSize=dd}"];
            [typeMSet addObject:@"{CGPoint=dd}"];
            [typeMSet addObject:@"{CGRect={CGPoint=dd}{CGSize=dd}}"];
            [typeMSet addObject:@"{CGAffineTransform=dddddd}"];
            [typeMSet addObject:@"{UIEdgeInsets=dddd}"];
            [typeMSet addObject:@"{UIOffset=dd}"];
            types = typeMSet;
        });
        
        //  只有上述类型的struct才能归档
        if ([types containsObject:propertyInfo.typeEncoding]) {
            meta->_isStructAvailableForKeyedArchiver = YES;
        }
    }
    
    meta->_cls = propertyInfo.cls;
    
    //  判断有没有根据一个JSON字典，获取对应配置的Class类型
    if (generic) {
        meta->_hasCustomClassFromDictionary = [generic respondsToSelector:@selector(modelCustomClassForDictionary:)];
    } else {
        meta->_hasCustomClassFromDictionary = [meta->_cls respondsToSelector:@selector(modelCustomClassForDictionary:)];
    }
    
    //  getter
    if (propertyInfo.getter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.getter]) {
            meta->_getter = propertyInfo.getter;
        }
    }
    //  setter
    if (propertyInfo.setter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.setter]) {
            meta->_setter = propertyInfo.setter;
        }
    }
    
    /**
     *  属性完成归档，必须实现getter与setter
     *
     *  不支持归档的数据类型
     *  1. long double
     *  2. CoreFundation 对象指针
     *  3. SEL
     *
     */
    if (meta->_getter && meta->_setter) {
        switch (meta->_type & PreventEncodingTypeMask) {
            case PreventEncodingTypeBool:
            case PreventEncodingTypeInt8:
            case PreventEncodingTypeUInt8:
            case PreventEncodingTypeInt16:
            case PreventEncodingTypeUInt16:
            case PreventEncodingTypeInt32:
            case PreventEncodingTypeUInt32:
            case PreventEncodingTypeInt64:
            case PreventEncodingTypeUInt64:
            case PreventEncodingTypeFloat:
            case PreventEncodingTypeDouble:
            case PreventEncodingTypeObject:
            case PreventEncodingTypeClass:
            case PreventEncodingTypeBlock:
            case PreventEncodingTypeStruct:
            case PreventEncodingTypeUnion: {
                meta->_isKVCCompatible = YES;
            } break;
            default: break;
        }
    }
    
    return meta;
}

@end

/**
 *  描述一个ClassModel实例
 */
@interface _PreventModelMeta : NSObject {
    @package
    
    PreventClassInfo *_classInfo;
    /**
     *  最终存放 json key 于 _PropertyMeta对象的映射关系字典
     */
    NSDictionary *_mapper;
    /**
     *  存放一个ClassModel对象所有的_PropertyMeta对象
     */
    NSArray *_allPropertyMetas;
    /**
     *  存放映射一个json keyPath 的_PropertyMeta对象
     */
    NSArray *_keyPathPropertyMetas;
    /**
     *  存放同事映射多个json key 的 _PropertyMeta对象
     */
    NSArray *_multiKeysPropertyMetas;
    /**
     *  映射的总数
     */
    NSUInteger _keyMappedCound;
    /**
     *  ClassInfo的Foundation类型
     */
    PreventEncodingNSType _nsType;
    
    BOOL _hasCustomWillTransformFromDictionary;
    BOOL _hasCustomTransformFromDictionary;
    BOOL _hasCustomTransformToDictionary;
    BOOL _hasCustomClassFromDictionary;
}

@end

@implementation _PreventModelMeta

/**
 *  使用传入的cls创建_ModelMeta对象，该方法做一下几件事情
 *  1. 调用modelPropertyBlacklist和modelPropertyWhitelist方法获取黑名单和白名单
 *  2. 调用modelContainerPropertyGenericClass方法获取容器类型的映射关系字典
 *  3. 根据黑名单和白名单筛选出对象的所有property
 *  4. 调用modelCustomPropertyMapper方法处理用户自定义的映射关系
 *  5. 处理除modelCustomPropertyMapper中自定义的映射以为的属性映射关系
 *
 *  @param cls cls
 *
 *  @return self
 */
- (instancetype)initWithClass:(Class)cls {
    PreventClassInfo *classInfo = [PreventClassInfo classInfoWithClass:cls];
    if (!classInfo) return nil;
    
    self = [super init];
    
    //  获取黑名单
    //  NSSet要比NSArray查询效率快，原因是NSSet直接根据hash值取值，如果在对存储顺序没有要求的地方可以用NSSet
    NSSet *blacklist = nil;
    if ([cls respondsToSelector:@selector(modelPropertyBlacklist)]) {
        NSArray *properties = [(id<PreventModel>)cls modelPropertyBlacklist];
        if (properties) {
            blacklist = [NSSet setWithArray:properties];
        }
    }
    
    //  白名单
    NSSet *whitelist = nil;
    if ([cls respondsToSelector:@selector(modelPropertyWhitelist)]) {
        NSArray *properties = [(id<PreventModel>)cls modelPropertyWhitelist];
        if (properties) {
            whitelist = [NSSet setWithArray:properties];
        }
    }
    
    //  获取容器类型property对应class
    NSDictionary *genericMapper = nil;
    if ([cls respondsToSelector:@selector(modelContainerPropertyGenericClass)]) {
        genericMapper = [(id<PreventModel>)cls modelContainerPropertyGenericClass];
        if (genericMapper) {
            NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
            [genericMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                // obj有两种可能 1.@”obj“是字符串 2.[obj class]是class对此昂
                
                //  key必须为NSString
                if (![key isKindOfClass:[NSString class]]) return ;
                //  object_getClass方法可以通过传入的obj的isa指针获取到一下两种Class：
                //  1. 类对象的Class,如果obj是字符串 则Class就是这种情况
                //  2. 类的MetaClass,如果obj是class对象，则class就是这种情况
                Class meta = object_getClass(obj);
                if (!meta) return;
                
                //  class_isMetaClass判断是发是metaclass
                if (class_isMetaClass(meta)) {
                    //  走到这里说明obj是class对象
                    //  obj就是对象的class,所以直接放入字典
                    tmpDic[key] = obj;
                } else if ([obj isKindOfClass:[NSString class]]) {
                    // 走到这里说明是obj字符串，然后通过字符串获取到class
                    Class cls = NSClassFromString(obj);
                    if (cls) {
                        tmpDic[key] = cls;
                    }
                }
            }];
            genericMapper = tmpDic;
        }
    }
    
    //  遍历对象所有的属性对应的PropertyMeta描述对象
    NSMutableDictionary *allPropertyMetas = [NSMutableDictionary dictionary];
    PreventClassInfo *curClassInfo = classInfo;
    //  遍历当前ClassInfo的所有PropertyInfo对象，创建对应的PropertyMeata对象
    //  循环停止条件superClass = nil,即superClass == NSObject或NSProxy
    while (curClassInfo && curClassInfo.superCls != nil) {
        //  循环遍历所有Class中的PropertyInfo
        for (PreventClassPropertyInfo *propertyInfo in curClassInfo.propertyInfos.allValues) {
            //  属性名是否存在
            if (!propertyInfo.name) continue;
            //  筛选是否在黑名单
            if (blacklist && [blacklist containsObject:propertyInfo.name]) continue;
            //  是否在白名单
            if (whitelist && ![whitelist containsObject:propertyInfo.name]) continue;
            //  创建PropertyMeta
            _PreventModelPropertyMeta *meta = [_PreventModelPropertyMeta metaWithClassInfo:curClassInfo
                                                                      propertyInfo:propertyInfo
                                                                           generic:genericMapper[propertyInfo.name]];
            if (!meta || !meta->_name) continue;
            if (!meta->_getter || !meta->_setter) continue;
            //  排除已存在的
            if (allPropertyMetas[meta->_name]) continue;
            
            allPropertyMetas[meta->_name] = meta;
        }
        //  获取superClass
        curClassInfo = curClassInfo.superClassInfo;
    }
    //  如果allPropertyMetas.count不等于0 则保存allPropertyMetas
    if (allPropertyMetas.count) _allPropertyMetas = allPropertyMetas.allValues.copy;
    
    //  创建json key 于 _PropertyMeta属性描述对象之间的映射关系
    
    //  保存 <'json key' : _PropertyMeta对象> 映射关系
    NSMutableDictionary *mapper            = [NSMutableDictionary dictionary];
    //  保存映射一个json keyPath的_propertyMeata对象
    NSMutableArray *keyPathPropertyMetas   = [NSMutableArray array];
    //  保存映射多个json key的_PropertyMeta对象
    NSMutableArray *multiKeysPropertyMetas = [NSMutableArray array];
    
    //  处理用户设置的自定义映射
    if ([cls respondsToSelector:@selector(modelCustomPropertyMapper)]) {
        /*  以下为自定义映射示例
         @{
         //属性名 : json key
         
         eg1. 属性名与json key 不一致
         @"page"  : @"p",
         
         eg2. 多个属性映射同一个json key
         @"name"  : @"n",
         @"title" : @"n",//title也映射n
         @"tip"   : @"n",//tip也映射n
         
         eg3. 一个属性映射一个json keyPath
         @"desc"  : @"ext.desc",
         
         eg4. 一个属性映射多个json key
         @"bookID": @[@"id", @"ID", @"book_id"]
         };
         */
        //  获取用户自定义的映射关系
        NSDictionary *customMapper = [(id<PreventModel>)cls modelCustomPropertyMapper];
        //  遍历映射
        [customMapper enumerateKeysAndObjectsUsingBlock:^(NSString * propertyName, NSString * mappedToKey, BOOL * _Nonnull stop) {
            //  取出对应的PropertyMeta对象
            _PreventModelPropertyMeta *propertyMeta = allPropertyMetas[propertyName];
            if (!propertyMeta) return;
            //  从PropertyMeta字典中移除propertyMeta
            [allPropertyMetas removeObjectForKey:propertyName];
            
            if ([mappedToKey isKindOfClass:[NSString class]]) {
                //  如果属性映射json key字符串，有以下几种情况
                //  一、@{@"name" : @"name"}      //  一一对应
                //  二、@{@"name" : @"user.name"} //  对应key path
                //  三、@{@"name" : @"name" , @"userName" : @"name"} //   多个属性对应一个json key
                if (mappedToKey.length == 0) return;
                //  直接保存json key，即为情况一
                propertyMeta->_mappedToKey = mappedToKey;
                //  用'.'进行分割，如果是keyPath即可分割出多个key，即为情况二
                NSArray *keyPath = [mappedToKey componentsSeparatedByString:@"."];
                for (NSString *onePath in keyPath) {
                    if (onePath.length == 0) {
                        NSMutableArray *tmp = keyPath.mutableCopy;
                        [tmp removeObject:@""];
                        keyPath = tmp;
                        break;
                    }
                }
                if (keyPath.count > 1) {
                    //  保存keyPath
                    propertyMeta->_mappedToKeyPath = keyPath;
                    //  meta添加到退役那个的keyPaths映射数组
                    [keyPathPropertyMetas addObject:propertyMeta];
                }
                //  是否能映射字典里取PropertyMeta对象，如果能说明是多一个属性映射一个jsonkey
                //  使用next指针串联同一个jsonkey对应的多个属性
                propertyMeta->_next = mapper[mappedToKey] ?: nil;
                //  保存映射
                mapper[mappedToKey] = propertyMeta;
                
            } else if ([mappedToKey isKindOfClass:[NSArray class]]) {
                //  如果jsonkey是数组,即为一个属性对应多个jsonkey,有以下情况
                // @{@"name" : @[@"name", @"userName", @"user.name"]}
                NSMutableArray *mappedToKeyArray = [NSMutableArray array];
                //  循环取出key
                for (NSString *oneKey in ((NSArray *)mappedToKey)) {
                    if (![oneKey isKindOfClass:[NSString class]]) continue;
                    if (oneKey.length == 0) continue;
                    //  判断是否是keyPath
                    NSArray *keyPath = [oneKey componentsSeparatedByString:@"."];
                    if (keyPath.count > 1) {
                        //  保存keyPath
                        [mappedToKeyArray addObject:keyPath];
                    } else {
                        //  不是keyPath，保存key
                        [mappedToKeyArray addObject:oneKey];
                    }
                    
                    //  将key保存到propertyMeta
                    //  只能保存第一个json key，后面的json key会放弃
                    if (!propertyMeta->_mappedToKey) {
                        propertyMeta->_mappedToKey = oneKey;
                        //  如果keyPath存在 保存keyPath
                        propertyMeta->_mappedToKeyPath = keyPath.count > 1 ? keyPath : nil;
                    }
                }
                //  属性没有任何映射
                if (!propertyMeta->_mappedToKey) return;
                //  保存所有json key映射数组
                propertyMeta->_mappedToKeyArray = mappedToKeyArray;
                [multiKeysPropertyMetas addObject:propertyMeta];
                
                propertyMeta->_next = mapper[mappedToKey] ?: nil;
                mapper[mappedToKey] = propertyMeta;
            }
            
        }];
    }
    
    //  用户自定义映射的属性都在上面从allPropertyMetas字典中删除
    //  allPropertyMetas字典中剩下的就是用户没有自定义映射的属性
    
    [allPropertyMetas enumerateKeysAndObjectsUsingBlock:^(NSString * name, _PreventModelPropertyMeta *propertyMeta, BOOL * _Nonnull stop) {
        //  映射的json key 直接就是属性名
        propertyMeta->_mappedToKey = name;
        //  处理多属性映射同一个keyjson
        propertyMeta->_next = mapper[name] ?: nil;
        mapper[name] = propertyMeta;
    }];
    
    if (mapper.count) _mapper = mapper;
    if (keyPathPropertyMetas) _keyPathPropertyMetas = keyPathPropertyMetas;
    if (multiKeysPropertyMetas) _multiKeysPropertyMetas = multiKeysPropertyMetas;
    
    _classInfo = classInfo;
    _keyMappedCound = _allPropertyMetas.count;
    _nsType = PreventClassGetNSType(cls);
    _hasCustomWillTransformFromDictionary = [cls instancesRespondToSelector:@selector(modelCustomWillTransformFromDictionary:)];
    _hasCustomTransformFromDictionary = [cls instancesRespondToSelector:@selector(modelCustomTransformFromDictionary:)];
    _hasCustomTransformToDictionary = [cls instancesRespondToSelector:@selector(modelCustomTransformToDictionary:)];
    _hasCustomClassFromDictionary = [cls instancesRespondToSelector:@selector(modelCustomClassForDictionary:)];
    
    return self;
}

+ (instancetype)metaWithClass:(Class)cls {
    if (!cls) return nil;
    
    //  创建一个CFMutableDictionaryRef用于缓存_PreventModelMeta对象
    static CFMutableDictionaryRef cache;
    static dispatch_once_t onceToken;
    //  同步信号量用于保证线程安全
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        //  创建字典
        cache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        //  创建同步信号
        lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    //  从缓存取出一个_PreventModelMeta对象
    _PreventModelMeta *meta = CFDictionaryGetValue(cache, (__bridge const void *)(cls));
    dispatch_semaphore_signal(lock);
    //  _PreventModelMeta对象不存在 或者 _PreventModelMeta对象需要更新
    if (!meta || meta->_classInfo.needUpdate) {
        //  新建一个_PreventModelMeta对象
        meta = [[_PreventModelMeta alloc] initWithClass:cls];
        if (meta) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(cache, (__bridge const void *)(cls), (__bridge const void *)(meta));
            dispatch_semaphore_signal(lock);
        }
    }
    
    return meta;
    
}

@end

/**
 *  获取number
 *
 *  @param model property的对象，不可为空
 *  @param meta  propertyMeta, meata.isCNumber必须是YES,meta.getter不可为空
 *
 *  @return number对象,或者nil
 */
static force_inline NSNumber *ModelCreatNumberFromeProperty(__unsafe_unretained id model,
                                                            __unsafe_unretained _PreventModelPropertyMeta *meta) {
    switch (meta->_type & PreventEncodingTypeMask) {
        case PreventEncodingTypeBool: {
            return @(((bool (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case PreventEncodingTypeInt8: {
            return @(((int8_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case PreventEncodingTypeUInt8: {
            return @(((uint8_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case PreventEncodingTypeInt16: {
            return @(((int16_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case PreventEncodingTypeUInt16: {
            return @(((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case PreventEncodingTypeInt32: {
            return @(((int32_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case PreventEncodingTypeUInt32: {
            return @(((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case PreventEncodingTypeInt64: {
            return @(((int64_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case PreventEncodingTypeUInt64: {
            return @(((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case PreventEncodingTypeFloat: {
            float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case PreventEncodingTypeDouble: {
            double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case PreventEncodingTypeLongDouble: {
            double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
            
        default: return nil;
    }
}
/**
 *  根据number设置property
 *
 *  @param model model，不可为空
 *  @param num   num，可以为空
 *  @param meta  propertyMeta, meata.isCNumber必须是YES,meta.getter不可为空
 *
 */
static force_inline void ModelSetNumberToProperty(__unsafe_unretained id model,
                                                  __unsafe_unretained NSNumber *num,
                                                  __unsafe_unretained _PreventModelPropertyMeta *meta) {
    switch (meta->_type & PreventEncodingTypeMask) {
        case PreventEncodingTypeBool: {
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)model, meta->_setter, num.boolValue);
        } break;
        case PreventEncodingTypeInt8: {
            ((void (*)(id, SEL, int8_t))(void *) objc_msgSend)((id)model, meta->_setter, (int8_t)num.charValue);
        } break;
        case PreventEncodingTypeUInt8: {
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint8_t)num.unsignedCharValue);
        } break;
        case PreventEncodingTypeInt16: {
            ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)model, meta->_setter, (int16_t)num.shortValue);
        } break;
        case PreventEncodingTypeUInt16: {
            ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint16_t)num.unsignedShortValue);
        } break;
        case PreventEncodingTypeInt32: {
            ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)((id)model, meta->_setter, (int32_t)num.intValue);
        } break;
        case PreventEncodingTypeUInt32: {
            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint32_t)num.unsignedIntValue);
        } break;
        case PreventEncodingTypeInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model, meta->_setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint64_t)num.longLongValue);
            }
        } break;
        case PreventEncodingTypeUInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model, meta->_setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint64_t)num.unsignedLongLongValue);
            }
        } break;
        case PreventEncodingTypeFloat: {
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)model, meta->_setter, f);
        } break;
        case PreventEncodingTypeDouble: {
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)model, meta->_setter, d);
        } break;
        case PreventEncodingTypeLongDouble: {
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)model, meta->_setter, d);
        } break;
        default:  break;
    }
}

/**
 *  将value转成属性
 *  应该强引用参数在这个方法返回去之前
 *
 *  @param model 不可为空
 *  @param value 不可为空，但可以为NSNull
 *  @param meta  不可为空，并且setter方法必须存在
 */
static void ModelSetValueForProperty(__unsafe_unretained id model, __unsafe_unretained id value, __unsafe_unretained _PreventModelPropertyMeta *meta) {
    if (meta->_isCNumber) {
        //  属性为基础数字类型
        //  value >>> number
        NSNumber *num = PreventNSNumberCreateFromID(value);
        //  将nuber设置给实体属性
        ModelSetNumberToProperty(model, num, meta);
        if (num) [num class];//TODO: 疑惑: 为什么写这一句了？作者解释: hold the number
    } else if (meta->_nsType) {
        //  属性是foundation class
        if (value == (id)kCFNull) {
            //  为空
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)nil);
        } else {
            switch (meta->_nsType) {
                case PreventEncodingTypeNSString:
                case PreventEncodingTypeNSMutableString: {
                    if ([value isKindOfClass:[NSString class]]) {
                        if (meta->_nsType == PreventEncodingTypeNSString) {
                            //  是NSString
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           value);
                        } else {
                            //  NSMutableString
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           ((NSString *)value).mutableCopy);
                            
                        }
                    } else if ([value isKindOfClass:[NSNumber class]]) {
                        //  NSNumber
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       meta->_nsType == PreventEncodingTypeNSString ?
                                                                       ((NSNumber *)value).stringValue :
                                                                       ((NSNumber *)value).stringValue.mutableCopy);
                        
                    } else if ([value isKindOfClass:[NSData class]]) {
                        //  NSData
                        NSMutableString *string = [[NSMutableString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       string);
                        
                    } else if ([value isKindOfClass:[NSAttributedString class]]) {
                        //  NSAttributedString
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       meta->_nsType == PreventEncodingTypeNSString ?
                                                                       ((NSAttributedString *)value).string :
                                                                       ((NSAttributedString *)value).string.mutableCopy);
                        
                    } else if ([value isKindOfClass:[NSURL class]]) {
                        //  NSURL
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       meta->_nsType == PreventEncodingTypeNSString ?
                                                                       ((NSURL *)value).absoluteString :
                                                                       ((NSURL *)value).absoluteString.mutableCopy);
                        
                    }
                } break;
                    
                case PreventEncodingTypeNSValue:
                case PreventEncodingTypeNSNumber:
                case PreventEncodingTypeNSDecimalNumber: {
                    if (meta->_nsType == PreventEncodingTypeNSNumber) {
                        //  NSNumber
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       PreventNSNumberCreateFromID(value));
                        
                    } else if (meta->_nsType == PreventEncodingTypeNSDecimalNumber) {
                        //  NSDecimalNumber
                        if ([value isKindOfClass:[NSDecimalNumber class]]) {
                            //  value is NSDecimalNumber
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           value);
                            
                        } else if ([value isKindOfClass:[NSNumber class]]) {
                            //  value is NSNumber
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[((NSNumber *)value) decimalValue]];
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           decNum);
                            
                        } else if ([value isKindOfClass:[NSString class]]) {
                            //  value is NSString
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithString:value];
                            NSDecimal dec = decNum.decimalValue;
                            if (dec._length == 0 && dec._isNegative) {
                                decNum = nil;
                            }
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           decNum);
                            
                        }
                    } else {
                        //  NSValue
                        if ([value isKindOfClass:[NSValue class]]) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           value);
                        }
                    }
                } break;
                    
                case PreventEncodingTypeNSData:
                case PreventEncodingTypeNSMutableData: {
                    if ([value isKindOfClass:[NSData class]]) {
                        //  value is NSData
                        if (meta->_nsType == PreventEncodingTypeNSData) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           value);
                            
                        } else {
                            NSMutableData *data = ((NSData *)value).mutableCopy;
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           data);
                            
                        }
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                        if (meta->_nsType == PreventEncodingTypeNSMutableData) {
                            data = ((NSData *)data).mutableCopy;
                        }
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       data);
                    }
                } break;
                    
                case PreventEncodingTypeNSDate: {
                    if ([value isKindOfClass:[NSDate class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       value);
                        
                    } else if ([value isKindOfClass:[NSString class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       PreventNSDateFromString(value));
                        
                    }
                } break;
                    
                case PreventEncodingTypeNSURL: {
                    if ([value isKindOfClass:[NSURL class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       value);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        //  去掉字符串中的多余空格
                        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                        NSString *str = [value stringByTrimmingCharactersInSet:set];
                        if (str.length == 0) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           nil);
                        } else {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           [[NSURL alloc] initWithString:str]);
                        }
                    }
                } break;
                    
                case PreventEncodingTypeNSArray:
                case PreventEncodingTypeNSMutableArray: {
                    if (meta->_genericCls) {
                        //  是否有数组中的元素的class
                        NSArray *valueArray = nil;
                        if ([value isKindOfClass:[NSArray class]]) {
                            valueArray = value;
                        } else if ([value isKindOfClass:[NSSet class]]) {
                            valueArray = ((NSSet *)value).allObjects;
                        }
                        
                        if (valueArray) {
                            //  将value >>> generic Object
                            //  新建一个保存对象的数组
                            NSMutableArray *objectArray = [NSMutableArray new];
                            for (id item in valueArray) {
                                if ([item isKindOfClass:meta->_genericCls]) {
                                    [objectArray addObject:item];
                                } else if ([item isKindOfClass:[NSDictionary class]]) {
                                    //  数组的item的Class 是字典
                                    Class cls = meta->_genericCls;
                                    
                                    //先使用用户设置的修正字典的Class
                                    //使用 -[NSObject mapping_objectClassForJSONDictionary:] 传入当前字典对象，得到的对应Class
                                    if (meta->_hasCustomClassFromDictionary) {
                                        cls = [cls modelCustomClassForDictionary:item];
                                        if (!cls) cls = meta->_genericCls;
                                    }
                                    
                                    NSObject *newObject = [cls new];
                                    [newObject modelSetWithDictionary:item];
                                    if (newObject) [objectArray addObject:newObject];
                                }
                            }
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           objectArray);
                        }
                        
                    } else {
                        if ([value isKindOfClass:[NSArray class]]) {
                            if (meta->_nsType == PreventEncodingTypeNSArray) {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                               meta->_setter,
                                                                               value);
                            } else {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                               meta->_setter,
                                                                               ((NSArray *)value).mutableCopy);
                            }
                        } else if ([value isKindOfClass:[NSSet class]]) {
                            if (meta->_nsType == PreventEncodingTypeNSArray) {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                               meta->_setter,
                                                                               ((NSSet *)value).allObjects);
                            } else {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                               meta->_setter,
                                                                               ((NSSet *)value).allObjects.mutableCopy);
                            }
                        }
                    }
                } break;
                    
                case PreventEncodingTypeNSDictionary:
                case PreventEncodingTypeNSMutableDictionary: {
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        //  是否有容器类对应的class设置
                        if (meta->_genericCls) {
                            //  设置了_genericCls
                            NSMutableDictionary *objectDic = [NSMutableDictionary new];
                            //  value >>> objectDic
                            [(NSDictionary *)value enumerateKeysAndObjectsUsingBlock:^(NSString *itemKey, id itemValue, BOOL * _Nonnull stop) {
                                if ([itemValue isKindOfClass:[NSDictionary class]]) {
                                    Class cls = meta->_genericCls;
                                    //  获取用户自定义的字典对应的class
                                    if (meta->_hasCustomClassFromDictionary) {
                                        cls = [cls modelCustomClassForDictionary:itemValue];
                                        if (!cls) cls = meta->_genericCls;
                                    }
                                    NSObject *newObject = [cls new];
                                    [newObject modelSetWithDictionary:(id)itemValue];
                                    if (newObject) objectDic[itemKey] = newObject;
                                }
                            }];
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, objectDic);
                        } else {
                            //  没有设置_genericCls
                            if (meta->_nsType == PreventEncodingTypeNSDictionary) {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                            } else {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, ((NSDictionary *)value).mutableCopy);
                            }
                        }
                    }
                } break;
                    
                case PreventEncodingTypeNSSet:
                case PreventEncodingTypeNSMutableSet: {
                    NSSet *valueSet = nil;
                    if ([value isKindOfClass:[NSArray class]]) {
                        valueSet = [NSMutableSet setWithArray:value];
                    } else if ([valueSet isKindOfClass:[NSSet class]]) {
                        valueSet = (NSSet *)value;
                    }
                    
                    //  是否存在容器类对应的_genericCls
                    if (meta->_genericCls) {
                        //  存在_genericCls
                        //  value >>> objectSet
                        NSMutableSet *objectSet = [NSMutableSet new];
                        for (id item in valueSet) {
                            
                            if ([item isKindOfClass:meta->_genericCls]) {
                                //  类型相同直接赋值
                                [objectSet addObject:item];
                            } else if ([item isKindOfClass:[NSDictionary class]]) {
                                //  如果是字典
                                Class cls = meta->_genericCls;
                                if (meta->_hasCustomClassFromDictionary) {
                                    //  后去自定义字典对应的class
                                    cls = [cls modelCustomClassForDictionary:item];
                                    if (!cls) cls = meta->_genericCls;
                                }
                                //  新建对象
                                NSObject *newObject = [cls new];
                                //  转换字典
                                [newObject modelSetWithDictionary:item];
                                if (newObject) [objectSet addObject:newObject];
                            }
                        }
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, objectSet);
                    } else {
                        if (meta->_nsType == PreventEncodingTypeNSSet) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           valueSet);
                        } else {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                           meta->_setter,
                                                                           ((NSSet *)valueSet).mutableCopy);
                        }
                    }
                    
                } break;
                default: break;
            }
        }
    } else {
        //  是否为空
        BOOL isNull = (value == (id)kCFNull);
        switch (meta->_type & PreventEncodingTypeMask) {
            case PreventEncodingTypeObject: {
                //  自定义的class类型
                if (isNull) {
                    //  为空
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)nil);
                } else if ([value isKindOfClass:meta->_cls] || !meta->_cls) {
                    //  类型匹配配置的Class
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)value);
                } else if ([value isKindOfClass:[NSDictionary class]]) {
                    //  字典
                    NSObject *newObject = nil;
                    if (meta->_getter) {
                        //  是否能获取到值，不知道为什么要加这句
                        newObject = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
                    }
                    if (newObject) {
                        //  根据字典解析出对象
                        [newObject modelSetWithDictionary:value];
                    } else {
                        Class cls = meta->_cls;
                        if (meta->_hasCustomClassFromDictionary) {
                            cls = [cls modelCustomClassForDictionary:value];
                            if (!cls) cls = meta->_genericCls;
                        }
                        
                        newObject = [cls new];
                        [newObject modelSetWithDictionary:value];
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)newObject);
                    }
                }
            } break;
                
            case PreventEncodingTypeClass: {
                if (isNull) {
                    ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)NULL);
                } else {
                    Class cls = nil;
                    if ([value isKindOfClass:[NSString class]]) {
                        cls = NSClassFromString(value);
                        if (cls) {
                            ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)cls);
                        }
                    } else {
                        cls = object_getClass(value);
                        if (cls) {
                            if (class_isMetaClass(cls)) {
                                //  如果得到的Class是元类，说明value本身就是Class
                                ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)value);
                            }
                        }
                    }
                }
            } break;
                
            case PreventEncodingTypeSEL: {
                if (isNull) {
                    ((void (*)(id, SEL, void (^)()))(void *) objc_msgSend)((id)model, meta->_setter, (void (^)())NULL);
                } else if ([value isKindOfClass:PreventNSBlockClass()]) {
                    ((void (*)(id, SEL, void (^)()))(void *) objc_msgSend)((id)model, meta->_setter, (void (^)())value);
                }
                
            } break;
                
            case PreventEncodingTypeStruct:
            case PreventEncodingTypeUnion:
            case PreventEncodingTypeCArray: {
                //  c类型需要使用NSValue包装
                
                if ([value isKindOfClass:[NSValue class]]) {
                    //  获取传入值得类型编码
                    const char *valueType = ((NSValue *)value).objCType;
                    //  属性类型的编码
                    const char *metaType = meta->_info.typeEncoding.UTF8String;
                    //  比较是否相同
                    if (valueType && metaType && strcmp(valueType, metaType) == 0) {
                        //  结构体实例使用KVC设置给属性变量
                        [model setValue:value forKey:meta->_name];
                    }
                }
            } break;
                
            case PreventEncodingTypePointer:
            case PreventEncodingTypeCString: {
                if (isNull) {
                    ((void (*)(id, SEL, void *))(void *) objc_msgSend)((id)model, meta->_setter, (void *)NULL);
                } else {
                    NSValue *nsValue = value;
                    // 判断传入值的类型，是否是 void* 指针类型
                    // TODO: 为什么CString要按照void*指针类型了？
                    // 因为 [NSValue valueWithPointer:(nullable const void *)]; 将传入的指针转换成 void* 类型了
                    // 所以再通过NSValue获取到指针的类型时，就是 void* ，而其编码就是 `^v`
                    if (nsValue.objCType && strcmp(nsValue.objCType, "^v") == 0) {
                        ((void (*)(id, SEL, void *))(void *) objc_msgSend)((id)model, meta->_setter, nsValue.pointerValue);
                    }
                }
            } break;
                
            default: break;
        }
    }
}

/**
 *  c结构体，用来打包 实体类对象、实体类Class的ClassMeta描述、要设置的字典对象
 */
typedef struct {
    void *modelMeta;    //  _PreventModelMeta 实体类Class的描述类
    void *model;        //  id (self) 设置给哪个实体类对象
    void *dictionary;   //  NSDictionary (json) json字典
} ModelSetContext;

/**
 *  将value根据jsonkey设置给一个实体类对象
 *
 *  @param _key     jsonkey
 *  @param _value   要设置的value
 *  @param _context 接受value的model内容描述
 */
static void ModelSetWithDictionaryFunction(const void *_key, const void *_value, void *_context) {
    ModelSetContext *context = (ModelSetContext *)_context;
    //  获取Class描述
    __unsafe_unretained _PreventModelMeta *meta = (__bridge _PreventModelMeta *)context->modelMeta;
    //  从meta里获取映射字典_mapper，获取jsonkey对应的propertyMeta对象
    __unsafe_unretained _PreventModelPropertyMeta *propertyMeta = [meta->_mapper objectForKey:(__bridge id)(_key)];
    //  实体类对象
    __unsafe_unretained id model = (__bridge id)context->model;
    //  如果多个不同属性映射同一个json
    while (propertyMeta) {
        if (propertyMeta->_setter) {
            ModelSetValueForProperty(model, (__bridge __unsafe_unretained id)_value, propertyMeta);
        }
        propertyMeta = propertyMeta->_next;
    }
}

static void ModelSetWithPropertyMetaArrayFunction(const void *_propertyMeta, void *_context) {
    ModelSetContext *context = _context;
    __unsafe_unretained NSDictionary *dictionary = (__bridge NSDictionary *)(context->dictionary);
    __unsafe_unretained _PreventModelPropertyMeta *propertyMeta = (__bridge _PreventModelPropertyMeta *)(_propertyMeta);
    if (!propertyMeta->_setter) return;
    id value = nil;
    
    if (propertyMeta->_mappedToKeyArray) {
        //  根据_mappedToKeyArray取出值
        value = PreventValueForMultiKeys(dictionary, propertyMeta->_mappedToKeyArray);
    } else if (propertyMeta->_mappedToKeyPath) {
        //  根据_mappedToKeyPath取出值
        value = PreventValueForKeyPath(dictionary, propertyMeta->_mappedToKeyPath);
    } else {
        //  直接取值
        value = [dictionary objectForKey:propertyMeta->_mappedToKey];
    }
    
    if (value) {
        __unsafe_unretained id model = (__bridge id)(context->model);
        ModelSetValueForProperty(model, value, propertyMeta);
    }
}

/**
 *  返回一个有效的json对象(NSArray/NSDictionary/NSString/NSNumber/NSNull) 或者 nil
 *
 *  @param model model,可为空
 *
 *  @return JSON object
 */
static id ModelToJSONObjectRecursive(NSObject *model) {
    //  如果为空/空对象/NSString/NSNumber 都直接返回
    if (!model || model == (id)kCFNull) return model;
    if ([model isKindOfClass:[NSString class]]) return model;
    if ([model isKindOfClass:[NSNumber class]]) return model;
    
    //  NSDictionary
    if ([model isKindOfClass:[NSDictionary class]]) {
        //  如果已经是JSON格式，直接返回
        if ([NSJSONSerialization isValidJSONObject:model]) return model;
        //  newDic 用于保存修正后的字典
        NSMutableDictionary *newDic = [NSMutableDictionary new];
        //  遍历
        [((NSDictionary *)model) enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            //  对key进行处理
            NSString *stringKey = [key isKindOfClass:[NSString class]] ? key : key.description;//使用NSObject实例的description获取其字符串描述
            if (!stringKey) return ;
            //  递归调用处理obj
            id jsonObj = ModelToJSONObjectRecursive(obj);
            if (!jsonObj) jsonObj = (id)kCFNull;
            //  保存
            newDic[stringKey] = jsonObj;
        }];
        //  返回修正过的字典
        return newDic;
    }
    
    //  NSSet >>> NSArray 转换后做处理
    if ([model isKindOfClass:[NSSet class]]) {
        //  NSSet >>> NSArray
        NSArray *array = ((NSSet *)model).allObjects;
        //  如果已经是合格的json数据 直接返回
        if ([NSJSONSerialization isValidJSONObject:array]) return array;
        
        NSMutableArray *newArray = [NSMutableArray new];
        for (id obj in array) {
            //  循环处理
            //  如果是NSString 和 NSNumber直接保存
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [newArray addObject:obj];
            } else {
                //  递归处理obj
                id jsonObj = ModelToJSONObjectRecursive(obj);
                //  保存
                if (jsonObj && jsonObj != (id)kCFNull) [newArray addObject:jsonObj];
            }
        }
        //  返回修正过的数组
        return newArray;
    }
    
    //  NSArray 处理过程同NSSet
    if ([model isKindOfClass:[NSArray class]]) {
        if ([NSJSONSerialization isValidJSONObject:model]) return model;
        NSMutableArray *newArray = [NSMutableArray new];
        for (id obj in (NSArray *)model) {
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [newArray addObject:obj];
            } else {
                id jsonObj = ModelToJSONObjectRecursive(obj);
                if (jsonObj && jsonObj != (id)kCFNull) [newArray addObject:jsonObj];
            }
        }
        
        return newArray;
    }
    
    //  NSURL/NSAttributedString/NSDate >>> NSString 转成成NSString返回
    if ([model isKindOfClass:[NSURL class]]) return ((NSURL *)model).absoluteString;
    if ([model isKindOfClass:[NSAttributedString class]]) return ((NSAttributedString *)model).string;
    if ([model isKindOfClass:[NSDate class]]) return [PreventISODateFormatter() stringFromDate:(id)model];
    //  NSData 不能再转换成JSON 返回nil
    if ([model isKindOfClass:[NSData class]]) return nil;
    
    //  前面已经对 空/空对象/NSString/NSNumber/NSDictionary/NSSet/NSArray/NSURL/NSAttributedString/NSDate 进行了处理，对剩下的类型做处理
    //  获取model的meta对象
    _PreventModelMeta *modelMeta = [_PreventModelMeta metaWithClass:[model class]];
    if (!modelMeta || modelMeta->_keyMappedCound == 0) return nil;
    //  保存对象的JSON字典，疑问：为什么字典初始化时声明长度为64
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:64];
    //  避免在block内对指针retain或release
    __unsafe_unretained NSMutableDictionary *dic = result;
    //  偏离key path 于propertyMeta的字典
    [modelMeta->_mapper enumerateKeysAndObjectsUsingBlock:^(NSString *propertyMappedKey, _PreventModelPropertyMeta *propertyMeta, BOOL * _Nonnull stop) {
        //  必须实现getter方法，用于调用getter方法获取其属性值
        if (!propertyMeta->_getter) return ;
        
        //  根据属性描述判断属性变量的类型，然后转换成能够可JSON化的对象
        id value = nil;
        
        if (propertyMeta->_isCNumber) {
            //  如果是C类型数据，则组装成NSNumber
            value = ModelCreatNumberFromeProperty(model, propertyMeta);
        } else if (propertyMeta->_nsType) {
            //  如果是Foundation框架中的类，获取到其对象
            id v = ((id (*)(id, SEL))(void *)objc_msgSend)((id)model, propertyMeta->_getter);
            //  嵌套调用转换对象，并保存到value中
            value = ModelToJSONObjectRecursive(v);
        } else {
            //  其他对象
            switch (propertyMeta->_type & PreventEncodingTypeMask) {
                case PreventEncodingTypeObject: {
                    //  自定义对象
                    id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
                    //  嵌套调用
                    value = ModelToJSONObjectRecursive(v);
                    if (value == (id)kCFNull) value = nil;
                } break;
                case PreventEncodingTypeClass: {
                    //  Class
                    Class v = ((Class (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
                    value = v ? NSStringFromClass(v) : nil;
                } break;
                case PreventEncodingTypeSEL: {
                    //  SEL
                    SEL v = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, propertyMeta->_getter);
                    value = v ? NSStringFromSelector(v) : nil;
                } break;
                default: break;
            }
        }
        //  对象转换失败，取消当前属性值设置到字典
        if (!value) return;
        //  将value组装到字典中，需要取出属性描述映射的json key
        //  字典格式: <转换后的value : json key>
        if (propertyMeta->_mappedToKeyPath) {
            //  属性映射的是一个json keypath，那么就需要组装成多层NSDictionary字典
            /**
             *  将一个实体类对象属性值，按照json keypath，转换成对应的字典
             *  @"apple" --映射-- @"user.name"
             *
             *  还原成
             *
             *  @{
             *     @"user" : @{
             *           @"name" : @"apple",
             *       }
             *  }
             */
            
            //  keyPath中一个key的外层字典
            NSMutableDictionary *superDic = dic;
            //  keyPath中一个key的内层字典
            NSMutableDictionary *subDic = nil;
            //  循环遍历keyPath
            for (NSUInteger i = 0, max = propertyMeta->_mappedToKeyPath.count; i < max; i++) {
                //  取出keyPath中的key
                NSString *key = propertyMeta->_mappedToKeyPath[i];
                //  最后一个key结束
                if (i + 1 == max) {
                    //  直接设置到superDict外层字典
                    if (!superDic[key]) superDic[key] = value;
                    break;
                }
                
                //  从外层字典根据json key获取内层字典
                subDic = superDic[key];
                if (subDic) {
                    //  内层字典存在
                    if ([subDic isKindOfClass:[NSDictionary class]]) {
                        subDic = subDic.mutableCopy;
                        superDic[key] = subDic;
                    } else {
                        break;
                    }
                } else {
                    //  内层字典不存在
                    subDic = [NSMutableDictionary new];
                    superDic[key] = subDic;
                }
                //  当前层字典设置成外层字典
                superDic = subDic;
                //  当前赋值空
                subDic = nil;
            }
        } else {
            //  属性不映射到keyPath,直接保存key
            
            if (!dic[propertyMeta->_mappedToKey]) {
                dic[propertyMeta->_mappedToKey] = value;
            }
        }
    }];
    
    //  如果存在自定义修正方法
    if (modelMeta->_hasCustomTransformToDictionary) {
        //  对转换后的字典进行修正
        BOOL suc = [((id<PreventModel>)model) modelCustomTransformToDictionary:dic];
        //  修正失败 返回nil
        if (!suc) return nil;
    }
    
    return result;
}

/**
 *  给传入的字符串添加缩进符(四个空格)，不给第一行添加
 *
 *  @param desc   字符串
 *  @param indent 添加缩进的数量
 *
 *  @return 返回修改或的字符换
 */
static NSMutableString *ModelDescriptionAddIndent(NSMutableString *desc, NSUInteger indent) {
    for (NSUInteger i = 0, max = desc.length; i < max; i++) {
        unichar c = [desc characterAtIndex:i];
        if (c == '\n') {
            for (NSUInteger j = 0; j < indent; j++) {
                [desc insertString:@"    " atIndex:i + 1];
            }
            
            i += indent * 4;
            max += indent * 4;
        }
    }
    
    return desc;
}

/**
 *  得到model的描述字符串
 *
 *  @param model model
 *
 *  @return model的描述字符串
 */
static NSString *ModelDescription(NSObject *model) {
    //  描述字符串的最大长度
    static const int kDescMaxLength = 100;
    if (!model) return @"<nil>";
    if (model == (id)kCFNull) return @"<null>";
    if (![model isKindOfClass:[NSObject class]]) return [NSString stringWithFormat:@"%@",model];
    
    _PreventModelMeta *modelMeta = [_PreventModelMeta metaWithClass:model.class];
    switch (modelMeta->_nsType) {
        case PreventEncodingTypeNSString:
        case PreventEncodingTypeNSMutableString: {
            NSString *tmp = model.description;
            if (tmp.length > kDescMaxLength) {
                //  超过长度，加"..."
                tmp = [tmp substringToIndex:kDescMaxLength];
                tmp = [tmp stringByAppendingString:@"..."];
            }
            
            return tmp;
        }
        case PreventEncodingTypeNSNumber:
        case PreventEncodingTypeNSDecimalNumber:
        case PreventEncodingTypeNSDate:
        case PreventEncodingTypeNSURL: {
            return [NSString stringWithFormat:@"%@",model];
        }
        case PreventEncodingTypeNSSet:
        case PreventEncodingTypeNSMutableSet: {
            model = ((NSSet *)model).allObjects;
        } // no break
        case PreventEncodingTypeNSArray:
        case PreventEncodingTypeNSMutableArray: {
            NSArray *array = (id)model;
            NSMutableString *desc = [NSMutableString new];
            if (array.count == 0) {
                return [desc stringByAppendingString:@"[]"];
            } else {
                [desc appendFormat:@"[\n"];
                for (NSUInteger i = 0, max = array.count; i < max; i++) {
                    NSObject *obj = array[i];
                    [desc appendString:@"    "];
                    [desc appendString:ModelDescriptionAddIndent(ModelDescription(obj).mutableCopy, 1)];
                    [desc appendString:(i + 1 == max) ? @"\n" : @";\n"];
                }
                [desc appendString:@"]"];
                return desc;
            }
        }
            
        case PreventEncodingTypeNSDictionary:
        case PreventEncodingTypeNSMutableDictionary: {
            NSDictionary *dic = (id)model;
            NSMutableString *desc = [NSMutableString new];
            if (dic.count == 0) {
                return [desc stringByAppendingString:@"{}"];
            } else {
                NSArray *keys = dic.allKeys;
                
                [desc appendString:@"{\n"];
                for (NSUInteger i = 0, max = keys.count; i < max; i++) {
                    NSString *key = keys[i];
                    NSObject *value = dic[key];
                    [desc appendString:@"    "];
                    [desc appendFormat:@"%@ = %@",key, ModelDescriptionAddIndent(ModelDescription(value).mutableCopy, i)];
                    [desc appendString:(i + 1 == max) ? @"\n" : @";\n"];
                }
                [desc appendString:@"}"];
            }
            return desc;
        }
            
        default: {
            NSMutableString *desc = [NSMutableString new];
            [desc appendFormat:@"<%@: %p>",model.class, model];
            if (modelMeta->_allPropertyMetas.count == 0) return desc;
            
            NSArray *properties = [modelMeta->_allPropertyMetas
                                   sortedArrayUsingComparator:^NSComparisonResult(_PreventModelPropertyMeta *meta1, _PreventModelPropertyMeta *meta2) {
                                       return [meta1->_name compare:meta2->_name];
                                   }];
            [desc appendString:@" {\n"];
            for (NSUInteger i = 0, max = properties.count; i < max; i++) {
                _PreventModelPropertyMeta *property = properties[i];
                NSString *propertyDesc;
                if (property->_isCNumber) {
                    NSNumber *num = ModelCreatNumberFromeProperty(model, property);
                    propertyDesc = num.stringValue;
                } else {
                    switch (property->_type & PreventEncodingTypeMask) {
                        case PreventEncodingTypeObject: {
                            id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = ModelDescription(v);
                            if (!propertyDesc) propertyDesc = @"<nil>";
                        } break;
                        case PreventEncodingTypeClass: {
                            id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = ((NSObject *)v).description;
                            if (!propertyDesc) propertyDesc = @"<nil>";
                        } break;
                        case PreventEncodingTypeSEL: {
                            SEL sel = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            if (sel) propertyDesc = NSStringFromSelector(sel);
                            else propertyDesc = @"<NULL>";
                        } break;
                        case PreventEncodingTypeBlock: {
                            id block = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = block ? ((NSObject *)block).description : @"<nil>";
                        } break;
                        case PreventEncodingTypeCArray:
                        case PreventEncodingTypeCString:
                        case PreventEncodingTypePointer: {
                            void *pointer = ((void* (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = [NSString stringWithFormat:@"%p",pointer];
                        } break;
                        case PreventEncodingTypeStruct:
                        case PreventEncodingTypeUnion: {
                            NSValue *value = [model valueForKey:property->_name];
                            propertyDesc = value ? value.description : @"{unknown}";
                        } break;
                        default: propertyDesc = @"<unknown>";
                    }
                }
                
                propertyDesc = ModelDescriptionAddIndent(propertyDesc.mutableCopy, 1);
                [desc appendFormat:@"    %@ = %@",property->_name, propertyDesc];
                [desc appendString:(i + 1 == max) ? @"\n" : @";\n"];
            }
            [desc appendString:@"}"];
            
            return desc;
            
        } break;
    }
}

@implementation NSObject (PreventModel)

/**
 *  将id类型的json(NSDictionary/NSString/NSData)转成字典
 *
 *  @param json json对象
 *
 *  @return json字典对象
 */
+ (NSDictionary *)_Prevent_dictionaryWithJSON:(id)json {
    //  判断是否为空
    if (!json || json == (id)kCFNull) return nil;
    
    NSDictionary *dic = nil;
    //  保存NSData类型和NSString转换成的NSData数据
    NSData *jsonData = nil;
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        //  如果是字典，直接保存
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        //  字符串转成NSData
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    
    if (jsonData) {
        //  转换NSData为字典
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    
    return dic;
}

+ (instancetype)modelWithJSON:(id)json {
    NSDictionary *dic = [self _Prevent_dictionaryWithJSON:json];
    return [self modelWithDictionary:dic];
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    
    Class cls = [self class];
    _PreventModelMeta *modelMeta = [_PreventModelMeta metaWithClass:cls];
    //  是否存在自定义的映射Class
    if (modelMeta->_hasCustomClassFromDictionary) {
        cls = [cls modelCustomClassForDictionary:dictionary] ?: cls;
    }
    NSObject *obj = [cls new];
    if ([obj modelSetWithDictionary:dictionary]) return obj;
    return nil;
}

- (BOOL)modelSetWithJSON:(id)json {
    NSDictionary *dic = [NSObject _Prevent_dictionaryWithJSON:json];
    return [self modelSetWithDictionary:dic];
}

- (BOOL)modelSetWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return NO;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return NO;
    
    _PreventModelMeta *modelMeta = [_PreventModelMeta metaWithClass:object_getClass(self)];
    if (modelMeta->_keyMappedCound == 0) return NO;
    
    if (modelMeta->_hasCustomWillTransformFromDictionary) {
        //  执行实现了转换前的dictionary修正方法
        dictionary = [((id<PreventModel>)self) modelCustomWillTransformFromDictionary:dictionary];
        if (![dictionary isKindOfClass:[NSDictionary class]]) return NO;
    }
    
    ModelSetContext context = {0};
    context.modelMeta = (__bridge void *)(modelMeta);
    context.model = (__bridge void *)(self);
    context.dictionary = (__bridge void *)(dictionary);
    
    //  如果映射数量大于字典价值对的数量，说明有一对多的映射
    if (modelMeta->_keyMappedCound >= CFDictionaryGetCount((CFDictionaryRef)dictionary)) {
        /**
         *  CFDictionaryApplyFunction方法的作用是对CFDictionaryRef类型的字典中的每个键值对执行某个方法(这里执行的是ModelSetWithDictionaryFunction方法)
         */
        CFDictionaryApplyFunction((CFDictionaryRef)dictionary, ModelSetWithDictionaryFunction, &context);
        if (modelMeta->_keyPathPropertyMetas) {
            /**
             *  给CFArrayRef中的指定范围中的对象执行方法
             */
            CFArrayApplyFunction((CFArrayRef)modelMeta->_keyPathPropertyMetas,
                                 CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_keyPathPropertyMetas)),
                                 ModelSetWithPropertyMetaArrayFunction,
                                 &context);
        }
        if (modelMeta->_multiKeysPropertyMetas) {
            CFArrayApplyFunction((CFArrayRef)modelMeta->_multiKeysPropertyMetas,
                                 CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_multiKeysPropertyMetas)),
                                 ModelSetWithPropertyMetaArrayFunction,
                                 &context);
        }
    } else {
        CFArrayApplyFunction((CFArrayRef)modelMeta->_allPropertyMetas,
                             CFRangeMake(0, modelMeta->_keyMappedCound),
                             ModelSetWithPropertyMetaArrayFunction, &context);
    }
    
    if (modelMeta->_hasCustomTransformFromDictionary) {
        return [((id<PreventModel>)self) modelCustomTransformFromDictionary:dictionary];
    }
    
    return YES;
}

- (id)modelToJSONObject {
    /**
     苹果规定:
     JSON对象顶层的对象必须是NSArray或者NSDictionary
     所有的对象必须是NSString/NSNumber/NSArray/NSDictionary 或者 NSNull
     所有的字典的key必须是NSString
     数字必须合法数字，并不可以无穷大小
     */
    id jsonObject = ModelToJSONObjectRecursive(self);
    if ([jsonObject isKindOfClass:[NSArray class]]) return jsonObject;
    if ([jsonObject isKindOfClass:[NSDictionary class]]) return jsonObject;
    
    return nil;
}

- (NSData *)modelToJSONData {
    id jsonObject = [self modelToJSONObject];
    if (!jsonObject) return nil;
    return [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
}

- (NSString *)modelToJSONString {
    NSData *jsonData = [self modelToJSONData];
    if (jsonData.length == 0) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (id)modelCopy {
    if (self == (id)kCFNull) return self;
    _PreventModelMeta *modelMeta = [_PreventModelMeta metaWithClass:self.class];
    //  如果是Foundation框架的类，直接copy并返回
    if (modelMeta->_nsType) return [self copy];
    
    //  创建新对象
    NSObject *one = [self.class new];
    //  取出所有属性
    for (_PreventModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        //  属性必须有getter和setter方法
        if (!propertyMeta->_getter || !propertyMeta->_setter) continue;
        
        if (propertyMeta->_isCNumber) {
            //  C语言类型的属性
            switch (propertyMeta->_type & PreventEncodingTypeMask) {
                case PreventEncodingTypeBool: {
                    bool num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case PreventEncodingTypeInt8:
                case PreventEncodingTypeUInt8: {
                    uint8_t num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case PreventEncodingTypeInt16:
                case PreventEncodingTypeUInt16: {
                    uint16_t num = ((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case PreventEncodingTypeInt32:
                case PreventEncodingTypeUInt32: {
                    uint32_t num = ((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case PreventEncodingTypeInt64:
                case PreventEncodingTypeUInt64: {
                    uint64_t num = ((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case PreventEncodingTypeFloat: {
                    float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case PreventEncodingTypeDouble: {
                    double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case PreventEncodingTypeLongDouble: {
                    long double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } // break; commented for code coverage in next line
                default: break;
            }
        } else {
            switch (propertyMeta->_type & PreventEncodingTypeMask) {
                case PreventEncodingTypeObject:
                case PreventEncodingTypeClass:
                case PreventEncodingTypeBlock: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                    //c指针 >>> 使用 size_t类型
                case PreventEncodingTypeSEL:
                case PreventEncodingTypePointer:
                case PreventEncodingTypeCString: {
                    size_t value = ((size_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, size_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                    //  结构体
                case PreventEncodingTypeStruct:
                case PreventEncodingTypeUnion: {
                    @try {
                        NSValue *value = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
                        if (value) {
                            [one setValue:value forKey:propertyMeta->_name];
                        }
                    } @catch (NSException *exception) {}
                } // break; commented for code coverage in next line
                default: break;
            }
        }
    }
    
    return one;
}

- (void)modelEncodeWithCoder:(NSCoder *)aCooder
{
    if (!aCooder) return;
    if (self == (id)kCFNull) {
        //  NSNull实现NSCoding协议
        [((id<NSCoding>)self) encodeWithCoder:aCooder];
        return;
    }
    
    _PreventModelMeta *modelMeta = [_PreventModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) {
        [((id<NSCoding>)self) encodeWithCoder:aCooder];
        return;
    }
    
    for (_PreventModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_getter) return;
        
        if (propertyMeta->_isCNumber) {
            NSNumber *value = ModelCreatNumberFromeProperty(self, propertyMeta);
            if (value) [aCooder encodeObject:value forKey:propertyMeta->_name];
        } else {
            switch (propertyMeta->_type & PreventEncodingTypeMask) {
                case PreventEncodingTypeObject: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    if (value && (propertyMeta->_nsType || [value respondsToSelector:@selector(encodeWithCoder:)])) {
                        //类型是NSValue时，需要注意内部包装的数据类型是否支持归档
                        if ([value isKindOfClass:[NSValue class]]) {
                            //如果是NSValue类型，只支持数值类型的value >>> NSNumber子类归档
                            if ([value isKindOfClass:[NSNumber class]]) {
                                [aCooder encodeObject:value forKey:propertyMeta->_name];
                            }
                        } else {
                            [aCooder encodeObject:value forKey:propertyMeta->_name];
                        }
                    }
                } break;
                case PreventEncodingTypeSEL: {
                    SEL value = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    if (value) {
                        NSString *str = NSStringFromSelector(value);
                        [aCooder encodeObject:str forKey:propertyMeta->_name];
                    }
                } break;
                case PreventEncodingTypeStruct:
                case PreventEncodingTypeUnion: {
                    //  是否是苹果允许归档的结构体类型
                    if (propertyMeta->_isKVCCompatible && propertyMeta->_isStructAvailableForKeyedArchiver) {
                        @try {
                            NSValue *value = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
                            [aCooder encodeObject:value forKey:propertyMeta->_name];
                        } @catch (NSException *exception) {}
                    }
                } break;
                default:
                    break;
            }
        }
    }
}

- (id)modelInitWithCoder:(NSCoder *)aDecoder {
    if (!aDecoder) return self;
    if (self == (id)kCFNull) return self;
    _PreventModelMeta *modelMeta = [_PreventModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) return self;
    
    for (_PreventModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_setter) continue;
        
        if (propertyMeta->_isCNumber) {
            NSNumber *value = [aDecoder decodeObjectForKey:propertyMeta->_name];
            if ([value isKindOfClass:[NSNumber class]]) {
                ModelSetNumberToProperty(self, value, propertyMeta);
                [value class];
            }
        } else {
            PreventEncodingType type = propertyMeta->_type & PreventEncodingTypeMask;
            switch (type) {
                case PreventEncodingTypeObject: {
                    id value = [aDecoder decodeObjectForKey:propertyMeta->_name];
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)self, propertyMeta->_setter, value);
                } break;
                case PreventEncodingTypeSEL: {
                    NSString *str = [aDecoder decodeObjectForKey:propertyMeta->_name];
                    if ([str isKindOfClass:[NSString class]]) {
                        SEL sel = NSSelectorFromString(str);
                        ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_setter, sel);
                    }
                } break;
                case PreventEncodingTypeStruct:
                case PreventEncodingTypeUnion: {
                    if (propertyMeta->_isKVCCompatible) {
                        @try {
                            NSValue *value = [aDecoder decodeObjectForKey:propertyMeta->_name];
                            if (value) [self setValue:value forKey:propertyMeta->_name];
                        } @catch (NSException *exception) {}
                    }
                } break;
                    
                default:
                    break;
            }
        }
    }
    return self;
}


- (NSUInteger)modelHash {
    if (self == (id)kCFNull) return [self hash];
    _PreventModelMeta *modelMeta = [_PreventModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) return [self hash];
    
    NSUInteger value = 0;
    NSUInteger count = 0;
    for (_PreventModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_isKVCCompatible) continue;
        value ^= [[self valueForKey:NSStringFromSelector(propertyMeta->_getter)] hash];
        count++;
    }
    if (count == 0) {
        value = (long)((__bridge void *)self);
    }
    
    return value;
}

- (BOOL)modelIsEqual:(id)model {
    if (self == model) return YES;
    if (![model isMemberOfClass:self.class]) return NO;
    _PreventModelMeta *modelMeta = [_PreventModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) return [self isEqual:model];
    if ([self hash] != [model hash]) return NO;
    
    for (_PreventModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_isKVCCompatible) continue;
        id this = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        id that = [model valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        if (this == that) continue;
        if (this == nil || that == nil) return NO;
        if (![this isEqual:that]) return NO;
    }
    return YES;
}

- (NSString *)modelDescription
{
    return ModelDescription(self);
}

@end

@implementation NSArray (PreventModel)

+ (NSArray *)modelArrayWithClass:(Class)cls json:(id)json {
    if (!json) return nil;
    NSArray *array = nil;
    NSData *jsonData = nil;
    
    if ([json isKindOfClass:[NSArray class]]) {
        array = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    
    if (jsonData) {
        array = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![array isKindOfClass:[NSArray class]]) array = nil;
    }
    
    return [self modelArrayWithClass:cls array:array];
}

+ (NSArray *)modelArrayWithClass:(Class)cls array:(NSArray *)array {
    if (!cls || !array) return nil;
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *dic in array) {
        NSObject *obj = [cls modelWithDictionary:dic];
        if (obj) [result addObject:obj];
    }
    
    return result;
}

@end

@implementation NSDictionary (PreventModel)

+ (NSDictionary *)modelDictionaryWithClass:(Class)cls json:(id)json {
    if (!json) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return [self modelDictionaryWithClass:cls dictionary:dic];
}

+ (NSDictionary *)modelDictionaryWithClass:(Class)cls dictionary:(NSDictionary *)dic {
    if (!cls || !dic) return nil;
    NSMutableDictionary *result = [NSMutableDictionary new];
    for (NSString *key in dic.allKeys) {
        if (![key isKindOfClass:[NSString class]]) continue;
        NSObject *obj = [cls modelWithDictionary:dic[key]];
        if (obj) result[key] = obj;
    }
    return result;
}

@end
