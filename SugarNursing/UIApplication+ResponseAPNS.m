//
//  UIApplication+ResponseAPNS.m
//  SugarNursing
//
//  Created by Ian on 15-3-4.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "UIApplication+ResponseAPNS.h"
#import "UIStoryboard+Storyboards.h"
#import <RESideMenu.h>
#import "AppDelegate.h"
#import "RootViewController.h"
#import "MessageInfoViewController.h"
#import "MyMessageViewController.h"
#import "SystemVersion.h"
#import "MsgRemind.h"
#import "CoreDataStack.h"
#import "MemberCenterViewController.h"
#import "NotificationName.h"
#import "UIViewController+PushHelper.h"

@implementation UIApplication (ResponseAPNS)


+ (void)responseAPNS:(NSDictionary *)info
{
    
    NSDictionary *content = [self analysisRespondData:info];
    
    if (!content || content.count<=0)
    {
        return;
    }
    NSString *type = content[@"type"];
    
    
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    if (state == UIApplicationStateActive)
    {
        
    }
    else if (state == UIApplicationStateBackground)
    {
        [self responseNotificationWithType:type];
    }
    else if (state == UIApplicationStateInactive)
    {
        [self responseNotificationWithType:type];
    }
}

+ (void)responseNotificationWithType:(NSString *)type
{
    if ([type isEqualToString:@"messageApprove"])
    {
        [self notificationRespondForMessageWithType:MsgTypeApprove];
    }
    else if ([type isEqualToString:@"messgeBulletin"])
    {
        [self notificationRespondForMessageWithType:MsgTypeBulletin];
    }
    else if ([type isEqualToString:@"messageAgent"])
    {
        [self notificationRespondForMessageWithType:MsgTypeAgent];
    }
    else if ([type isEqualToString:@"trusteeshipConfirm"])
    {
        [self notificationRespondForMyHosting];
    }
    else if ([type isEqualToString:@"trusteeshipRefuse"])
    {
        [self notificationRespondForMyHosting];
    }
    else if ([type isEqualToString:@"takeoverWait"])
    {
        [self notificationRespondForMyTakeover];
    }
    else if ([type isEqualToString:@"patientList"])
    {
        [self notificationRespondForPatientList];
    }
}

+ (void)notificationRespondForPatientList
{
    RootViewController *rootVC = (RootViewController *)[self sharedApplication].delegate.window.rootViewController;
    [rootVC configureTabBar];
    [rootVC setSelectedIndex:0];
    
    UINavigationController *navigationVC = rootVC.viewControllers[0];
    if ([navigationVC.viewControllers count]>1)
    {
        [navigationVC popToRootViewControllerAnimated:NO];
    }
}



+ (void)notificationRespondForMessageWithType:(MsgType)msgType
{
    
    RootViewController *rootVC = (RootViewController *)[self sharedApplication].delegate.window.rootViewController;
    [rootVC configureTabBar];
    [rootVC setSelectedIndex:1];
    
    UINavigationController *navigationVC = rootVC.viewControllers[1];
    if ([navigationVC.viewControllers count]>1)
    {
        [navigationVC popToRootViewControllerAnimated:NO];
    }
    
}

+ (void)notificationRespondForMyHosting
{
    
    RootViewController *rootVC = (RootViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [rootVC configureTabBar];
    if (rootVC.selectedIndex != 2)
    {
        [rootVC setSelectedIndex:2];
    }

    UINavigationController *navigationVC = rootVC.viewControllers[2];
    if ([navigationVC.viewControllers count]>1)
    {
        [navigationVC popToRootViewControllerAnimated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTABBAR object:nil];
//    MemberCenterViewController *vc = navigationVC.viewControllers[0];
//    
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
//    {
//        // conditionly check for any version >= iOS 8
//        [vc showViewController:[[UIStoryboard myHostingStoryboard] instantiateInitialViewController] sender:nil];
//    }
//    else
//    {
//        [vc.navigationController pushViewController:vc animated:YES];
//    }
}

+ (void)notificationRespondForMyTakeover
{
    
    RootViewController *rootVC = (RootViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [rootVC configureTabBar];
    if (rootVC.selectedIndex != 2)
    {
        [rootVC setSelectedIndex:2];
    }

    UINavigationController *navigationVC = rootVC.viewControllers[2];
    if ([navigationVC.viewControllers count]>1)
    {
        [navigationVC popToRootViewControllerAnimated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTABBAR object:nil];
    
    
//    MemberCenterViewController *vc = navigationVC.viewControllers[0];
//
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
//    {
//        // conditionly check for any version >= iOS 8
//        [vc showViewController:[[UIStoryboard myTakeoverStoryboard] instantiateInitialViewController] sender:nil];
//    }
//    else
//    {
//        [vc.navigationController pushViewController:vc];
//    }

}



+ (void)skipToViewController:(UIViewController *)viewController showItemIndex:(NSInteger)itemIndex
{
    RootViewController *rootVC = (RootViewController *)[self sharedApplication].delegate.window.rootViewController;
    
    [rootVC setSelectedIndex:itemIndex];
}


+ (NSDictionary *)analysisRespondData:(NSDictionary *)respondData
{
    NSString *jsonString = respondData[@"content"];
    if (jsonString && [jsonString isKindOfClass:[NSString class]])
    {
        NSData *contentData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *content = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:nil];
        return content;
    }
    return nil;
}
@end
