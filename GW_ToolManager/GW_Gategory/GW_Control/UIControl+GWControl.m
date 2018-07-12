//
//  UIControl+GWControl.m
//  TestDemo
//
//  Created by gw on 2018/7/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "UIControl+GWControl.h"
#import <objc/runtime.h>

static NSString const *gwHeader = @"GW_";
const char *blockManager = "GWControl";

@implementation UIControl (GWControl)

- (void)GW_addEvents:(UIControlEvents)controlEvents actionBlock:(ActionBlock)actionBlock{
    NSMutableArray *blocks = objc_getAssociatedObject(self, blockManager);
    NSString *actionName = [self getUIControlEventsName:controlEvents];
    actionName = [gwHeader stringByAppendingString:actionName];
    if (!blocks) {
        blocks = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, blockManager, blocks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    __block BOOL result = YES;
    
    [blocks enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.allKeys.firstObject isEqualToString:actionName]) {
            result = NO;
            *stop = YES;
        }
    }];
    
    if (result) {
        [self createMethod:actionName];
        [self addTarget:self action:NSSelectorFromString(actionName) forControlEvents:controlEvents];
    }

    NSMutableDictionary<NSString *,ActionBlock> *blocksDic = [[NSMutableDictionary alloc] init];
    [blocksDic setValue:actionBlock forKey:actionName];
    [blocks addObject:blocksDic];
    
}

- (void)createMethod:(NSString *)actionName{
    Method m1 = class_getInstanceMethod(self.class, NSSelectorFromString(actionName));
    if (!m1) {
        class_addMethod(self.class, NSSelectorFromString(actionName), (IMP)actionIMP, "@v");
    }
}

void actionIMP(id obj,SEL _cmd,id newValue){
    NSString *actionName = NSStringFromSelector(_cmd);
    
    NSMutableArray *blocks = objc_getAssociatedObject(obj, blockManager);
    
    for (NSDictionary *dic in blocks) {
        if ([dic.allKeys.firstObject isEqualToString:actionName]) {
            ActionBlock block = [dic objectForKey:actionName];
            block(obj);
        }
    }
}

- (NSString *)getUIControlEventsName:(UIControlEvents)event{
    if (@available(iOS 9.0, *) ) {
        if (event == UIControlEventPrimaryActionTriggered) {
            return @"UIControlEventPrimaryActionTriggered";
        }
    }
    switch (event) {
        case UIControlEventTouchDown:
            return @"UIControlEventTouchDown";
        case UIControlEventTouchDownRepeat:
            return @"UIControlEventTouchDownRepeat";
        case UIControlEventTouchDragInside:
            return @"UIControlEventTouchDragInside";
        case UIControlEventTouchDragOutside:
            return @"UIControlEventTouchDragOutside";
        case UIControlEventTouchDragEnter:
            return @"UIControlEventTouchDragEnter";
        case UIControlEventTouchDragExit:
            return @"UIControlEventTouchDragExit";
        case UIControlEventTouchUpInside:
            return @"UIControlEventTouchUpInside";
        case UIControlEventTouchUpOutside:
            return @"UIControlEventTouchUpOutside";
        case UIControlEventTouchCancel:
            return @"UIControlEventTouchCancel";
        case UIControlEventValueChanged:
            return @"UIControlEventValueChanged";
        case UIControlEventEditingDidBegin:
            return @"UIControlEventEditingDidBegin";
        case UIControlEventEditingChanged:
            return @"UIControlEventEditingChanged";
        case UIControlEventEditingDidEnd:
            return @"UIControlEventEditingDidEnd";
        case UIControlEventEditingDidEndOnExit:
            return @"UIControlEventEditingDidEndOnExit";
        case UIControlEventAllTouchEvents:
            return @"UIControlEventAllTouchEvents";
        case UIControlEventAllEditingEvents:
            return @"UIControlEventAllEditingEvents";
        case UIControlEventApplicationReserved:
            return @"UIControlEventApplicationReserved";
        case UIControlEventSystemReserved:
            return @"UIControlEventSystemReserved";
        case UIControlEventAllEvents:
            return @"UIControlEventAllEvents";
            default:
            return @"";
    }
}


@end
