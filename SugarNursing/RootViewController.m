//
//  RootViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "RootViewController.h"
#import "UIStoryboard+Storyboards.h"
#import "MemberInfoCell.h"
#import "MemberCenterViewController.h"
#import "AppDelegate+UserLogInOut.h"
#import "MsgRemind.h"
#import "UtilsMacro.h"
#import "UserInfoViewController.h"
#import "NotificationName.h"
#import <MBProgressHUD.h>
#import "UMessage.h"
#import "AppDelegate+MessageControl.h"
#import "UIApplication+ResponseAPNS.h"
#import "SPKitExample.h"
#import "SPUtil.h"

typedef NS_ENUM(NSInteger, GCLanguageType)
{
    GCLanguageTypeSimplified = 1,
    GCLanguageTypeTraditional = 2,
    GCLanguageTypeEnglish = 3
};


@interface RootViewController ()


@end

@implementation RootViewController

- (void)awakeFromNib
{
    
    [self configureTabBar];
    [self requestForAPP];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [self.selectedViewController beginAppearanceTransition: YES animated: animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTabBarBadge:) name:NOT_RELOADTABBAR object:nil];
}


-(void)viewDidAppear:(BOOL)animated
{
    [self.selectedViewController endAppearanceTransition];
    
    [self reloadTabBarBadge:nil];
}


-(void) viewWillDisappear:(BOOL)animated
{
    [self.selectedViewController beginAppearanceTransition: NO animated: animated];
}


-(void) viewDidDisappear:(BOOL)animated
{
    [self.selectedViewController endAppearanceTransition];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOT_RELOADTABBAR object:nil];
}


- (void)reloadTabBarBadge:(NSNotification *)notification
{
    UITabBarItem *myMsgItem = self.tabBar.items[1];
    NSInteger messageCount = [AppDelegate msgCountOfMessageSection];
    if (messageCount >0)
    {
        [myMsgItem setBadgeValue:[NSString stringWithFormat:@"%ld",messageCount]];
    }
    else
    {
        [myMsgItem setBadgeValue:nil];
    }
    
    
    UITabBarItem *memberItem = self.tabBar.items[2];
    NSInteger memberCount = [AppDelegate msgCountOfMemberCenter];
    if (memberCount >0)
    {
        [memberItem setBadgeValue:[NSString stringWithFormat:@"%ld",[AppDelegate msgCountOfMemberCenter]]];
    }
    else
    {
        [memberItem setBadgeValue:nil];
    }
    
}


- (void)configureTabBar
{
    
    [self setViewControllers:[self items]];
    
    UITabBarItem *patientItem = [self.tabBar.items objectAtIndex:0];
    UITabBarItem *messageItem = [self.tabBar.items objectAtIndex:1];
    UITabBarItem *memberItem = [self.tabBar.items objectAtIndex:2];
    
    [patientItem setTitle:NSLocalizedString(@"patient", nil)];
    [messageItem setTitle:NSLocalizedString(@"message", nil)];
    [memberItem setTitle:NSLocalizedString(@"mine", nil)];
    
    
    [patientItem setImage:[UIImage imageNamed:@"br"]];
    [patientItem setSelectedImage:[UIImage imageNamed:@"br_on"]];
    [messageItem setImage:[UIImage imageNamed:@"xx"]];
    [messageItem setSelectedImage:[UIImage imageNamed:@"xx_on"]];
    [memberItem setImage:[UIImage imageNamed:@"wd"]];
    [memberItem setSelectedImage:[UIImage imageNamed:@"wd_on"]];
    
    [self setSelectedIndex:1];
    [self setSelectedIndex:2];
    [self setSelectedIndex:0];
}


- (void)requestForAPP
{
    
    if ([LoadedLog needReloadedByKey:@"userInfo"] || ![UserInfomation existWithContext:[CoreDataStack sharedCoreDataStack].context])
    {
        [self requestUserInfo];
    }
    if (![ServCenter existWithContext:[CoreDataStack sharedCoreDataStack].context])
    {
        [self requestForServiceCenter];
    }
    if (![Department existWithContext:[CoreDataStack sharedCoreDataStack].context])
    {
        [self requestForDepartment];
    }
    
}


