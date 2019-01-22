//
//  TestControlVC.m
//  GW_Gategory
//
//  Created by gw on 2018/7/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "TestControlVC.h"
#import "UIControl+GWControl.h"
@interface TestControlVC ()

@end

@implementation TestControlVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSStringFromClass([self class]);
    self.view.backgroundColor = [UIColor whiteColor];
    [self test1];
    [self test2];
}

- (void)test1{
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(50, 200, 200, 30);
    btn1.backgroundColor = [UIColor redColor];
    [btn1 setTitle:@"hehe" forState:UIControlStateNormal];
    [self.view addSubview:btn1];
    //    支持响应多次加载时间
    [btn1 GW_addEvents:UIControlEventTouchUpInside actionBlock:^(UIButton *control) {
        NSLog(@"111");
    }];
    [btn1 GW_addEvents:UIControlEventTouchUpInside actionBlock:^(UIButton *control) {
        [control setTitle:@"222" forState:UIControlStateNormal];
        NSLog(@"222");
    }];
    
    //    同时支持多种手势
    [btn1 GW_addEvents:UIControlEventTouchUpOutside actionBlock:^(UIButton *control) {
        NSLog(@"333");
    }];
    
    [btn1 GW_addEvents:UIControlEventTouchDown actionBlock:^(UIButton *control) {
        [control setTitle:@"444" forState:UIControlStateNormal];
        NSLog(@"444");
    }];
}

- (void)test2{
    UISlider *sV = [[UISlider alloc] init];
    sV.frame = CGRectMake(50, 300, 200, 30);
    sV.maximumValue = 10;
    sV.value = 3;
    [self.view addSubview:sV];
    
    [sV GW_addEvents:UIControlEventValueChanged actionBlock:^(UISlider *__weak control) {
        NSLog(@"%f",control.value);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    NSLog(@"%@------delloc",self.title);
}

@end
