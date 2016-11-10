//
//  PreventClassInfo.m
//  NewCreate
//
//  Created by 叶慧伟 on 16/10/16.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "PreventClassInfo.h"
#import <objc/runtime.h>

PreventEncodingType PreventEncodingGetType(const char *typeEncoding){
    // 为什么要转换一下??
    char *type = (char *)typeEncoding;
    
    // 为空 返回PreventEncodingTypeUnknown
    if(!type) return PreventEncodingTypeUnknown;
    
    // 长度为零 返回PreventEncodingTypeUnknown
    size_t len = strlen(type);
    if(len == 0) return PreventEncodingTypeUnknown;
    
    // 用来保存修饰符
    PreventEncodingType qualifier = 0;
    bool prefix = true;
    // 循环遍历知道找不到前缀修饰符为止
    while (prefix) {
        switch (*type) {
            case 'r':{
                qualifier |= PreventEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n':{
                qualifier |= PreventEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N':{
                qualifier |= PreventEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o':{
                qualifier |= PreventEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O':{
                qualifier |= PreventEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R':{
                qualifier |= PreventEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V':{
                qualifier |= PreventEncodingTypeQualifierOneway;
                type++;
            } break;
            default:{
                prefix = false;
            } break;
        }
    }
    
    len = strlen(type);
    if(len == 0) return PreventEncodingTypeUnknown | qualifier;
    switch (*type) {
        case 'v': return PreventEncodingTypeVoid        | qualifier;
        case 'B': return PreventEncodingTypeBool        | qualifier;
        case 'c': return PreventEncodingTypeInt8        | qualifier;
        case 'C': return PreventEncodingTypeUInt8       | qualifier;
        case 's': return PreventEncodingTypeInt16       | qualifier;
        case 'S': return PreventEncodingTypeUInt16      | qualifier;
        case 'i': return PreventEncodingTypeInt32       | qualifier;
        case 'I': return PreventEncodingTypeUInt32      | qualifier;
        case 'l': return PreventEncodingTypeInt32       | qualifier;
        case 'L': return PreventEncodingTypeUInt32      | qualifier;
        case 'q': return PreventEncodingTypeInt64       | qualifier;
        case 'Q': return PreventEncodingTypeUInt64      | qualifier;
        case 'f': return PreventEncodingTypeFloat       | qualifier;
        case 'd': return PreventEncodingTypeDouble      | qualifier;
        case 'D': return PreventEncodingTypeLongDouble  | qualifier;
        case '#': return PreventEncodingTypeClass       | qualifier;
        case ':': return PreventEncodingTypeSEL         | qualifier;
        case '*': return PreventEncodingTypeCString     | qualifier;
        case '^': return PreventEncodingTypePointer     | qualifier;
        case '[': return PreventEncodingTypeCArray      | qualifier;
        case '(': return PreventEncodingTypeUnion       | qualifier;
        case '{': return PreventEncodingTypeStruct      | qualifier;
        case '@': {
            if(len == 2 && *(type + 1) == '?')
                return PreventEncodingTypeBlock         | qualifier;
            else
                return PreventEncodingTypeObject        | qualifier;
        }
        default:return PreventEncodingTypeUnknown       | qualifier;
    }
}

/**
 *  ivar info
 */
@implementation PreventClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar
{
    if (!ivar) {
        return  nil;
    }
    
    if (self = [super init]) {
        _ivar = ivar;
        
        //  获取名字
        const char *ivarName = ivar_getName(ivar);
        if (ivarName) _name = [NSString stringWithUTF8String:ivarName];
        
        //  获取偏移字节
        _offset = ivar_getOffset(ivar);
        
        //  获取编码类型
        const char *typeEncoding = ivar_getTypeEncoding(ivar);
        if (typeEncoding) {
            _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
            _type = PreventEncodingGetType(typeEncoding);
        }
    }
    
    return self;
}


//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"PreventClassIvarInfo description:%@\n ivar: %s\nname: %@\noffset: %td\ntypeEncoding: %@\ntype: %lu\n",[super description], ivar_getName(self.ivar), self.name, self.offset, self.typeEncoding, (unsigned long)self.type];
//}

@end

/**
 *  methodInfo
 */
@implementation PreventClassMethodInfo

