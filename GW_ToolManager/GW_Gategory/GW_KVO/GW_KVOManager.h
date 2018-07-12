//
//  GW_KVOManager.h
//  GW_Gategory
//
//  Created by gw on 2018/7/11.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

/**
 block

 @param obj 被检查者对象
 @param keyPath 属性
 @param oldValue 原始值
 @param newValue 新值
 @param context 传值
 */
typedef void(^GW_KVOResult)(NSObject *obj,NSString *keyPath,id oldValue,id newValue, id context);

@interface GW_KVOManager : NSObject

/**
 添加被监听者

 @param listenerObj 被监听者
 @param keyPath 属性
 @param options options
 @param context 传值
 @param block 回调
 */
+ (void)GW_KVOManagerListenerObj:(__weak NSObject *)listenerObj forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(_Nullable id)context block:(GW_KVOResult)block;


/**
 移除

 @param listenerObj 被监听者
 @param keyPath 属性
 @param context 传值 需要和添加时保持一致（如果是对象，需要对象一致，地址相同）
 */
+ (void)GW_RemoveKVOManagerListenerObj:(NSObject *)listenerObj forKeyPath:(NSString *)keyPath context:(void *)context;


/**
 移除
 
 @param listenerObj 被监听者
 @param keyPath 属性
 */
+ (void)GW_RemoveKVOManagerListenerObj:(NSObject *)listenerObj forKeyPath:(NSString *)keyPath;


/**
 移除
 
 @param listenerObj 被监听者
 */
+ (void)GW_RemoveKVOManagerListenerObj:(NSObject *)listenerObj;
@end
NS_ASSUME_NONNULL_END
