//
//  NSObject+PreventModel.h
//  NewCreate
//
//  Created by 叶慧伟 on 16/10/16.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN


/**
 *  转换json到任何对象，或者转换任何对象为json
 *  并实现了 NSCoding NSCopying -hash - isEqual方法
 *  示例代码：
 ********************** json convertor *********************
 @ YYAuthor : NSObject
 @property (nonatomic, strong) NSString *name;
 @property (nonatomic, assign) NSDate *birthday;
 @end
 @implementation YYAuthor
 @end
 
 @ YYBook : NSObject
 @property (nonatomic, copy) NSString *name;
 @property (nonatomic, assign) NSUInteger pages;
 @property (nonatomic, strong) YYAuthor *author;
 @end
 @implementation YYBook
 @end
 
 int main() {
 // create model from json
 YYBook *book = [YYBook modelWithJSON:@"{\"name\": \"Harry Potter\", \"pages\": 256, \"author\": {\"name\": \"J.K.Rowling\", \"birthday\": \"1965-07-31\" }}"];
 
 // convert model to json
 NSString *json = [book modelToJSONString];
 // {"author":{"name":"J.K.Rowling","birthday":"1965-07-31T00:00:00+0000"},"name":"Harry Potter","pages":256}
 }
 
 ********************** Coding/Copying/hash/equal *********************
 @ YYShadow :NSObject <NSCoding, NSCopying>
 @property (nonatomic, copy) NSString *name;
 @property (nonatomic, assign) CGSize size;
 @end
 
 @implementation YYShadow
 - (void)encodeWithCoder:(NSCoder *)aCoder { [self modelEncodeWithCoder:aCoder]; }
 - (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self modelInitWithCoder:aDecoder]; }
 - (id)copyWithZone:(NSZone *)zone { return [self modelCopy]; }
 - (NSUInteger)hash { return [self modelHash]; }
 - (BOOL)isEqual:(id)object { return [self modelIsEqual:object]; }
 @end
 */

@interface NSObject (PreventModel)

/**
 *  创建并返回一个对象根据json
 *  这个方法是线程安全的
 *
 *  @param json json可为 NSDictionary NSString NSData
 *
 *  @return 返回一个示例对象或者nil
 */
+ (nullable instancetype)modelWithJSON:(id)json;

/**
 *  创建并返回一个对象根据字典转换而来
 *  这个方法是线程安全的
 *  字典中的 key 对应于对象中property的名字，字典中的value会赋值给property。
 *  如果字典中的value的类型和property的类型不一致，这个方法会尝试进行转换，转换规则如下：
 *  'NSString' or 'NSNumber' -> c number ,比如:BOOL,int.long.float.NSUinteger...
 *  'NSString' -> NSDate,解析字符串"yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd HH:mm:ss" or "yyyy-MM-dd"
 *  'NSString' -> NSURL
 *  'NSValue' -> struct 或者 union,比如:CGRect,CGSize,...
 *  'NSString' -> SEL,Class
 *
 *  @param dictionary key-value字典，映射到对象的property，将会忽略是无效的key-value
 *
 *  @return 返回model对象 或者 nil(如果出错)
 */
+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dictionary;

/**
 *  将json转换成model对象，
 *  将会忽略无效的数据
 *
 *  @param json 存储json的对象，可以为NSDictionary,NSData,NSString
 *
 *  @return 返回转换是否成功
 */
- (BOOL)modelSetWithJSON:(id)json;

/**
 *  根据key-value字典转换成model对象
 *  如果字典中的value类型和property类型不一致，转换规则参考+modelWithDictionary:方法
 *
 *  @param dictionary key-value字典，映射到对象的property，将会忽略是无效的key-value
 *
 *  @return 返回转换是否成功
 */
- (BOOL)modelSetWithDictionary:(NSDictionary *)dictionary;

/**
 *  将model转换成json对象
 *
 *  @return 返回json对象可能为'NSDictionary','NSArray' 或者 nil(如果出错)
 */
- (nullable id)modelToJSONObject;

/**
 *  将model转换成json对象
 *
 *
 *  @return 返回一个json的字符串NSData,或者nil
 */
- (nullable NSData *)modelToJSONData;

/**
 *  将model转换成json字符串
 *
 *  @return 返回json字符串或者nil
 */
- (nullable NSString *)modelToJSONString;

/**
 *  copy model对象
 *
 *  @return 返回copy出的对象，或者nil
 */
- (nullable id)modelCopy;

/**
 *  归档
 *
 *  @param aCooder 归档对象
 */
- (void)modelEncodeWithCoder:(NSCoder *)aCooder;

/**
 *  解档
 *
 *  @param aDecoder 解档对象
 *
 *  @return self
 */
- (id)modelInitWithCoder:(NSCoder *)aDecoder;

/**
 *  获取hash值
 *
 *  @return hash值
 */
- (NSUInteger)modelHash;

/**
 *  比较两个model对象
 *
 *  @param model 另一个model对象
 *
 *  @return 比较结果
 */
- (BOOL)modelIsEqual:(id)model;

/**
 *  model的描述
 *
 *  @return 返回描述字符串
 */
- (NSString *)modelDescription;

@end

@interface NSArray (PreventModel)

