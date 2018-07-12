
//
//  NSObject+GW_KVO.m
//  TestDemo
//
//  Created by gw on 2018/7/9.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "NSObject+GW_KVO.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
static NSString *const GW_SUB_KVO = @"GW_SUB_KVO_";
static const char *GW_ObserverKey = "GW_ObserverKey";
@interface GW_KVO_ObserverInfo:NSObject
@property (copy, nonatomic) NSString *observer;
@property (copy, nonatomic) NSString *keyPath;
@property (copy, nonatomic) GW_ObserverResult block;
@property (copy, nonatomic) NSString *type;
@property (weak, nonatomic, nullable) NSObject *context;
@end

@implementation GW_KVO_ObserverInfo

- (instancetype)initWithObserver:(NSString *)observer forKeyPath:(NSString *)keyPath context:(NSObject *)context block:(GW_ObserverResult)block{
    if (self = [super init]) {
        _observer = observer;
        _keyPath = keyPath;
        _context = context;
        _block = block;
    }
    return self;
}

@end

@implementation NSObject (GW_KVO)
static NSRecursiveLock *lock = nil;

- (void)GW_addObserver:(__weak NSObject *)observer forKeyPath:(NSString *)keyPath context:(__weak NSObject * _Nullable)context block:(GW_ObserverResult)block{
    NSString *setName = [NSString stringWithFormat:@"set%@:",[self changeKeyUpperKey:keyPath]];
    Method setMethod = class_getInstanceMethod(self.class, NSSelectorFromString(setName));
    
    
    NSString *subName = NSStringFromClass(self.class);
    if ([subName rangeOfString:GW_SUB_KVO].location == NSNotFound) {
        subName = [NSString stringWithFormat:@"%@%@",GW_SUB_KVO,NSStringFromClass(self.class)];
    }
    Class subClass = objc_lookUpClass(subName.UTF8String);
    if (!subClass) {
        subClass = objc_allocateClassPair(self.class, subName.UTF8String, 0);
        objc_registerClassPair(subClass);
    }
    
    IMP sss = class_getMethodImplementation(subClass, NSSelectorFromString(setName));
    NSLog(@"%p",sss);
    
    if (setMethod) {
        if (![NSStringFromClass(self.class) isEqualToString:subName] || ![self respondsToSelector:NSSelectorFromString(setName)]) {
            const char *setEncoder = method_getTypeEncoding(setMethod);
            [self GW_OverrideSetterFor:setName subClass:subClass setEncoder:setEncoder];
        }
    }else{
        Method m1 = class_getInstanceMethod(self.class, @selector(setValue:forKey:));
        Method m2 = class_getInstanceMethod(self.class, @selector(swizz_setValue:forKey:));
        method_exchangeImplementations(m1, m2);
    }
    
    object_setClass(self, subClass);
    
    NSMutableArray *observers = objc_getAssociatedObject(self, GW_ObserverKey);
    if (!observers) {
        observers = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, GW_ObserverKey, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    GW_KVO_ObserverInfo *info = [[GW_KVO_ObserverInfo alloc] initWithObserver:observer.description forKeyPath:keyPath context:context block:block];
    [observers addObject:info];
}

- (void)GW_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    if (!keyPath || keyPath.length == 0) {
        [self GW_removeObserver:observer];
        return;
    }
    NSMutableArray* observers = objc_getAssociatedObject(self, GW_ObserverKey);
    GW_KVO_ObserverInfo *info;
    for (GW_KVO_ObserverInfo* temp in observers) {
        if ([temp.observer isEqualToString:observer.description] && [temp.keyPath isEqualToString:keyPath]) {
            info = temp;
            break;
        }
    }
    if (info) {
        [observers removeObject:info];
    }
}

- (void)GW_removeObserver:(NSObject *)observer{
    NSMutableArray* observers = objc_getAssociatedObject(self, GW_ObserverKey);
    NSMutableArray *removes = [[NSMutableArray alloc] init];
    for (GW_KVO_ObserverInfo* temp in observers) {
        if ([temp.observer isEqualToString:observer.description]) {
            [removes addObject:temp];
        }
    }
    if (removes.count) {
        [observers removeObjectsInArray:removes];
    }
}

-(void)swizz_setValue:(id)value forKey:(NSString *)key{
    id oldValue = [self valueForKey:key];
    
    [self swizz_setValue:value forKey:key];
    
    NSMutableArray *observers = objc_getAssociatedObject(self, GW_ObserverKey);
    
    for (GW_KVO_ObserverInfo *info in observers) {
        if ([info.keyPath isEqualToString:key]) {
            info.block(self, key, oldValue, value, info.context);
        }
    }
}

