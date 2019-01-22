//
//  UIControl+GWControl.h
//  TestDemo
//
//  Created by gw on 2018/7/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 创建block

 @param control 触发对象
 */
typedef void (^ActionBlock)(__kindof UIControl *control);
@interface UIControl (GWControl)

/**
 添加响应事件

 @param controlEvents UIControlEvents类型
 @param actionBlock 响应回调
 */
- (void)GW_addEvents:(UIControlEvents)controlEvents actionBlock:(ActionBlock)actionBlock;
@end
