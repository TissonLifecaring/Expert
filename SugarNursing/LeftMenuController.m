//
//  LeftMenuController.m
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "LeftMenuController.h"
#import "LeftMenuCell.h"
#import "MemberInfoCell.h"
#import "UIStoryboard+Storyboards.h"
#import "MemberCenterViewController.h"
#import "AppDelegate+UserLogInOut.h"
#import "MsgRemind.h"
#import "UtilsMacro.h"
#import "UserInfoViewController.h"
#import "NotificationName.h"
#import <MBProgressHUD.h>
#import "UMessage.h"

typedef NS_ENUM(NSInteger, GCLanguageType)
{
    GCLanguageTypeSimplified = 1,
    GCLanguageTypeTraditional = 2,
    GCLanguageTypeEnglish = 3
};


@interface LeftMenuController ()<NSFetchedResultsControllerDelegate,MBProgressHUDDelegate>
{
    
}


@property (nonatomic, strong) NSArray *menuArray;
@property (nonatomic) NSInteger selectedIndex;

@end

@implementation LeftMenuController

- (void)awakeFromNib
{
    [super awakeFromNib];
    _selectedIndex = -1;
    if (!self.menuArray) {
        self.menuArray  = @[
                            @[NSLocalizedString(@"My Patient",),@"IconMyPatient"],
                            @[NSLocalizedString(@"My Hosting",),@"IconMyHosting"],
                            @[NSLocalizedString(@"My Takeover",),@"IconMyTakeover"],
                            @[NSLocalizedString(@"My Message",),@"IconMyMessage"],
                            @[NSLocalizedString(@"Member Center",),@"IconMemberCenter"],
                            @[NSLocalizedString(@"System Set",),@"IconSystemSet"],
                            @[NSLocalizedString(@"Log Out",),@"IconEmpty"],
                            ];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self configureMenu];
    [self requestForAPP];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
}


- (void)reloadLeftMenu
{
    [self.leftMenu reloadData];
}


- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    hud = nil;
}


- (void)configureMenu
{
    self.leftMenu.dataSource = self;
    self.leftMenu.delegate = self;
    
    self.leftMenu.rowHeight = UITableViewAutomaticDimension;
    self.leftMenu.estimatedRowHeight = 100;
}

- (void)requestForAPP
{
//    [self detectApplicationLanguage];
    
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
                
                [self.leftMenu reloadData];
                
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




#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuArray.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 140;
    } else return 52;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 )
    {
        
        MemberInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberInfoCell" forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        UserInfomation *info = [UserInfomation shareInfo];
        [cell.MemberInfoBG setImageWithURL:[NSURL URLWithString:info.headimageUrl]];
        cell.userNameLabel.text = info.exptName;
        cell.userSexLabel.text = info.sex;
        NSString *age = [NSString ageWithDateOfBirth:[NSDate dateByString:info.birthday dateFormat:@"yyyy-MM-dd"]];
        cell.userAgeLabel.text = [NSString stringWithFormat:@"%@%@",age,NSLocalizedString(@"old", nil)];
        return cell;
    }
    
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeftMenuCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    [cell configureCellWithIndexPath:indexPath iconName:self.menuArray[indexPath.row-1][1] LabelText:self.menuArray[indexPath.row-1][0]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
    if (self.selectedIndex == indexPath.row)
    {
        
        if (indexPath.row == 7)
        {
            [self switchToViewControllerAtIndex:self.selectedIndex];
            return;
        }
        [self.sideMenuViewController hideMenuViewController];
        return;
    }
    else
    {
        self.selectedIndex = indexPath.row;
        [self switchToViewControllerAtIndex:self.selectedIndex];
    }
}

- (void)switchToViewControllerAtIndex:(NSInteger)index
{
    
    switch (index)
    {
        case 0:
        {
            
            UserInfoViewController *userInfo = [[UIStoryboard memberCenterStoryboard] instantiateViewControllerWithIdentifier:@"UserInfo"];
            [userInfo.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStyleDone target:self action:@selector(menu:)]];
            UINavigationController *personalInfoNav = [[UINavigationController alloc] initWithRootViewController:userInfo];
            
            [personalInfoNav.navigationBar setBarTintColor:[UIColor colorWithRed:44/255.0 green:125/255.0 blue:198/255.0 alpha:1]];
            NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
            [personalInfoNav.navigationBar setTitleTextAttributes:attributes];
            [personalInfoNav.navigationBar setTintColor:[UIColor whiteColor]];
            [personalInfoNav.navigationBar setBarStyle:UIBarStyleBlack];
            [self.sideMenuViewController setContentViewController:personalInfoNav animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 1:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard myPatientStoryboard] instantiateViewControllerWithIdentifier:@"MyPatientNav"] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            
            break;
        case 2:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard myHostingStoryboard] instantiateViewControllerWithIdentifier:@"MyHostingNav"] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 3:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard myTakeoverStoryboard] instantiateViewControllerWithIdentifier:@"MyTakeoverNav"] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 4:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard myMessageStoryboard] instantiateViewControllerWithIdentifier:@"MyMessageNav"] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 5:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard memberCenterStoryboard] instantiateViewControllerWithIdentifier:@"MemberCenterNav"] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 6:
            [self.sideMenuViewController setContentViewController:[[UIStoryboard systemSetStoryboard] instantiateViewControllerWithIdentifier:@"SystemSetNav"] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 7:
            [self requestToLogOut];
            break;
        default:
            break;
    }
}


- (void)requestToLogOut
{
    
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.parentViewController.view];
    [self.parentViewController.view addSubview:hud];
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"Logout..", nil);
    [hud show:YES];
    
    NSDictionary *parameters = @{@"method":@"delSession",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"accountId":[NSString exptId],
                                 };
    [GCRequest delSessionWithParameters:parameters block:^(NSDictionary *responseData, NSError *error)
     {
        hud.mode = MBProgressHUDModeText;
        if (!error)
        {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"])
            {
                
                // User logout
                [AppDelegate userLogOut];
            }
            else
            {
                hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
            }
        }
        else
        {
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
        }
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
    }];
    

}

- (void)menu:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}


@end