/**
 *  根据json-array创建并返回一个数组，这个方法是线程安全的
 *
 *  @param cls  数组里的对象的class
 *  @param json json对象 可以是NSArray/NSString/NSData
 *              例如：[{"name","Mary"},{"name":"Joe"}]
 *
 *  @return 返回数组或者nil
 */
+ (nullable NSArray *)modelArrayWithClass:(Class)cls json:(id)json;

@end

@interface NSDictionary (PreventModel)

/**
 *  根据json创建一个字典
 *
 *  @param cls  字典中value对应的对象的class
 *  @param json json对象 可以是NSDictionary/NSString/NSData
 *              例如：{"user1":{"name":"Mary"},"user2":{"name":"Joe"}}
 *
 *  @return 返回字典或者nil
 */
+ (nullable NSDictionary *)modelDictionaryWithClass:(Class)cls json:(id)json;

@end

@protocol PreventModel <NSObject>
@optional

/**
 *  如果json中的key和model的property名字不是一样的，则实现这个方法，返回自定义的映射规则
 *
 *  @return 返回自定义映射
 */
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;
/**
 modelCustomPropertyMapper 示例:
 
 json:
 {
 "n":"Harry Pottery",
 "p": 256,
 "ext" : {
 "desc" : "A book written by J.K.Rowling."
 },
 "ID" : 100010
 }
 
 model:
 @interface YYBook : NSObject
 @property NSString *name;
 @property NSInteger page;
 @property NSString *desc;
 @property NSString *bookID;
 @end
 
 @implementation YYBook
 + (NSDictionary *)modelCustomPropertyMapper {
 return @{@"name"  : @"n",
 @"page"  : @"p",
 @"desc"  : @"ext.desc",
 @"bookID": @[@"id", @"ID", @"book_id"]};
 }
 @end
 */


/**
 *  如果这个property是一个容器对象，比如 NSArray/NSSet/NSDictionary,实现这个方法并且返回一个 property->class映射，说明哪一种对象将要添加到NSArray/NSSet/NSDictionary之中。
 *
 *  @return 返回一个class映射
 */
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;
/**
 modelContainerPropertyGenericClass 方法例子：
 @class YYShadow, YYBorder, YYAttachment;
 
 @interface YYAttributes
 @property NSString *name;
 @property NSArray *shadows;
 @property NSSet *borders;
 @property NSDictionary *attachments;
 @end
 
 @implementation YYAttributes
 + (NSDictionary *)modelContainerPropertyGenericClass {
 return @{@"shadows" : [YYShadow class],
 @"borders" : YYBorder.class,
 @"attachments" : @"YYAttachment" };
 }
 @end
 */

/**
 *  映射规则，json中部分字典对象对应的Class
 *
 *  @param dictionary 字典对象
 *
 *  @return 返回字典对应的class 如果返回为 nil 自使用当前的class
 */
+ (nullable Class)modelCustomClassForDictionary:(NSDictionary *)dictionary;
/**
 modelCustomClassForDictionary 示例：
 @class YYCircle, YYRectangle, YYLine;
 
 @implementation YYShape
 
 + (Class)modelCustomClassForDictionary:(NSDictionary*)dictionary {
 if (dictionary[@"radius"] != nil) {
 return [YYCircle class];
 } else if (dictionary[@"width"] != nil) {
 return [YYRectangle class];
 } else if (dictionary[@"y2"] != nil) {
 return [YYLine class];
 } else {
 return [self class];
 }
 }
 
 @end
 */

/**
 *  在黑名单中的property在映射时将被忽略，即不做映射
 *
 *  @return property黑名单 如果返回 nil则忽略此功能
 */
+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;

/**
 *  不在白色名单中的property在映射时将被忽略，即不做映射
 *
 *  @return property白名单 如果返回 nil则忽略此功能
 */
+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;

/**
 *  这个方法的功能和 ‘- (BOOL)modelCustomTransformFromDictionary:’ 相似
 *  但这个方法会在转换之前调用
 *  此方法可以自转换成model之前对dictionary做处理，返回nil则不进行转换model
 *
 *  @param ditionary json dictionary
 *
 *  @return 返回进行修正过的dictionary，返回'nil'则忽略映射
 */
- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)ditionary;

/**
 *  在 json-to-model 转换后，调用这个方法对转换后的model进行额外的处理
 *  或者调用这个方法来验证model的properties，即验证model是否有效
 *  该方法会在以下方法执行后调用 +modelWithJSON:
 *                          +modelWithDictionary:
 *                          -modelSetWithJSON:
 *                          -modelSetWithDictionary:
 *
 *  @param dictionary json dictionary
 *
 *  @return YES: 当前model是有效的，NO: 忽略这个model
 */
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dictionary;

/**
 *  在 model-to-json 转换之后，调用该方法对转换后的dictionary进行额外的处理
 *  或者调用此方法验证转换后的Dictionary是否有效
 *  该方法会在以下方法执行后调用 -modelToJSONObject
 *                          -modelToJSONString
 *
 *  @param dictionary json dictionary
 *
 *  @return YES: dictionary是有效的，NO: 忽略此次转换
 */
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dictionary;

@end


NS_ASSUME_NONNULL_END
