//
//  UIControl+GWControl.h
//  TestDemo
//
//  Created by gw on 2018/7/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
// 创建block
typedef void (^ActionBlock)(__kindof __weak UIControl *control);
@interface UIControl (GWControl)
- (void)GW_addEvents:(UIControlEvents)controlEvents actionBlock:(ActionBlock)actionBlock;
@end