- (instancetype)initWithMethod:(Method)method{
    if(!method) return nil;
    
    if (self = [super init]) {
        _method = method;
        _sel = method_getName(method);
        _imp = method_getImplementation(method);
        
        //  获取sel name
        const char *selName = sel_getName(_sel);
        if (selName) _name = [NSString stringWithUTF8String:selName];
        
        // 获取编码类型
        const char *typeEncoding = method_getTypeEncoding(method);
        if (typeEncoding) _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        
        // 获取返回值的编码类型
        char *returnType = method_copyReturnType(method);
        if (returnType) {
            _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
            //注意: 只要带 copy、retain、alloc之类的系统方法得到的，不使用时必须使用release()或free()
            free(returnType);
        }
        
        // 获取参数列表类型
        unsigned int argumentCount = method_getNumberOfArguments(method);
        if (argumentCount > 0) {
            NSMutableArray *argumentTypes = [NSMutableArray array];
            
            // 循环获取每个参数
            for (unsigned int i = 0; i < argumentCount; i++) {
                // 参数类型
                char *argumentType = method_copyArgumentType(method, i);
                NSString *type = argumentType ? [NSString stringWithUTF8String:argumentType] : @"";
                [argumentTypes addObject:type];
                if (argumentType) {
                    free(argumentType);
                }
            }
            
            _argumentTypeEncoding = argumentTypes;
        }
        
    }
    
    return self;
}


//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"PreventClassMethodInfo description:%@\n method: %@\nname: %@\nsel: %@\nimp: %p\ntypeEncoding: %@\nreturnTypeEncoding: %@\nargumentTypeEncoding: %@\n",[super description], NSStringFromSelector(method_getName(self.method)), self.name, NSStringFromSelector(self.sel), self.imp, self.typeEncoding, self.returnTypeEncoding, self.argumentTypeEncoding];
//}

@end

@implementation PreventClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property
{
    if (!property) return nil;
    
    if (self = [super init]) {
        _property = property;
        
        //  获取名字
        const char *name = property_getName(property);
        if (name) _name = [NSString stringWithUTF8String:name];
        
        //  获取属性类型
        PreventEncodingType type = 0;
        unsigned int attrCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
        for (unsigned int i = 0; i < attrCount; i++) {
            //获取每一个属性的 @encode()编码字符串
            /*
             T@"NSString",C,N,V_name分割成如下子项:
             
             name = T, value = @"User"
             name = &, value =
             name = N, value =
             name = V, value = _user
             
             结构体如下
             typedef struct {
             const char *name;
             const char *value;
             } objc_property_attribute_t;
             */
            objc_property_attribute_t attr = attrs[i];
            switch (attr.name[0]) {
                case 'T':{  //  T开头是属性的类型编码
                    if (attr.value) {
                        _typeEncoding = [NSString stringWithUTF8String:attr.value];
                        type = PreventEncodingGetType(attr.value);
                        //  如果是实体类，取出其实体类Class，如: User
                        if ((type & PreventEncodingTypeMask) == PreventEncodingTypeObject && _typeEncoding.length) {
                            // 字符搜索
                            NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                            //  特征值类型为自定义对象，如: @"User" --> @，"，U，s，e，r，" 长度为7，
                            //  其中 '@' 表示当前为类对象
                            //  Class名字部分为去除 开头'@"'两个字符和最后一个'"'字符，共长度为3个字符
                            // 如果不是一@“开头 跳出本次循环
                            if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                            
                            NSString *className = nil;
                            // 截取类名，搜索到"或者<时得到的就是类名，当属性有协议是搜索到<
                            if ([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&className]) {
                                if (className.length) _cls = objc_getClass(className.UTF8String);
                            }
                            NSMutableArray *protocols = nil;
                            while ([scanner scanString:@"<" intoString:NULL]) {
                                NSString *protocol = nil;
                                if ([scanner scanUpToString:@">" intoString:&protocol]) {
                                    if (!protocols) protocols = [NSMutableArray array];
                                    [protocols addObject:protocol];
                                }
                                [scanner scanString:@">" intoString:NULL];
                            }
                            _protocols = protocols;
                        }
                    }
                } break;
                case 'V':{  //  //V_user、属性变量的名字,name = V, value = _user
                    if (attr.value) _ivarName = [NSString stringWithUTF8String:attr.value];
                } break;
                case 'R':{
                    type |= PreventEncodingTypePropertyReadonly;
                } break;
                case 'C':{
                    type |= PreventEncodingTypePropertyCopy;
                } break;
                case '&':{
                    type |= PreventEncodingTypePropertyRetain;
                } break;
                case 'N':{
                    type |= PreventEncodingTypePropertyNonatomic;
                } break;
                case 'D':{
                    type |= PreventEncodingTypePropertyDynamic;
                } break;
                case 'W':{
                    type |= PreventEncodingTypePropertyWeak;
                } break;
                case 'G':{
                    type |= PreventEncodingTypePropertyCustomGetter;
                    if (attr.value) _getter = NSSelectorFromString([NSString stringWithUTF8String:attr.value]);
                } break;
                case 'S':{
                    type |= PreventEncodingTypePropertyCustomSetter;
                    if (attr.value) _setter = NSSelectorFromString([NSString stringWithUTF8String:attr.value]);
                } //break;
                default: break;
            }
        }
        
        if (attrs) {
            free(attrs);
            attrs = NULL;
        }
        
        _type = type;
        
        if (_name.length) {
            if (!_getter) {
                _getter = NSSelectorFromString(_name);
            }
            
            if (!_setter) {
                _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
            }
        }
    }
    
    return self;
}


