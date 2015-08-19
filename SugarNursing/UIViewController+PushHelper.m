//
//  UIViewController+PushHelper.m
//  SugarNursing
//
//  Created by Ian on 15-4-22.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "UIViewController+PushHelper.h"
#import "SystemVersion.h"

@implementation UIViewController (PushHelper)


- (void)skipToViewController:(UIViewController *)vc
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        // conditionly check for any version >= iOS 8
        [self showViewController:vc sender:nil];
    }
    else
    {
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
