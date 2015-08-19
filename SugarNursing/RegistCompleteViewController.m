//
//  RegistCompleteViewController.m
//  SugarNursing
//
//  Created by Ian on 14-12-30.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "RegistCompleteViewController.h"
#import "AppDelegate+UserLogInOut.h"
@interface RegistCompleteViewController ()

@end

@implementation RegistCompleteViewController

- (IBAction)backLoginViewButtonEvent:(id)sender
{
    [AppDelegate userLogOut];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
