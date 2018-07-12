//
//  GW_KVOManager.m
//  GW_Gategory
//
//  Created by gw on 2018/7/11.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_KVOManager.h"

typedef enum : NSUInteger {
    allInfo = 0,
    keyPathInfo,
    contextInfo,
} GW_RemoveInfo;

static NSString const*ob = @"observer";
static NSString const*obKeyPath = @"keyPath";
static NSString const*obBlock = @"block";


#define GW_ShareManager [GW_KVOManager shareManager]
@interface GW_SYSKVO_ObserverInfo:NSObject
@property (weak, nonatomic) NSObject *observer;
@property (copy, nonatomic) NSString *keyPath;
@property (copy, nonatomic) GW_KVOResult block;
@property (copy, nonatomic) NSString *blockDescription;
@property (copy, nonatomic) NSString *type;
@property (strong, nonatomic) NSDictionary *dict;
@property (weak, nonatomic) id oldValue;
@property (weak, nonatomic) id obContext;


@end

@implementation GW_SYSKVO_ObserverInfo

- (instancetype)initWithObserver:(__weak NSObject *)observer forKeyPath:(NSString *)keyPath context:(id)context oldValue:(id)oldValue block:(GW_KVOResult)block dict:(NSDictionary *)dict{
    if (self = [super init]) {
        _observer = observer;
        _keyPath = keyPath;
        _obContext = context;
        _oldValue = oldValue;
        _block = block;
        _dict = dict;
        _blockDescription = [NSString stringWithFormat:@"%@",block];
    }
    return self;
}

@end

static NSString *const GW_ContextKey = @"GW_ContextKey";
static NSString *const GW_BlockKey = @"GW_BlockKey";

@interface GW_KVOManager(){
    dispatch_semaphore_t semaphore;
    dispatch_semaphore_t removeSemaphore;
}

@property (strong, nonatomic) NSMutableArray *observers;
@property (strong, nonatomic) NSMapTable *mapT;
@end

@implementation GW_KVOManager
static GW_KVOManager *base = nil;
+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        base = [[super allocWithZone:NULL] init];
    });
    return base;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return base;
}

- (instancetype)init{
    if (self = [super init]) {
        self.observers = [[NSMutableArray alloc] init];
        self.mapT = [NSMapTable weakToWeakObjectsMapTable];
        semaphore = dispatch_semaphore_create(1);
        removeSemaphore = dispatch_semaphore_create(1);
    }
    return self;
}

+ (void)GW_KVOManagerListenerObj:(__weak NSObject *)listenerObj forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(id)context block:(GW_KVOResult)block{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:context forKey:GW_ContextKey];
    [dict setValue:[NSString stringWithFormat:@"%@",block] forKey:GW_BlockKey];
    NSDictionary *conDic = dict;
    GW_SYSKVO_ObserverInfo *kvo = [[GW_SYSKVO_ObserverInfo alloc] initWithObserver:listenerObj forKeyPath:keyPath context:context oldValue:[listenerObj valueForKey:keyPath] block:block dict:conDic];
    [GW_ShareManager.observers addObject:kvo];
//    (__bridge void *)注意事项 必须保证对象地址不被释放
    [listenerObj addObserver:GW_ShareManager forKeyPath:keyPath options:options context:(__bridge void *)(dict)];
}

+ (void)GW_RemoveKVOManagerListenerObj:(NSObject *)listenerObj forKeyPath:(NSString *)keyPath context:(void *)context select:(GW_RemoveInfo)select{
    dispatch_semaphore_wait(GW_ShareManager->removeSemaphore, DISPATCH_TIME_FOREVER);
    NSMutableArray *removes = [[NSMutableArray alloc] init];
    switch (select) {
        case allInfo:{
            for (GW_SYSKVO_ObserverInfo* temp in GW_ShareManager.observers) {
                if (temp.observer == listenerObj) {
                    [temp.observer removeObserver:GW_ShareManager forKeyPath:temp.keyPath];
                    [removes addObject:temp];
                }
            }
            break;
        }
        case keyPathInfo: {
            for (GW_SYSKVO_ObserverInfo* temp in GW_ShareManager.observers) {
                if (temp.observer == listenerObj && [temp.keyPath isEqualToString:keyPath]) {
                    [temp.observer removeObserver:GW_ShareManager forKeyPath:temp.keyPath];
                    [removes addObject:temp];
                }
            }
            break;
        }
        case contextInfo: {
            for (GW_SYSKVO_ObserverInfo* temp in GW_ShareManager.observers) {
                if (temp.observer == listenerObj && [temp.keyPath isEqualToString:keyPath] && temp.obContext == context) {
                    [temp.observer removeObserver:GW_ShareManager forKeyPath:temp.keyPath context:context];
                    [removes addObject:temp];
                }
            }
            break;
        }
    }
    if (removes.count) {
        [GW_ShareManager.observers removeObjectsInArray:removes];
    }
    dispatch_semaphore_signal(GW_ShareManager->removeSemaphore);
}

+ (void)GW_RemoveKVOManagerListenerObj:(NSObject *)listenerObj forKeyPath:(NSString *)keyPath context:(void *)context{
    [self GW_RemoveKVOManagerListenerObj:listenerObj forKeyPath:keyPath context:context select:contextInfo];
}

+ (void)GW_RemoveKVOManagerListenerObj:(NSObject *)listenerObj forKeyPath:(NSString *)keyPath{
    [self GW_RemoveKVOManagerListenerObj:listenerObj forKeyPath:keyPath context:nil select:keyPathInfo];
}

+ (void)GW_RemoveKVOManagerListenerObj:(NSObject *)listenerObj{
    [self GW_RemoveKVOManagerListenerObj:listenerObj forKeyPath:@"" context:nil select:allInfo];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    __weak NSDictionary *dic = (__bridge NSDictionary *)(context);
    NSString *blockKey = dic[GW_BlockKey];
    for (GW_SYSKVO_ObserverInfo *info in self.observers) {
        if (info.observer == object && [info.keyPath isEqualToString:keyPath] && [info.blockDescription isEqualToString:blockKey]) {
            info.block(object, keyPath, info.oldValue, change[NSKeyValueChangeNewKey], info.obContext);
            info.oldValue = change[NSKeyValueChangeNewKey];
        }
    }
    dispatch_semaphore_signal(semaphore);
}

- (void)dealloc{
    semaphore = nil;
    removeSemaphore = nil;
    for (GW_SYSKVO_ObserverInfo *info in self.observers) {
        [info.observer removeObserver:self forKeyPath:info.keyPath];
    }
}

@end
