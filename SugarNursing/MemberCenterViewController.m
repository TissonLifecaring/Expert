//
//  MemberCenterViewController.m
//  SugarNursing
//
//  Created by Ian on 14-11-17.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "MemberCenterViewController.h"
#import "AppDelegate+UserLogInOut.h"
#import "UIStoryboard+Storyboards.h"
#import "CustomLabel.h"
#import "ThumbnailImageView.h"
#import "UtilsMacro.h"
#import <MBProgressHUD.h>
#import "VerificationViewController.h"
#import "DeviceHelper.h"
#import "RootViewController.h"
#import "MsgRemind.h"
#import "NotificationName.h"

static CGFloat kUserInfoCellHeight = 80;
static CGFloat kUserInfoCellMaginLeft = 20;
static CGFloat kUserInfoCellImageHeightWidth = 50;

static CGFloat kUserInfoViewMagin = 10;



static CGFloat kDefaultCellHeight = 44;


typedef enum
{
    UserInfoCellItemTagUserImageView = 1001,
    UserInfoCellItemTagUsernameLabel,
    UserInfoCellItemTagMajorLabe,
    UserInfoCellItemTagRankLabel
}UserInfoCellViewTag;


@interface MemberCenterViewController ()<MBProgressHUDDelegate>
{
    UserInfomation *_info;
    MBProgressHUD *hud;
}



@end

@implementation MemberCenterViewController
@synthesize mainTableView;

- (void)awakeFromNib
{
    
    _info = [UserInfomation shareInfo];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMemberList:) name:NOT_RELOADMEMBERLIST object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)reloadMemberList:(NSNotification *)notification
{
    [self.mainTableView reloadData];
}


- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    [hud2 removeFromSuperview];
    hud2 = nil;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.mainTableView reloadData];
}



#pragma mark ** UITableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 3;
            break;
        default:
            return 1;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 12;
            break;
        case 1:
            return 10;
            break;
        default:
            return 8;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0)
    {
        return kUserInfoCellHeight;
    }
    else
    {
        return kDefaultCellHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.section)
    {
        case 0:
            [self performSegueWithIdentifier:@"goUserInfo" sender:nil];
            break;
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    [self skipToViewController:[[UIStoryboard myHostingStoryboard] instantiateInitialViewController]];
                }
                    break;
                case 1:
                {
                    [self skipToViewController:[[UIStoryboard myTakeoverStoryboard] instantiateInitialViewController]];
                }
                    break;
                case 2:
                {
                    [self skipToViewController:[[UIStoryboard systemSetStoryboard] instantiateInitialViewController]];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            if (indexPath.row == 0)
            {
                [self performSegueWithIdentifier:@"goAboutMe" sender:nil];
            }
            else if (indexPath.row == 1)
            {
                [self performSegueWithIdentifier:@"goTermsOfService" sender:nil];
            }
            else
            {
                [self performSegueWithIdentifier:@"goFeedBack" sender:nil];
            }
        }
            break;
        case 3:
            [self requestToLogOut];
            break;
        default:
            break;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        static NSString *identifierUserInfo = @"UserInfoCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierUserInfo];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:@"UserInfoCell"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
            [self setupUserInfoCell:cell];
        }
        
        
        CustomLabel *usernameLabel = (CustomLabel *)[cell viewWithTag:UserInfoCellItemTagUsernameLabel];
        ThumbnailImageView *imageView = (ThumbnailImageView *)[cell viewWithTag:UserInfoCellItemTagUserImageView];
        CustomLabel *rankLabel = (CustomLabel *)[cell viewWithTag:UserInfoCellItemTagRankLabel];
        CustomLabel *majorLabel = (CustomLabel *)[cell viewWithTag:UserInfoCellItemTagMajorLabe];
        if (_info.headimageUrl && _info.headimageUrl.length>0)
        {
            [imageView setImageWithURL:[NSURL URLWithString:_info.headimageUrl] placeholderImage:nil];
        }
        else
        {
            [imageView setImage:[UIImage imageNamed:@"thumbDefault"]];
        }
        
        [usernameLabel setText:_info.exptName];
        [rankLabel setText:_info.expertLevel];
        [majorLabel setText:[Department getDepartmentNameByID:_info.departmentId]];
        
        
        CGSize size = [self sizeWithString:majorLabel.text
                                      font:majorLabel.font
                                   maxSize:CGSizeMake(CGRectGetWidth(self.view.bounds)/2.5, 20)];
        
        [majorLabel setFrame:CGRectMake(usernameLabel.frame.origin.x,
                                        usernameLabel.frame.origin.y + usernameLabel.frame.size.height + kUserInfoViewMagin/2,
                                        size.width,
                                        size.height)];
        
        
        [rankLabel setFrame:CGRectMake(majorLabel.frame.origin.x + majorLabel.bounds.size.width + kUserInfoViewMagin/2,
                                       majorLabel.frame.origin.y,
                                       CGRectGetWidth(self.view.bounds)/3,
                                       majorLabel.bounds.size.height)];
        
        return cell;
    }
    else if (indexPath.section == 3)
    {
        static NSString *logoutIdentifier = @"logoutCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:logoutIdentifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:logoutIdentifier];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.backgroundColor = [UIColor orangeColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        }
            
        cell.textLabel.text = [self titleWithIndexPath:indexPath];
        return cell;
    }
    else
    {
        UITableViewCell *cell ;
        
        if (indexPath.section == 1 && indexPath.row < 2)
        {
            static NSString *identifierDefault = @"messageCell";
            cell = [tableView dequeueReusableCellWithIdentifier:identifierDefault];
            
            
            UILabel *titleLabel = (UILabel *)[cell viewWithTag:1000];
            UIImageView *messagePoint = (UIImageView *)[cell viewWithTag:1001];
            
            MsgRemind *remind = [MsgRemind shareMsgRemind];
            
            if (indexPath.row == 0)
            {
                [titleLabel setText:NSLocalizedString(@"My Hosting", nil)];
                if ([remind.hostingConfirmRemindCount integerValue] > 0 ||
                    [remind.hostingRefuseRemindCount integerValue] >0)
                {
                    messagePoint.hidden = NO;
                }
                else
                {
                    messagePoint.hidden = YES;
                }
            }
            else
            {
                [titleLabel setText:NSLocalizedString(@"My Takeover", nil)];
                if ([remind.takeoverWaittingRemindCount integerValue] > 0)
                {
                    messagePoint.hidden = NO;
                }
                else
                {
                    messagePoint.hidden = YES;
                }
            }
            
        }
        else
        {
            
            static NSString *identifierDefault = @"DefaultCell";
            cell = [tableView dequeueReusableCellWithIdentifier:identifierDefault];
            
            if (!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"DefaultCell"];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                
                NSString *title = [self titleWithIndexPath:indexPath];
                [cell.textLabel setText:title];
                cell.textLabel.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
            }
        }

        return cell;
    }
}



