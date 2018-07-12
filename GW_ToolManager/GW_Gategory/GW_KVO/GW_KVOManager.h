//
//  GW_KVOManager.h
//  GW_Gategory
//
//  Created by gw on 2018/7/11.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
typedef void(^GW_KVOResult)(NSObject *obj,NSString *keyPath,id oldValue,id newValue, id context);

@interface GW_KVOManager : NSObject
+ (void)GW_KVOManagerListenerObj:(__weak NSObject *)listenerObj forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(_Nullable id)context block:(GW_KVOResult)block;

+ (void)GW_RemoveKVOManagerListenerObj:(NSObject *)listenerObj forKeyPath:(NSString *)keyPath context:(void *)context;

+ (void)GW_RemoveKVOManagerListenerObj:(NSObject *)listenerObj forKeyPath:(NSString *)keyPath;

+ (void)GW_RemoveKVOManagerListenerObj:(NSObject *)listenerObj;
@end
NS_ASSUME_NONNULL_END
