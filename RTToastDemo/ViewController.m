//
//  ViewController.m
//  RTToastDemo
//
//  Created by ColaBean on 2017/7/22.
//  Copyright © 2017年 ColaBean. All rights reserved.
//

#import "ViewController.h"
#import "RTToast.h"

@interface ViewController ()
{
    /*
     1.创建UI
     2.显示UI
     3.delay后消失
     task(1,2,3)
     */
    
    /*
     维护一个队列
     <<buffer>>FIFO
     */
    
    NSInteger count;
}
- (IBAction)toastAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toastAction:(id)sender {
    count++;
    [RTToast hint:@(count).stringValue showView:[[UIApplication sharedApplication] keyWindow]];
}
@end
