//
//  CustomViewController.m
//  SugarNursing
//
//  Created by Ian on 15/6/4.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "CustomViewController.h"

@interface CustomViewController ()

@end

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



#pragma mark - 强制设置竖屏
-(BOOL)shouldAutorotate
{
    return NO;
}


-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
