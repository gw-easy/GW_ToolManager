//
//  ViewController.m
//  GW_Gategory
//
//  Created by gw on 2018/7/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "ViewController.h"
#import "TestKVOVC.h"
#import <Foundation/Foundation.h>
#import "TestControlVC.h"
#import "GW_Gategory/GW_Control/UIControl+GWControl.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(50, 100, 200, 30);
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"jump" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn GW_addEvents:UIControlEventTouchUpInside actionBlock:^(UIButton *control) {
        [self.navigationController pushViewController:[TestKVOVC new] animated:YES];
    }];
    
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(50, 200, 200, 30);
    btn2.backgroundColor = [UIColor redColor];
    [btn2 setTitle:@"jump2" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    [btn2 GW_addEvents:UIControlEventTouchUpInside actionBlock:^(UIButton *control) {
        [self.navigationController pushViewController:[TestControlVC new] animated:YES];
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