#pragma mark - 检测语言并添加到服务器
- (void)detectApplicationLanguage
{
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSArray *allLanguages = [user objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = allLanguages[0];
    
    NSString *lastLanguages = [user objectForKey:@"LastLanguages"];
    if (!lastLanguages || ![currentLanguage isEqualToString:lastLanguages])
    {
        GCLanguageType langugeType;
        if ([currentLanguage isEqualToString:@"zh-Hans"])
        {
            [UMessage removeTag:@"lang_2" response:nil];
            [UMessage removeTag:@"lang_3" response:nil];
            
            [UMessage addTag:@"lang_1" response:nil];
            langugeType = GCLanguageTypeSimplified;
        }
        else if ([currentLanguage isEqualToString:@"zh-Hant"])
        {
            [UMessage removeTag:@"lang_1" response:nil];
            [UMessage removeTag:@"lang_3" response:nil];
            
            [UMessage addTag:@"lang_2" response:nil];
            langugeType = GCLanguageTypeTraditional;
        }
        else if ([currentLanguage isEqualToString:@"en"])
        {
            
            [UMessage removeTag:@"lang_1" response:nil];
            [UMessage removeTag:@"lang_2" response:nil];
            
            [UMessage addTag:@"lang_3" response:nil];
            langugeType = GCLanguageTypeEnglish;
        }
        else if ([currentLanguage isEqualToString:@"zh-HK"])
        {
            [UMessage removeTag:@"lang_1" response:nil];
            [UMessage removeTag:@"lang_3" response:nil];
            
            [UMessage addTag:@"lang_2" response:nil];
            langugeType = GCLanguageTypeTraditional;
        }
        else
        {
            [UMessage removeTag:@"lang_1" response:nil];
            [UMessage removeTag:@"lang_3" response:nil];
            
            [UMessage addTag:@"lang_2" response:nil];
            langugeType = GCLanguageTypeTraditional;
        }
        
        [self updateServerSystemLanguage:langugeType];
    }
}

#pragma mark - Net Working
- (void)updateServerSystemLanguage:(GCLanguageType)langugeType
{
    
    NSDictionary *parameters = @{@"method":@"setUserLanguage",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"sessionToken":[NSString sessionToken],
                                 @"accountId":[NSString exptId],
                                 @"language":[NSString stringWithFormat:@"%ld",langugeType]};
    
    [GCRequest setUserLanguageWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        
        if (!error)
        {
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSArray *allLanguages = [user objectForKey:@"AppleLanguages"];
                NSString *currentLanguage = allLanguages[0];
                
                [user setObject:currentLanguage forKey:@"LastLanguages"];
                [user synchronize];
            }
        }
    }];
}


- (void)requestUserInfo
{
    
    NSDictionary *parameters = @{@"method":@"getPersonalInfo",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"exptId":[NSString exptId]};
    
    [GCRequest getPersonalInfoWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        NSArray *objects = [UserInfomation findAllInContext:[CoreDataStack sharedCoreDataStack].context];
        
        UserInfomation *info;
        
        if (objects.count <= 0)
        {
            info = [UserInfomation createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
            
        }
        else
        {
            info = objects[0];
        }
        
        info.exptId = [NSString exptId];
        
        if (!error)
        {
            
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                
                responseData = [responseData[@"expert"] mutableCopy];
                
                [responseData sexFormattingToUserForKey:@"sex"];
                
                [responseData dateFormattingToUserForKey:@"birthday"];
                
                [responseData expertLevelFormattingToUserForKey:@"expertLevel"];
                
                [info updateCoreDataForData:responseData withKeyPath:nil];
                
                [LoadedLog shareLoadedLog].userInfo = [NSString stringWithDateFormatting:@"yyyyMMddHHmmss" date:[NSDate date]];
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
            }
            else
            {
                
            }
        }
        else
        {
            
        }
        
        [[CoreDataStack sharedCoreDataStack] saveContext];
    }];
}


- (void)requestForServiceCenter
{
    if (![ServCenter existWithContext:[CoreDataStack sharedCoreDataStack].context])
    {
        
        
        NSDictionary *parameters = @{@"method":@"getCenterInfoList",
                                     @"centerId":@"1",
                                     @"type":@"3"};
        [GCRequest getCenterInfoListWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
            if (!error)
            {
                if ([responseData[@"ret_code"] isEqualToString:@"0"])
                {
                    NSArray *array = responseData[@"centerList"];
                    
                    [ServCenter deleteAllEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    
                    [ServCenter updateCoreDataWithListArray:array identifierKey:@"centerId"];
                    
                    [[CoreDataStack sharedCoreDataStack] saveContext];
                }
            }
        }];
    }
}

- (void)requestForDepartment
{
    if (![Department existWithContext:[CoreDataStack sharedCoreDataStack].context])
    {
        
        NSDictionary *parameters = @{@"method":@"getDepartmentInfoList",
                                     @"departmentId":@"1",
                                     @"type":@"3"};
        
        [GCRequest getDepartmentInfoListWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
            if (!error)
            {
                
                if ([responseData[@"ret_code"] isEqualToString:@"0"])
                {
                    NSArray *array = responseData[@"departmentList"];
                    
                    [Department deleteAllEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    
                    [Department updateCoreDataWithListArray:array identifierKey:@"departmentId"];
                    
                    [[CoreDataStack sharedCoreDataStack] saveContext];
                }
            }
            
        }];
    }
}





#pragma mark - All Items
- (NSArray *)items
{
    UINavigationController *patientNav = [[UIStoryboard myPatientStoryboard] instantiateViewControllerWithIdentifier:@"MyPatientNav"];
    
    UINavigationController *messageNav = [[UIStoryboard myMessageStoryboard] instantiateViewControllerWithIdentifier:@"MyMessageNav"];
    
    UINavigationController *memberNav = [[UIStoryboard memberCenterStoryboard] instantiateViewControllerWithIdentifier:@"MemberCenterNav"]; 
    
    
    return [NSArray arrayWithObjects:patientNav, messageNav, memberNav,nil];
}

@end
