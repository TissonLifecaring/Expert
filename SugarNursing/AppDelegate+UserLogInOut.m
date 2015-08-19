//
//  AppDelegate+UserLogInOut.m
//  SugarNursing
//
//  Created by Dan on 14-11-6.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "AppDelegate+UserLogInOut.h"
#import "UIStoryboard+Storyboards.h"
#import "UtilsMacro.h"
#import "UMessage.h"
#import "SPKitExample.h"


@implementation AppDelegate (UserLogInOut)


#pragma mark LogIn
+ (void)userLogIn
{
    
    User*user = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context][0];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:user.username forKey:@"LastUsername"];
    [[CoreDataStack sharedCoreDataStack] saveContext];
    
    [self settingUMParameter];
    [self loginIMWithSuccessBlock:nil failedBlock:nil];
    
    [UIApplication sharedApplication].delegate.window.rootViewController = [[UIStoryboard mainStoryboard]
                                                                      instantiateInitialViewController];
}

+ (void)settingUMParameter
{
    
    User*user = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context][0];
    [UMessage addAlias:user.exptId type:@"expertId" response:nil];
    
    NSArray *objects = [UserInfomation findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    if (objects.count>0)
    {
        
        UserInfomation *info = objects[0];
        
        NSString *tag = [NSString stringWithFormat:@"center_%@",info.centerId];
        [UMessage addTag:tag response:nil];
    }
}





#pragma mark 登陆阿里百川
+ (void)loginIMWithSuccessBlock:(void(^)())successBlock failedBlock:(void(^)())failedBlock
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.ywIMKit)
    {
        NSString *openIMAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"openIMAccount"];
        NSString *openIMPwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"openIMPwd"];
        
        [[SPKitExample sharedInstance] exampleLoginWithUserID:openIMAccount password:openIMPwd successBlock:^{
            if (successBlock)
            {
                successBlock();
            }
        } failedBlock:^(NSError *aError) {
            if (failedBlock)
            {
                failedBlock();
            }
        }];
    }
}


#pragma mark LogOut
+ (void)userLogOut
{
    //删除绑定在该设备的别名
    NSArray *objects = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    if (objects && objects.count>0)
    {
        
        [self removeUMParameter];
        
        
        User*user = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context][0];
        user.sessionId = @"";
        user.sessionToken = @"";
        
        [LoadedLog deleteAllEntityInContext:[CoreDataStack sharedCoreDataStack].context];
        [[CoreDataStack sharedCoreDataStack] saveContext];
        
        //注销阿里百川
        [self logOutIM];
        
        [UIApplication sharedApplication].delegate.window.rootViewController = [[UIStoryboard loginStoryboard] instantiateInitialViewController];
    }
}


+ (void)logOutIM
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([[appDelegate.ywIMKit.IMCore getLoginService] isCurrentLogined])
    {
        [[SPKitExample sharedInstance] exampleLogout];
    }
}

+ (void)removeUMParameter
{
    
    
    User*user = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context][0];
    [UMessage removeAlias:user.exptId type:@"expertId" response:nil];
    [UMessage removeAllTags:^(id responseObject, NSInteger remain, NSError *error) {
    }];
}





#pragma mark - NormalMethod
+ (BOOL)isLogin
{
    NSArray *userObjects = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    if (userObjects.count<=0)
    {
        return NO;
    }
    else
    {
        User *user = userObjects[0];
        if (user.sessionId && user.sessionId.length>0 && user.sessionToken && user.sessionToken.length >0)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
}

@end