//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"PreventClassPropertyInfo description:%@\n property: %s\nname: %@\ntype: %lu\ntypeEncoding: %@\nivarName: %@\ncls: %@\ngetter: %@\nsetter: %@\n",[super description], property_getName(self.property), self.name, (unsigned long)self.type, self.typeEncoding, self.ivarName, NSStringFromClass(self.cls), NSStringFromSelector(self.getter), NSStringFromSelector(self.setter)];
//}

@end

@implementation PreventClassInfo{
    BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls
{
    if (!cls) return nil;
    
    if (self = [super init]) {
        _cls = cls;
        _superCls = class_getSuperclass(cls);
        _isMeta = class_isMetaClass(cls);
        
        if (!_isMeta) _metaCls = objc_getMetaClass(class_getName(cls));
        
        _name = NSStringFromClass(cls);
        
        [self _update];
        
        _superClassInfo = [PreventClassInfo classInfoWithClass:_superCls];
    }
    
    return self;
}

- (void)_update
{
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    
    Class cls = _cls;
    
    //  获取Method信息
    unsigned int methodCount = 0;
    //  获取所有Method
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary dictionary];
        
        for (unsigned int i = 0; i < methodCount; i++) {
            // 对Method进行封装保存
            PreventClassMethodInfo *methodInfo = [[PreventClassMethodInfo alloc] initWithMethod:methods[i]];
            if (methodInfo.name) methodInfos[methodInfo.name] = methodInfo;
        }
        
        _methodInfos = methodInfos;
        
        free(methods);
    }
    
    //  获取Ivar信息
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary dictionary];
        
        for (unsigned int i = 0; i < ivarCount; i++) {
            PreventClassIvarInfo *ivarInfo = [[PreventClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (ivarInfo.name) ivarInfos[ivarInfo.name] = ivarInfo;
        }
        
        _ivarInfos = ivarInfos;
        
        free(ivars);
    }
    
    //  获取property信息
    unsigned int propertyCount = 0;
    objc_property_t *propertys = class_copyPropertyList(cls, &propertyCount);
    if (propertys) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary dictionary];
        for (unsigned int i = 0; i < propertyCount; i++) {
            PreventClassPropertyInfo *propertyInfo = [[PreventClassPropertyInfo alloc] initWithProperty:propertys[i]];
            if (propertyInfo.name) propertyInfos[propertyInfo.name] = propertyInfo;
        }
        _propertyInfos = propertyInfos;
        
        free(propertys);
    }
    
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_methodInfos) _methodInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    
    _needUpdate = NO;
}

- (void)setNeedUpdate
{
    _needUpdate = YES;
}

- (BOOL)needUpdate
{
    return _needUpdate;
}

+ (instancetype)classInfoWithClass:(Class)cls
{
    if (!cls) return nil;
    
    /**
     *  创建两个CoreFoundation的可变字典，来缓存Class和ClassMeta的info数据
     */
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    
    //  同步信号量，控制并发操作
    static dispatch_semaphore_t lock;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        /**
         *  创建一个控制并发的信号量
         *
         *  @param 1 可并发说，1代表只能有一个线程执行代码
         *
         *  @return 返回信号量
         */
        lock = dispatch_semaphore_create(1);
    });
    
    /**
     *  如果信号量<1，则线程在此等待，知道信号量>0，则往下执行并让信号量减1
     */
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    
    /**
     *  关于 __bridge,__bridge_transfer,__bridge_retained
     *  __bridge:CF和OC对象转化时只涉及对象类型不涉及对象所有权的转化；意思是内存的管理还是由ARC来管理
     *  __bridge_transfer:常用在讲CF对象转换成OC对象时，将CF对象的所有权交给OC对象，此时ARC就能自动管理该内存；（作用同CFBridgingRelease()）
     *  当使用_bridge_retained标识符以后，代表OC要将对象所有权交给CF对象自己来管理,所以我们要在ref使用完成以后用CFRelease将其手动释放.
     */
    PreventClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
    if (info && info->_needUpdate) {
        [info _update];
    }
    
    /**
     *  释放信号量，信号量加1
     */
    dispatch_semaphore_signal(lock);
    
    if (!info) {
        info = [[PreventClassInfo alloc] initWithClass:cls];
        if (info) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            dispatch_semaphore_signal(lock);
        }
    }
    
    return info;
}

+ (instancetype)classInfoWithClassName:(NSString *)className
{
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"PreventClassInfo description:%@\n cls: %@\nsuperCls: %@\nmetaCls: %@\nisMeta: %i\nname: %@\nsuperClassInfo: %@\nivarInfos: %@\nmethodInfos: %@\npropertyInfos: %@\n",[super description], NSStringFromClass(self.cls), NSStringFromClass(self.superCls), NSStringFromClass(self.metaCls), self.isMeta, self.name, self.superClassInfo, self.ivarInfos, self.methodInfos, self.propertyInfos];
}

@end