- (void)GW_OverrideSetterFor:(NSString*)aKey subClass:(Class)subClass setEncoder:(const char *)setEncoder{

    IMP imp;
    SEL sel = NSSelectorFromString(aKey);
    if (sel == 0) {
        return;
    }
    NSMethodSignature *sig = [self.class instanceMethodSignatureForSelector: sel];
    
    if ([sig numberOfArguments] != 3){
        return;    // Not a valid setter method.
    }
    
    const char *type = [sig getArgumentTypeAtIndex: 2];
    switch (*type)
    {
        case _C_CHR:
        case _C_UCHR:
        case _C_BOOL:
        case _C_BFLD:
            imp = (IMP)setterChar;
            break;
        case _C_SHT:
        case _C_USHT:
            imp = (IMP)setterShort;
            break;
        case _C_INT:
        case _C_UINT:
            imp = (IMP)setterInt;
            break;
        case _C_LNG:
        case _C_ULNG:
            imp = (IMP)setterLong;
            break;
        case _C_LNG_LNG:
        case _C_ULNG_LNG:
            imp = (IMP)setterLongLong;
            break;
        case _C_FLT:
            imp = (IMP)setterFloat;
            break;
        case _C_DBL:
            imp = (IMP)setterDouble;
            break;
        case _C_ID:
        case _C_CLASS:
        case _C_PTR:
            imp = (IMP)setterIMP;
            break;
        case _C_STRUCT_B:{
            if (GW_SelectorTypesMatch(@encode(NSRange), type)){
                imp = (IMP)setterRange;
            }else if (GW_SelectorTypesMatch(@encode(CGPoint), type)){
                imp = (IMP)setterPoint;
            }else if (GW_SelectorTypesMatch(@encode(CGSize), type)){
                imp = (IMP)setterSize;
            }else if (GW_SelectorTypesMatch(@encode(CGRect), type)){
                imp = (IMP)setterRect;
            }else{
                imp = 0;
            }
        }
            break;
        default:
            imp = 0;
            break;
    }
    
    if (imp != 0){
        class_addMethod(subClass, sel, imp, setEncoder);
        
    }
}

- (IMP) instanceMethodForSelector: (SEL)aSelector{
    if (aSelector == 0){
        [NSException raise: NSInvalidArgumentException
                    format: @"%@ null selector given", NSStringFromSelector(_cmd)];
    }
    return class_getMethodImplementation((Class)self, aSelector);
}

BOOL GW_SelectorTypesMatch(const char *types1, const char *types2){
    if (!types1 || !types2){
        return NO;        // Nul pointers never match
    }
    if (types1 == types2){
        return YES;
    }
    
    while (*types1 && *types2){
        types1 = GW_SkipTypeQualifierAndLayoutInfo (types1);
        types2 = GW_SkipTypeQualifierAndLayoutInfo (types2);
        
        /* Reached the end of the selector.  */
        if (! *types1 && ! *types2){
            return YES;
        }
        
        /* Ignore structure name yet compare layout.  */
        if (*types1 == '{' && *types2 == '{'){
            while (*types1 != '=' && *types1 != '}'){
                types1++;
            }
            while (*types2 != '=' && *types2 != '}'){
                types2++;
            }
        }
        
        if (*types1 != *types2){
            return NO;
        }
        types1++;
        types2++;
    }
    
    types1 = GW_SkipTypeQualifierAndLayoutInfo (types1);
    types2 = GW_SkipTypeQualifierAndLayoutInfo (types2);
    
    return (! *types1 && ! *types2) ? YES : NO;
}


const char * GW_SkipTypeQualifierAndLayoutInfo(const char *types){
    while (*types == '+'
           || *types == '-'
           || *types == 'r'
           || *types == 'n'
           || *types == 'N'
           || *types == 'o'
           || *types == 'O'
           || *types == 'R'
           || *types == 'V'
           || *types == '!'
           || isdigit ((unsigned char) *types))
    {
        types++;
    }
    
    return types;
}

void setterRect(id obj,SEL _cmd,CGRect newValue){
    setterComment(obj, _cmd, [NSNumber valueWithCGRect:newValue],@"CGRect");
}
void setterSize(id obj,SEL _cmd,CGSize newValue){
    setterComment(obj, _cmd, [NSNumber valueWithCGSize:newValue],@"CGSize");
}

void setterPoint(id obj,SEL _cmd,CGPoint newValue){
    setterComment(obj, _cmd, [NSNumber valueWithCGPoint:newValue],@"CGPoint");
}

void setterRange(id obj,SEL _cmd,NSRange newValue){
    setterComment(obj, _cmd, [NSNumber valueWithRange:newValue],@"NSRange");
}

void setterShort(id obj,SEL _cmd,unsigned short newValue){
    setterComment(obj, _cmd, [NSNumber numberWithShort:newValue],@"short");
}

void setterLongLong(id obj,SEL _cmd,unsigned long long newValue){
    setterComment(obj, _cmd, [NSNumber numberWithUnsignedLongLong:newValue],@"longlong");
}

void setterLong(id obj,SEL _cmd,unsigned long newValue){
    setterComment(obj, _cmd, [NSNumber numberWithUnsignedLong:newValue],@"long");
}

