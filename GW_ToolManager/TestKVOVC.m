//
//  TestVC.m
//  GW_Gategory
//
//  Created by gw on 2018/7/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "TestKVOVC.h"
#import "NSObject+GW_KVO.h"
#import "GW_Gategory/GW_KVO/Worker.h"
#import "GW_KVOManager.h"
@interface TestKVOVC ()
@property (strong, nonatomic) Worker *ww;
@end

@implementation TestKVOVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSStringFromClass([self class]);
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self test1];
    [self test2];
}

- (void)test1{
    self.ww = [[Worker alloc] init];
    __weak Worker *ss = self.ww;
    __block NSDictionary *dic = @{@"abc":@"bcd"};
//    [self.ww GW_addObserver:self forKeyPath:@"name" context:dic block:^(NSObject * _Nonnull obj, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue, NSObject * _Nonnull context) {
//        NSLog(@"%@------",obj);
//        NSLog(@"%@------",keyPath);
//        NSLog(@"%@------",oldValue);
//        NSLog(@"%@------",newValue);
//        NSLog(@"%@------",context);
//
//    }];
    
//    [self.ww GW_addObserver:self forKeyPath:@"age" context:dic block:^(NSObject * _Nonnull obj, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue, NSObject * _Nonnull context) {
//        NSLog(@"%@------",obj);
//        NSLog(@"%@------",keyPath);
//        NSLog(@"%@------",oldValue);
//        NSLog(@"%@------",newValue);
//        NSLog(@"%@------",context);
//
//    }];
//
//    [self.ww GW_addObserver:self forKeyPath:@"age" context:dic block:^(NSObject * _Nonnull obj, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue, NSObject * _Nonnull context) {
//        NSLog(@"%@------",obj);
//        NSLog(@"%@------",keyPath);
//        NSLog(@"%@------",oldValue);
//        NSLog(@"%@------",newValue);
//        NSLog(@"%@------",context);
//
//    }];
//
//    [self.ww GW_addObserver:self forKeyPath:@"size" context:dic block:^(NSObject * _Nonnull obj, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue, NSObject * _Nonnull context) {
//        NSLog(@"%@------",obj);
//        NSLog(@"%@------",keyPath);
//        NSLog(@"%@------",oldValue);
//        NSLog(@"%@------",newValue);
//        NSLog(@"%@------",context);
//
//    }];

    NSLog(@"%@-----%@------%@",self,self.ww,[self.ww class]);
}

-(void)test2{
    self.ww = [[Worker alloc] init];
    
    [GW_KVOManager GW_KVOManagerListenerObj:self.ww forKeyPath:@"age" options:0|1 context:@(10) block:^(NSObject * _Nonnull obj, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue, id context) {
                NSLog(@"%@------",obj);
                NSLog(@"%@------",keyPath);
                NSLog(@"%@------",oldValue);
                NSLog(@"%@------",newValue);
                NSLog(@"%@------",context);
    }];
    
    
    [GW_KVOManager GW_KVOManagerListenerObj:self.ww forKeyPath:@"age" options:0|1 context:nil block:^(NSObject * _Nonnull obj, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue, id context) {
        NSLog(@"%@------",obj);
        NSLog(@"%@------",keyPath);
        NSLog(@"%@------",oldValue);
        NSLog(@"%@------",newValue);
        NSLog(@"%@------",context);
    }];
    
    [GW_KVOManager GW_KVOManagerListenerObj:self.ww forKeyPath:@"name" options:0|1 context:nil block:^(NSObject * _Nonnull obj, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue, id  _Nonnull context) {
        NSLog(@"%@------",obj);
        NSLog(@"%@------",keyPath);
        NSLog(@"%@------",oldValue);
        NSLog(@"%@------",newValue);
        NSLog(@"%@------",context);
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
            NSLog(@"%@------",object);
            NSLog(@"%@------",keyPath);
            NSLog(@"%@------",change);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.ww.name = @"12344";
    self.ww.age = 10;
    [self.ww setValue:@"eeeee" forKey:@"email"];
    self.ww.size = CGSizeMake(10, 10);
//    self.ww ->_email = @"wewewe";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    NSLog(@"%@----dealloc",self.title);
    [self.ww GW_removeObserver:self];
//    [self.ww removeObserver:self forKeyPath:@"age"];
    [GW_KVOManager GW_removeObserver:self.ww];
//    [self.ww removeObserver:self forKeyPath:@"_email"];
}

@end
