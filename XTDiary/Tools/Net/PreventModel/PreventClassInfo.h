//
//  PreventClassInfo.h
//  NewCreate
//
//  Created by 叶慧伟 on 16/10/16.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

/**
 *  NS_ASSUME_NONNULL_BEGIN和NS_ASSUME_NONNULL_END在这两个宏之间的代码，所有简单指针对象都被假定为nonnull，因此我们只需要去指定那些nullable的指针。
 * _nonnull和_nullable标记表示一个指针是否可以为Null或者nil，这两个为xcode6.3引入的新特性，用于swift和oc混合编程
 */
NS_ASSUME_NONNULL_BEGIN

/**
 * NS_ENUM和NS_OPTIONS本质是一样的，仅仅从字面上来区分其用途。NS_ENUM是通用情况，NS_OPTIONS一般用来定义具有位移操作或特点的情况
 */
typedef NS_OPTIONS(NSUInteger, PreventEncodingType) {
    PreventEncodingTypeMask                 = 0xFF,// 0xFF = (二进制)11111111 所以是低8位Mask掩码，用来去得枚举值的低8位值
    PreventEncodingTypeUnknown              = 0,// 未知类型
    PreventEncodingTypeVoid                 = 1,// void
    PreventEncodingTypeBool                 = 2,// bool
    PreventEncodingTypeInt8                 = 3,// char / BOOL (BOOL和bool的区别，BOOL为int型，bool为布尔型，bool只有一个字节，BOOL根据环境而定；bool取值是false和true，是0和1的区别，BOOL取值FALSE和TRUE,是0和非0的区别。具体请查看http://www.cnblogs.com/luofuxian/archive/2012/08/03/2621365.html)
    PreventEncodingTypeUInt8                = 4,// unsigned char
    PreventEncodingTypeInt16                = 5,// short
    PreventEncodingTypeUInt16               = 6,// unsigned short
    PreventEncodingTypeInt32                = 7,// int
    PreventEncodingTypeUInt32               = 8,// unsigned int
    PreventEncodingTypeInt64                = 9,// long long
    PreventEncodingTypeUInt64               = 10,// unsigned long long
    PreventEncodingTypeFloat                = 11,// float
    PreventEncodingTypeDouble               = 12,// double
    PreventEncodingTypeLongDouble           = 13,// long double
    PreventEncodingTypeObject               = 14,// id
    PreventEncodingTypeClass                = 15,// Class
    PreventEncodingTypeSEL                  = 16,// SEL
    PreventEncodingTypeBlock                = 17,// block
    PreventEncodingTypePointer              = 18,// void*
    PreventEncodingTypeStruct               = 19,// struct
    PreventEncodingTypeUnion                = 20,// union
    PreventEncodingTypeCString              = 21,// char*
    PreventEncodingTypeCArray               = 22,// char[10]
    
    PreventEncodingTypeQualifierMask        = 0xFF00,// 低16位Mask掩码，用于修饰符获取
    PreventEncodingTypeQualifierConst       = 1 << 8,// const
    PreventEncodingTypeQualifierIn          = 1 << 9,// in
    PreventEncodingTypeQualifierInout       = 1 << 10,
    PreventEncodingTypeQualifierOut         = 1 << 11,
    PreventEncodingTypeQualifierBycopy      = 1 << 12,
    PreventEncodingTypeQualifierByref       = 1 << 13,
    PreventEncodingTypeQualifierOneway      = 1 << 14,
    
    PreventEncodingTypePropertyMask         = 0xFF0000,// 32为Mask掩码，用于获取property的修饰符
    PreventEncodingTypePropertyReadonly     = 1 << 16,
    PreventEncodingTypePropertyCopy         = 1 << 17,
    PreventEncodingTypePropertyRetain       = 1 << 18,
    PreventEncodingTypePropertyNonatomic    = 1 << 19,
    PreventEncodingTypePropertyWeak         = 1 << 20,
    PreventEncodingTypePropertyCustomGetter = 1 << 21,
    PreventEncodingTypePropertyCustomSetter = 1 << 22,
    PreventEncodingTypePropertyDynamic      = 1 << 23,// @dynamic
};

/**
 *  根据Type-Encoding字符串获取type
 *
 *  @param typeEncoding Type-Encoding字符串
 *
 *  @return encoding type
 */
PreventEncodingType PreventEncodingGetType(const char *typeEncoding);

/**
 *  保存对IVar变量信息的类
 */
@interface PreventClassIvarInfo : NSObject

/**
 *  变量
 */
@property (nonatomic, assign, readonly) Ivar ivar;

/**
 *  变量名
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  Ivar偏移字节，对 ivar 的访问就可以通过 对象地址 ＋ ivar偏移字节 的方法
 *  参考链接
 *  http://chun.tips/blog/2014/11/08/bao-gen-wen-di-objective[nil]c-runtime(4)[nil]-cheng-yuan-bian-liang-yu-shu-xing/
 */
@property (nonatomic, assign, readonly) ptrdiff_t offset;

/**
 *  Ivar的系统编码
 */
@property (nonatomic, strong, readonly) NSString *typeEncoding;

