//
//  worker.h
//  TestDemo
//
//  Created by gw on 2018/7/4.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Worker : NSObject{
    @public
    NSString *_email;
}
@property (copy, nonatomic) NSString *name;

@property (assign, nonatomic) int age;

@property (copy, nonatomic) NSString *school;

@property (copy, nonatomic) NSString *work;

@property (assign, nonatomic) CGSize size;
@end