void setterDouble(id obj,SEL _cmd,double newValue){
    setterComment(obj, _cmd, [NSNumber numberWithDouble:newValue],@"double");
}

void setterFloat(id obj,SEL _cmd,float newValue){
    setterComment(obj, _cmd, [NSNumber numberWithFloat:newValue],@"float");
}

void setterInt(id obj,SEL _cmd,unsigned int newValue){
    setterComment(obj, _cmd, [NSNumber numberWithUnsignedInt:newValue],@"int");
}

void setterChar(id obj,SEL _cmd,unsigned char newValue){
    setterComment(obj, _cmd, [NSNumber numberWithUnsignedChar:newValue],@"char");
}

void setterIMP(id obj,SEL _cmd,id newValue){
    setterComment(obj, _cmd, newValue,@"id");
}

void setterComment(id obj,SEL _cmd,id newValue,NSString *type){
    if (!lock) {
        lock = [[NSRecursiveLock alloc] init];
    }
    [lock lock];
    
    NSString *setName = NSStringFromSelector(_cmd);
    setName = [setName substringFromIndex:@"set".length];
    setName = [setName substringToIndex:setName.length-1];
    setName = [setName changeKeyLowerKey:setName];
    id oldValue = [obj valueForKey:setName];
    
    struct objc_super superStruct = {
        .receiver = obj,
        .super_class = class_getSuperclass(object_getClass(obj))
    };
    NSLog(@"%@",class_getSuperclass([obj class]));
    if ([type isEqualToString:@"id"]) {
        ((void (*)(void *,SEL,id))objc_msgSendSuper)(&superStruct,_cmd,newValue);
    }else if ([type isEqualToString:@"char"]) {
        ((void (*)(void *,SEL,unsigned char))objc_msgSendSuper)(&superStruct,_cmd,[newValue unsignedCharValue]);
    }else if ([type isEqualToString:@"int"]){
        ((void (*)(void *,SEL,unsigned int))objc_msgSendSuper)(&superStruct,_cmd,[newValue unsignedIntValue]);
    }else if ([type isEqualToString:@"float"]){
        ((void (*)(void *,SEL,float))objc_msgSendSuper)(&superStruct,_cmd,[newValue floatValue]);
    }else if ([type isEqualToString:@"double"]){
        ((void (*)(void *,SEL,double))objc_msgSendSuper)(&superStruct,_cmd,[newValue doubleValue]);
    }else if ([type isEqualToString:@"long"]){
        ((void (*)(void *,SEL,unsigned long))objc_msgSendSuper)(&superStruct,_cmd,[newValue unsignedLongValue]);
    }else if ([type isEqualToString:@"longlong"]){
        ((void (*)(void *,SEL,unsigned long long))objc_msgSendSuper)(&superStruct,_cmd,[newValue unsignedLongLongValue]);
    }else if ([type isEqualToString:@"short"]){
        ((void (*)(void *,SEL,unsigned short))objc_msgSendSuper)(&superStruct,_cmd,[newValue unsignedShortValue]);
    }else if ([type isEqualToString:@"NSRange"]){
        ((void (*)(void *,SEL,NSRange))objc_msgSendSuper)(&superStruct,_cmd,[newValue rangeValue]);
    }else if ([type isEqualToString:@"CGPoint"]){
        ((void (*)(void *,SEL,CGPoint))objc_msgSendSuper)(&superStruct,_cmd,[newValue CGPointValue]);
    }else if ([type isEqualToString:@"CGSize"]){
        ((void (*)(void *,SEL,CGSize))objc_msgSendSuper)(&superStruct,_cmd,[newValue CGSizeValue]);
    }else if ([type isEqualToString:@"CGRect"]){
        ((void (*)(void *,SEL,CGRect))objc_msgSendSuper)(&superStruct,_cmd,[newValue CGRectValue]);
    }
    
    NSMutableArray *observers = objc_getAssociatedObject(obj, GW_ObserverKey);
    for (GW_KVO_ObserverInfo *info in observers) {
        if ([info.keyPath isEqualToString:setName]) {
            info.block(obj, info.keyPath, oldValue, newValue, info.context);
        }
    }
    [lock unlock];
}

- (NSString *)changeKeyUpperKey:(NSString *)key{
    if (!key || key.length == 0) {
        return key;
    }
    NSRange range = NSMakeRange(0, 1);
    NSString *upperStr = [key substringWithRange:range].uppercaseString;
    key = [key stringByReplacingCharactersInRange:range withString:upperStr];
    return key;
}

- (NSString *)changeKeyLowerKey:(NSString *)key{
    if (!key || key.length == 0) {
        return key;
    }
    NSRange range = NSMakeRange(0, 1);
    NSString *lowerStr = [key substringWithRange:range].lowercaseString;
    key = [key stringByReplacingCharactersInRange:range withString:lowerStr];
    return key;
}

@end