- (NSString *)titleWithIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                    return NSLocalizedString(@"My Hosting", nil);
                    break;
                case 1:
                    return NSLocalizedString(@"My Takeover", nil);
                    break;
                default:
                    return NSLocalizedString(@"System Set", nil);
                    break;
                    
            }
        }
            break;
        case 2:
            switch (indexPath.row)
        {
            case 0:
                return NSLocalizedString(@"About app", nil);
                break;
            case 1:
                return NSLocalizedString(@"Terms of service", nil);
                break;
            default:
                return NSLocalizedString(@"Advice feed back", nil);
                break;
        }
            break;
        default:
            return NSLocalizedString(@"Log Out", nil);
            break;
    }
}



- (void)setupUserInfoCell:(UITableViewCell *)cell
{
    //用户头像
    ThumbnailImageView *imageView = [[ThumbnailImageView alloc] initWithFrame:CGRectMake(kUserInfoCellMaginLeft,
                                                                                         (kUserInfoCellHeight - kUserInfoCellImageHeightWidth)/2,
                                                                                         kUserInfoCellImageHeightWidth,
                                                                                         kUserInfoCellImageHeightWidth)];
    [imageView setTag:UserInfoCellItemTagUserImageView];
    [cell addSubview:imageView];
    
    
    //用户名称
    CustomLabel *usernameLabel = [[CustomLabel alloc] init];
    [usernameLabel setFrame:CGRectMake(imageView.frame.origin.x + CGRectGetWidth(imageView.frame) + kUserInfoViewMagin,
                                      imageView.frame.origin.y + kUserInfoViewMagin/2,
                                      CGRectGetWidth(self.view.bounds)/1.5,
                                       CGRectGetWidth(imageView.bounds)/3)];
    [usernameLabel setTag:UserInfoCellItemTagUsernameLabel];
    [cell addSubview:usernameLabel];
    
    
    //专业
    CustomLabel *majorLabel = [[CustomLabel alloc] init];
    [majorLabel setNumberOfLines:1];
    [majorLabel setTag:UserInfoCellItemTagMajorLabe];
    [cell addSubview:majorLabel];
    
    
    //级别
    CustomLabel *rankLabel = [[CustomLabel alloc] init];
    [rankLabel setNumberOfLines:1];
    [rankLabel setTag:UserInfoCellItemTagRankLabel];
    [cell addSubview:rankLabel];
    
    }


#pragma mark - 根据string计算label大小
- (CGSize)sizeWithString:(NSString*)string font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attribute = @{NSFontAttributeName: font};
    
    CGSize textSize = [string boundingRectWithSize:maxSize
                                           options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        attributes:attribute
                                           context:nil].size;
    return textSize;
}



#pragma mark - 注销
- (void)requestToLogOut
{
    
    
    hud = [[MBProgressHUD alloc] initWithView:self.parentViewController.view];
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


@end