/**
 *  Ivar系统编码对应的枚举类型
 */
@property (nonatomic, assign, readonly) PreventEncodingType type;

/**
 *  根据Ivar变量初始化对象
 *
 *  @param ivar ivar
 *
 *  @return self
 */
- (instancetype)initWithIvar:(Ivar)ivar;

@end


@interface PreventClassMethodInfo : NSObject

/**
 *  objc_method结构体
 *
 *  typedef struct objc_ method {
 *      SEL method_name;        // 表示该方法的名称
 *      char *method_types;     // 表示该方法参数的类型
 *      IMP method_imp;         // 指向该方法的具体实现的函数指针
 *  }
 *
 *  typedef struct objc_method *Method;
 */
@property (nonatomic, assign, readonly) Method method;

/**
 *  方法名字
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  objc_method的SEL值
 */
@property (nonatomic, assign, readonly) SEL sel;

/**
 *  objc_method的IMP实现指针
 *  IMP的定义：typedef id (*IMP)(id, SEL, ...);
 *  至此，我们就很清楚地知道 IMP 的含义：
 *  IMP 是一个函数指针，这个被指向的函数包含一个接收消息的对象id(self 指针), 调用方法的选标 SEL (方法名)，以及不定个数的方法参数，并返回一个id。
 *  也就是说 IMP 是消息最终调用的执行代码，是方法真正的实现代码 。我们可以像在Ｃ语言里面一样使用这个函数指针。
 */
@property (nonatomic, assign, readonly) IMP imp;

/**
 *  方法的类型编码
 */
@property (nonatomic, strong, readonly) NSString *typeEncoding;

/**
 *  方法返回值的类型编码
 */
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;

/**
 *  方法的所有参数的类型编码
 */
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncoding;

/**
 *  根据Method初始化
 *
 *  @param method Method
 *
 *  @return self
 */
- (instancetype)initWithMethod:(Method)method;

@end

/**
 *  对objc_property_t的抽象封装
 */
@interface PreventClassPropertyInfo : NSObject

/**
 *  属性
 */
@property (nonatomic, assign, readonly) objc_property_t property;

/**
 *  属性名称
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  属性的类型编码对应的枚举值
 */
@property (nonatomic, assign, readonly) PreventEncodingType type;

/**
 *  属性的类型编码
 */
@property (nonatomic, strong, readonly) NSString *typeEncoding;

/**
 *  属性的变量名字
 */
@property (nonatomic, strong, readonly) NSString *ivarName;

/**
 *  属性的遵守的协议列表
 */
@property (nonatomic, strong) NSArray<NSString *> *protocols;

/**
 *  属性的Class类型，可空
 */
@property (nullable, nonatomic, assign, readonly) Class cls;

/**
 *  属性的getter和setter的SEL
 */
@property (nonatomic, assign, readonly) SEL getter;
@property (nonatomic, assign, readonly) SEL setter;

/**
 *  根据objc_property_t初始化
 *
 *  @param property objc_property_t
 *
 *  @return self
 */
- (instancetype)initWithProperty:(objc_property_t)property;

@end

/**
 *  对Class抽象的模型
 */
@interface PreventClassInfo : NSObject

/**
 *  被封装的cls
 */
@property (nonatomic, assign, readonly) Class cls;

/**
 *  cls的父类
 */
@property (nullable, nonatomic, assign, readonly) Class superCls;

/**
 *  cls的元数据类
 */
@property (nullable, nonatomic, assign, readonly) Class metaCls;

/**
 *  当前cls是否是元数据类
 */
@property (nonatomic, assign, readonly) BOOL isMeta;

/**
 *  cls的字符串名字
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  cls的父类Class的抽象模型
 */
@property (nonatomic, strong, readonly) PreventClassInfo *superClassInfo;

/**
 *  保存所有的Ivar信息
 */
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, PreventClassIvarInfo *> *ivarInfos;

/**
 *  保存所有的Method信息
 */
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, PreventClassMethodInfo *> *methodInfos;

/**
 *  保存所有的Property信息
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, PreventClassPropertyInfo *> *propertyInfos;

/**
 *  当使用runtime修改该Classs（比如：使用class_addMethod()方法添加了一个方法），需要调用此方法进行更新当前Class封装对象
 *  在执行该方法之后，你需要调用 'classInfoWithClass:' 或 'classInfoWithClass:' 方法来更新Class Info
 */
- (void)setNeedUpdate;

- (BOOL)needUpdate;

/**
 *  获取Class的信息
 *  在第一次调用这个方法时，将会缓存class和super-class的信息；这个方法是线程安全的
 *
 *  @param cls Class
 *
 *  @return 返回class info 或者 发生错误时返回 nil
 */
+ (nullable instancetype)classInfoWithClass:(Class)cls;


/**
 *  获取Class的信息
 *  在第一次调用这个方法时，将会缓存class和super-class的信息；这个方法是线程安全的
 *
 *  @param className Class Name
 *
 *  @return 返回class info 或者 发生错误时返回 nil
 */
+ (nullable instancetype)classInfoWithClassName:(NSString *)className;
@end

NS_ASSUME_NONNULL_END



