//
//  NSObject+GW_KVO.h
//  TestDemo
//
//  Created by gw on 2018/7/9.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

#pragma mark 缺点--将本身类变成了子类

typedef void(^GW_ObserverResult)(NSObject *obj,NSString *keyPath,id oldValue,id newValue,NSObject *context);

@interface NSObject (GW_KVO)

- (void)GW_addObserver:(__weak NSObject *)observer forKeyPath:(NSString *)keyPath context:(__weak NSObject * _Nullable)context block:(GW_ObserverResult)block;

- (void)GW_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

- (void)GW_removeObserver:(NSObject *)observer;

@end
NS_ASSUME_NONNULL_END
