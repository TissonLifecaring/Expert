//
//  MyHostingViewController.m
//  SugarNursing
//
//  Created by Ian on 14-11-25.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "MyHostingViewController.h"
#import "TakeoverStandby_Cell.h"
#import <MBProgressHUD.h>
#import "UIStoryboard+Storyboards.h"
#import "CustomLabel.h"
#import "UtilsMacro.h"
#import <SSPullToRefresh.h>
#import "AttributedLabel.h"
#import "NoDataLabel.h"
#import "SinglePatient_ViewController.h"
#import "MsgRemind.h"
#import "NotificationName.h"
#import "AppDelegate+MessageControl.h"
#import "RootViewController.h"
#import "DeviceHelper.h"

static const NSString *loadSize = @"5";

@interface MyHostingViewController ()<NSFetchedResultsControllerDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD *hud;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchControllerWaitting;
@property (strong, nonatomic) NSFetchedResultsController *fetchControllerConfirm;
@property (strong, nonatomic) NSFetchedResultsController *fetchControllerRefuse;
@property (strong, nonatomic) NSFetchedResultsController *fetchControllerOver;


@property (assign, nonatomic) RefreshTableViewFlag flag;
@property (strong, nonatomic) NSMutableArray *loadedArray;
@property (strong, nonatomic) NSMutableArray *isAllArray;
@property (assign, nonatomic) BOOL loading;

@end

@implementation MyHostingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];
}


- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadMsgPoint:)
                                                 name:NOT_RELOADTRUSLIST
                                               object:nil];
    
    //防止刚进入页面时autolayout的计算错误 ,把tabBarController.tabBar也计算在内
    self.tabBarController.tabBar.hidden = YES;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - init
- (void)setup
{
    
    self.flag = RefreshTableViewFlagWaitting;
    
    self.loadedArray = [@[[NSNumber numberWithBool:NO],
                          [NSNumber numberWithBool:NO],
                          [NSNumber numberWithBool:NO],
                          [NSNumber numberWithBool:NO],
                          [NSNumber numberWithBool:NO]] mutableCopy];
    
    self.isAllArray = [@[[NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO]] mutableCopy];
    
    [self.myTabBar.items[0] setTitle:NSLocalizedString(@"Waitting", nil)];
    [self.myTabBar.items[1] setTitle:NSLocalizedString(@"BeConfirmed", nil)];
    [self.myTabBar.items[2] setTitle:NSLocalizedString(@"BeRefused", nil)];
    [self.myTabBar.items[3] setTitle:NSLocalizedString(@"Over", nil)];
    
    self.tableViewWaitting.tag = 1;
    self.tableViewConfirm.tag = 2;
    self.tableViewRefuse.tag = 4;
    self.tableViewOver.tag = 3;
    self.tableViewWaitting.refreshView.tag = 1;
    self.tableViewConfirm.refreshView.tag = 2;
    self.tableViewRefuse.refreshView.tag = 4;
    self.tableViewOver.refreshView.tag = 3;
    
    [self.myTabBar setSelectedItem:self.myTabBar.items[0]];
    [self tabBar:self.myTabBar didSelectItem:self.myTabBar.items[0]];
    
    MsgRemind *remind = [MsgRemind shareMsgRemind];
    NSInteger confirmCount = [remind.hostingConfirmRemindCount integerValue];
    if (confirmCount >0)
    {
        UITabBarItem *item = self.myTabBar.items[1];
        [item setBadgeValue:[NSString stringWithFormat:@"%ld",confirmCount]];
    }
    
    NSInteger refuseCount = [remind.hostingRefuseRemindCount integerValue];
    if (refuseCount >0)
    {
        UITabBarItem *item = self.myTabBar.items[2];
        [item setBadgeValue:[NSString stringWithFormat:@"%ld",refuseCount]];
    }
}

#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    hud2 = nil;
}


#pragma makr - APNS 触发方法
- (void)reloadMsgPoint:(NSNotification *)notification
{
    
    
    [self refreshTabBarBadgeCount];
    
    NSString *type = (NSString *)notification.object;
    if ([type isEqualToString:@"trusPass"])
    {
        [self.loadedArray setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:1];
        [self.loadedArray setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:2];
    }
    else if ([type isEqualToString:@"trusObjection"])
    {
        [self.loadedArray setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:1];
        [self.loadedArray setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:4];
    }
    
    if (self.flag == RefreshTableViewFlagWaitting ||
        self.flag == RefreshTableViewFlagConfirm ||
        self.flag == RefreshTableViewFlagRefuse)
    {
        [self refreshPresentTableViewWithFlag:self.flag];
    }
}

- (void)refreshTabBarBadgeCount
{
    MsgRemind *remind = [MsgRemind shareMsgRemind];
    
    NSInteger confirmCount = [remind.hostingConfirmRemindCount integerValue];
    
    UITabBarItem *confirmItem = self.myTabBar.items[1];
    [confirmItem setBadgeValue:(confirmCount == 0 ? nil : [NSString stringWithFormat:@"%ld",confirmCount])];
    
    NSInteger refuseCount = [remind.hostingRefuseRemindCount integerValue];
    UITabBarItem *refuseItem = self.myTabBar.items[2];
    [refuseItem setBadgeValue:(refuseCount == 0 ? nil : [NSString stringWithFormat:@"%ld",refuseCount])];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADMEMBERLIST object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTABBAR object:nil];
}

- (void)resetMsgCountWithFlag:(RefreshTableViewFlag)flag
{
    MsgRemind *remind = [MsgRemind shareMsgRemind];
    
    if (flag == RefreshTableViewFlagConfirm && [remind.hostingConfirmRemindCount integerValue]>0)
    {
        remind.hostingConfirmRemindCount = [NSNumber numberWithInteger:0];
        [MsgRemind saveContext];
        [self.myTabBar.items[1] setBadgeValue:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTABBAR object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADMEMBERLIST object:nil];
        
    }
    else if (flag == RefreshTableViewFlagRefuse && [remind.hostingRefuseRemindCount integerValue]>0)
    {
        remind.hostingRefuseRemindCount = [NSNumber numberWithInteger:0];
        [MsgRemind saveContext];
        [self.myTabBar.items[2] setBadgeValue:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTABBAR object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADMEMBERLIST object:nil];
    }
}

#pragma mark - 根据标识flag获取目标tableView和fetchController
- (RefreshTableView *)getRefreshTableViewWithFlag:(RefreshTableViewFlag)flag
{
    
    if (flag == RefreshTableViewFlagWaitting)
    {
        return self.tableViewWaitting;
    }
    else if (flag == RefreshTableViewFlagConfirm)
    {
        return self.tableViewConfirm;
    }
    else if (flag == RefreshTableViewFlagRefuse)
    {
        return self.tableViewRefuse;
    }
    else
    {
        return self.tableViewOver;
    }
}

- (NSFetchedResultsController *)getFetchedControllerWithFlag:(RefreshTableViewFlag)flag
{
    
    if (flag == RefreshTableViewFlagWaitting)
    {
        return self.fetchControllerWaitting;
    }
    else if (flag == RefreshTableViewFlagConfirm)
    {
        return self.fetchControllerConfirm;
    }
    else if (flag == RefreshTableViewFlagRefuse)
    {
        return self.fetchControllerRefuse;
    }
    else
    {
        return self.fetchControllerOver;
    }
}

- (NSString *)getQueryFlagWithFlag:(RefreshTableViewFlag)flag
{
    return [NSString stringWithFormat:@"0%ld",flag];
}

#pragma mark - 四个tableView通用方法
- (void)reloadPresentTableViewWithFlag:(RefreshTableViewFlag)flag
{
    [[self getRefreshTableViewWithFlag:flag] reloadData];
}

- (void)refreshPresentTableViewWithFlag:(RefreshTableViewFlag)flag
{
    RefreshTableView *tableView = [self getRefreshTableViewWithFlag:flag];
    [tableView.refreshView startLoadingAndExpand:YES animated:YES];
}


- (void)requestDataWithFlag:(RefreshTableViewFlag)flag refresh:(BOOL)refresh
{
    [self requestTrusteeshipWithQueryFlag:flag isRefresh:refresh];
}

- (void)configureTableViewFooterViewWithFlag:(RefreshTableViewFlag)flag
{
    
    RefreshTableView *tableView = [self getRefreshTableViewWithFlag:flag];
    NSFetchedResultsController *fetchController = [self getFetchedControllerWithFlag:flag];
    
    if (fetchController.fetchedObjects.count > 0)
    {
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else
    {
        NoDataLabel *label = [[NoDataLabel alloc] initWithFrame:tableView.bounds];
        tableView.tableFooterView = label;
    }
}

#pragma mark - fetchController
- (void)configureFetchControllerWithFlag:(RefreshTableViewFlag)flag
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"queryFlag = %@",[self getQueryFlagWithFlag:flag]];
    
    NSString *sort = @"";
    
    if (flag == RefreshTableViewFlagWaitting)
    {
        sort = @"reqtTime";
        self.fetchControllerWaitting = [Trusteeship fetchAllGroupedBy:nil sortedBy:sort ascending:NO withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    }
    else if (flag == RefreshTableViewFlagConfirm)
    {
        sort = @"apprTime";
        
        self.fetchControllerConfirm = [Trusteeship fetchAllGroupedBy:nil sortedBy:sort ascending:NO withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    }
    else if (flag == RefreshTableViewFlagRefuse)
    {
        sort = @"apprTime";
        self.fetchControllerRefuse = [Trusteeship fetchAllGroupedBy:nil sortedBy:sort ascending:NO withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    }
    else
    {
        sort = @"trusEndTime";
        self.fetchControllerOver = [Trusteeship fetchAllGroupedBy:nil sortedBy:sort ascending:NO withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    RefreshTableViewFlag flag;
    if ([controller isEqual:self.fetchControllerWaitting])
    {
        flag = RefreshTableViewFlagWaitting;
    }
    else if ([controller isEqual:self.fetchControllerConfirm])
    {
        flag = RefreshTableViewFlagConfirm;
    }
    else if ([controller isEqual:self.fetchControllerRefuse])
    {
        flag = RefreshTableViewFlagRefuse;
    }
    else if ([controller isEqual:self.fetchControllerOver])
    {
        flag = RefreshTableViewFlagOver;
    }
    
    [self reloadPresentTableViewWithFlag:flag];
    [self configureTableViewFooterViewWithFlag:flag];
}




#pragma mark - RefreshView Delegate
- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self requestDataWithFlag:self.flag refresh:YES];
}

- (void)pullToRefreshViewDidFinishLoading:(SSPullToRefreshView *)view
{
    
}



#pragma mark - Message Remind
//- (void)showUnreadRemind
//{
//    
//    MsgRemind *remind = [MsgRemind shareMsgRemind];
//    
//    if ([remind.hostingConfirmRemindCount integerValue]>0)
//    {
//        [self addMessagePointWithSegmentIndex:1];
//    }
//    
//    if ([remind.hostingRefuseRemindCount integerValue]>0)
//    {
//        [self addMessagePointWithSegmentIndex:2];
//    }
//    
//}

//- (void)addMessagePointWithSegmentIndex:(NSInteger )index
//{
//    
//    NSInteger tag = index == 1 ? BADGE_VIEW_TAG : BADGE_VIEW_TAG+1;
//    UIImageView *messagePoint = (UIImageView *)[self.hostingSegment viewWithTag:tag];
//    
//    if (!messagePoint)
//    {
//        
//        [self.hostingSegment setNeedsLayout];
//        [self.hostingSegment layoutIfNeeded];
//        
//        NSInteger remindImgWidthHeight = 13;
//        
//        CGSize size = self.hostingSegment.bounds.size;
//        CGFloat originX  = (size.width/4) * (index +1) - remindImgWidthHeight;
//        
//        UIImageView *messagePoint = [[UIImageView alloc] initWithFrame:CGRectMake(originX, 0, remindImgWidthHeight, remindImgWidthHeight)];
//        messagePoint.tag = tag;
//        [messagePoint setImage:[UIImage imageNamed:@"messagePoint"]];
//        [self.hostingSegment addSubview:messagePoint];
//    }
//    
//}

//- (void)cancelMsgPointWithFlag:(NSString *)flag
//{
//    
//    MsgRemind *remind = [MsgRemind shareMsgRemind];
//    
//    if ([flag isEqualToString:@"02"])
//    {
//        remind.hostingConfirmRemindCount = [NSNumber numberWithInteger:0];
//        [MsgRemind saveContext];
//        
//        UIView *view = [self.hostingSegment viewWithTag:BADGE_VIEW_TAG];
//        if (view && [remind.hostingConfirmRemindCount integerValue] <= 0)
//        {
//            [view removeFromSuperview];
//            view = nil;
//            [self.hostingSegment setNeedsLayout];
//            [self.hostingSegment layoutIfNeeded];
//        }
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTABBAR object:nil];
//    }
//    else if ([flag isEqualToString:@"04"])
//    {
//        remind.hostingRefuseRemindCount = [NSNumber numberWithInteger:0];
//        [MsgRemind saveContext];
//        
//        UIView *view = [self.hostingSegment viewWithTag:BADGE_VIEW_TAG+1];
//        if (view && [remind.hostingRefuseRemindCount integerValue] <= 0)
//        {
//            [view removeFromSuperview];
//            view = nil;
//            [self.hostingSegment setNeedsLayout];
//            [self.hostingSegment layoutIfNeeded];
//        }
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTABBAR object:nil];
//    }
//}







#pragma mark - Net Working
- (void)requestTrusteeshipWithQueryFlag:(RefreshTableViewFlag)flag isRefresh:(BOOL)isRefresh
{
    //重置未读消息
    [self resetMsgCountWithFlag:flag];
    
    
    
    NSString *queryFlag = [self getQueryFlagWithFlag:flag];
    
    self.loading = YES;
    [self.loadedArray setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:flag];
    
//    //隐藏未读消息红点
//    [self cancelMsgPointWithFlag:queryFlag];
    
    NSFetchedResultsController *fetchController = [self getFetchedControllerWithFlag:flag];
    RefreshTableView *tableView = [self getRefreshTableViewWithFlag:flag];
    
    NSDictionary *parameter = @{@"method":@"getTrusteeshipList",
                                @"sessionToken":[NSString sessionToken],
                                @"sign":@"sign",
                                @"sessionId":[NSString sessionID],
                                @"exptId":[NSString exptId],
                                @"queryFlag":queryFlag,
                                @"size":loadSize,
                                @"start":isRefresh ? @"1" : [NSString stringWithFormat:@"%ld",fetchController.fetchedObjects.count+1]
                                };
    
    
    [GCRequest getTrusteeshipListWithParameters:parameter block:^(NSDictionary *responseData, NSError *error) {
        
        if (!error)
        {
            
            
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                
                if (isRefresh)
                {
                    [self deleteTrusteeshipListWithQueryFlag:queryFlag];
                }    
                
                
                NSInteger size = [responseData[@"trusteeshipListSize"] integerValue];
                if (size <= 0)
                {
                    DDLogDebug(@"Trusteeship List Size <= 0");
                    [self configureFetchControllerWithFlag:flag];
                    [self reloadPresentTableViewWithFlag:flag];
                    [self configureTableViewFooterViewWithFlag:flag];
                }
                else
                {
                    if (size < [loadSize integerValue])
                    {
                        [self.isAllArray setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:flag];
                    }
                    else
                    {
                        [self.isAllArray setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:flag];
                    }
                    
                    
                    NSArray *array = responseData[@"trusteeshipList"];
                    
                    NSMutableArray *objects = [@[] mutableCopy];
                    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSMutableDictionary *dic = [obj mutableCopy];
                        [dic setObject:queryFlag forKey:@"queryFlag"];
                        [dic sexFormattingToUserForKey:@"linkManSex"];
                        [objects addObject:dic];
                    }];
                    
                    [Trusteeship updateCoreDataWithListArray:objects identifierKey:@"reqtId"];
                    
                    [[CoreDataStack sharedCoreDataStack] saveContext];
                }
            }
            else
            {
                hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                [hud show:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }
        else
        {
            hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
            [hud show:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
        
        self.loading = NO;
        if (tableView.refreshView)
        {
            [tableView.refreshView finishLoading];
        }
    }];
}



- (void)deleteTrusteeshipListWithQueryFlag:(NSString *)queryFlag
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"queryFlag = %@",queryFlag];
    NSArray *deleteArray = [Trusteeship findAllWithPredicate:predicate
                                                   inContext:[CoreDataStack sharedCoreDataStack].context];
    for (Trusteeship *takeover in deleteArray)
    {
        [takeover deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
    }
}


#pragma mark - UIScrollView Delegate  (上拉加载更多)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.frame) > scrollView.contentSize.height)
    {
        BOOL isAll = [[self.isAllArray objectAtIndex:self.flag] boolValue];
        if (!isAll && !self.loading)
        {
            [self requestTrusteeshipWithQueryFlag:self.flag isRefresh:NO];
        }
    }
}

#pragma mark - UITableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (tableView.tag)
    {
        case 1:
            return self.fetchControllerWaitting.fetchedObjects.count;
            break;
        case 2:
            return self.fetchControllerConfirm.fetchedObjects.count;
            break;
        case 4:
            return self.fetchControllerRefuse.fetchedObjects.count;
            break;
        case 3:
            return self.fetchControllerOver.fetchedObjects.count;
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"MyHostingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
        [cell.textLabel setNumberOfLines:0];
        [cell.textLabel setFont:[UIFont systemFontOfSize:[DeviceHelper normalFontSize]]];
    }
    
    NSFetchedResultsController *fetchController;
    
    switch (tableView.tag)
    {
        case 1:
            fetchController =  self.fetchControllerWaitting;
            break;
        case 2:
            fetchController =  self.fetchControllerConfirm;
            break;
        case 4:
            fetchController =  self.fetchControllerRefuse;
            break;
        case 3:
            fetchController =  self.fetchControllerOver;
            break;
        default:
            break;
    }
    
    Trusteeship *trus = fetchController.fetchedObjects[indexPath.row];
    NSAttributedString *content = [self configureContentStringWithTrusteeship:trus language:[DeviceHelper deviceLanguage]];
    
    [cell.textLabel setAttributedText:content];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSFetchedResultsController *fetchController = [self getFetchedControllerWithFlag:self.flag];
    Trusteeship *trus = [fetchController.fetchedObjects objectAtIndex:indexPath.row];
    SinglePatient_ViewController *singleVC = [[UIStoryboard myPatientStoryboard] instantiateViewControllerWithIdentifier:@"SinglePatientVC"];
    singleVC.linkManId = trus.linkManId;
    singleVC.isMyPatient = YES;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        [self showViewController:singleVC sender:nil];
    }
    else
    {
        [self.navigationController pushViewController:singleVC animated:YES];
    }
}


#pragma makr - UITabBar Delegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    RefreshTableViewFlag flag;
    RefreshTableView *tableView;
    
    if ([item.title isEqualToString:NSLocalizedString(@"Waitting", nil)])
    {
        flag = RefreshTableViewFlagWaitting;
        tableView = self.tableViewWaitting;
    }
    else if ([item.title isEqualToString:NSLocalizedString(@"BeConfirmed", nil)])
    {
        flag = RefreshTableViewFlagConfirm;
        tableView = self.tableViewConfirm;
    }
    else if ([item.title isEqualToString:NSLocalizedString(@"BeRefused", nil)])
    {
        flag = RefreshTableViewFlagRefuse;
        tableView = self.tableViewRefuse;
    }
    else if ([item.title isEqualToString:NSLocalizedString(@"Over", nil)])
    {
        flag = RefreshTableViewFlagOver;
        tableView = self.tableViewOver;
    }
    
    self.tableViewWaitting.hidden = YES;
    self.tableViewConfirm.hidden = YES;
    self.tableViewRefuse.hidden = YES;
    self.tableViewOver.hidden = YES;
    
    tableView.hidden = NO;
    self.flag = flag;
    
    //设置并刷新
    [self configureFetchControllerWithFlag:flag];
    [self reloadPresentTableViewWithFlag:flag];
    [self configureTableViewFooterViewWithFlag:flag];
    
    BOOL isLoaded = [[self.loadedArray objectAtIndex:flag] boolValue];
    if (!isLoaded)
    {
        [self refreshPresentTableViewWithFlag:flag];
    }
}



#pragma mark - AttributedString
- (NSAttributedString *)configureContentStringWithTrusteeship:(Trusteeship *)trus language:(GCLanguage)language
{
    if (language == GCLanguageChineseSimple ||
        language == GCLanguageChineseTradition)
    {
        return [self configureChineseAttributedStringWithTrusteeship:trus];
    }
    else if (language == GCLanguageEnglish)
    {
        return [self configureEnglishAttributedStringWithTrusteeship:trus];
    }
    else
    {
        return [self configureChineseAttributedStringWithTrusteeship:trus];
    }
}

- (NSAttributedString *)configureChineseAttributedStringWithTrusteeship:(Trusteeship *)trus
{
    NSString *jointString;
    NSAttributedString *attString;
    
    NSDate *birthDay = [NSDate dateByString:trus.linkManBirthday dateFormat:@"yyyyMMdd"];
    NSString *age = [NSString ageWithDateOfBirth:birthDay];
    
    if ([trus.queryFlag isEqualToString:@"01"])
    {
        jointString = [NSString stringWithFormat:
                       @"%@%@%@%@ (%@ %@%@) %@%@, %@:%@%@%@",
                       NSLocalizedString(@"于", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd HH:mm" string:trus.reqtTime],
                       NSLocalizedString(@"把病人", nil),
                       trus.linkManUserName,
                       trus.linkManSex,
                       age,
                       NSLocalizedString(@"岁", nil),
                       NSLocalizedString(@"托管给医生", nil),
                       trus.trusExptName,
                       NSLocalizedString(@"预计托管时间", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.trusBeginTime],
                       NSLocalizedString(@"至", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.trusEndTime]];
    }
    else if ([trus.queryFlag isEqualToString:@"02"])
    {
        jointString = [NSString stringWithFormat:
                       @"%@%@%@%@%@%@ (%@ %@%@) ,%@:%@%@%@",
                       NSLocalizedString(@"医生", nil),
                       trus.trusExptName,
                       NSLocalizedString(@"于", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.reqtTime],
                       NSLocalizedString(@"托管病人", nil),
                       trus.linkManUserName,
                       trus.linkManSex,
                       age,
                       NSLocalizedString(@"岁", nil),
                       NSLocalizedString(@"接管时间", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.trusBeginTime],
                       NSLocalizedString(@"至", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.trusEndTime]];
        
    }
    else if ([trus.queryFlag isEqualToString:@"04"])
    {
        jointString = [NSString stringWithFormat:
                       @"%@%@%@%@%@%@(%@ %@%@)%@",
                       NSLocalizedString(@"医生", nil),
                       trus.trusExptName,
                       NSLocalizedString(@"于", nil),
                       [NSString dateFormattingByBeforeFormat:@"YYYYMMddHHmmss" toFormat:@"YYYY-MM-dd HH:mm" string:trus.reqtTime],
                       NSLocalizedString(@"退回接管病人", nil),
                       trus.linkManUserName,
                       trus.linkManSex,
                       age,
                       NSLocalizedString(@"岁", nil),
                       NSLocalizedString(@"的请求", nil)];
    }
    else if ([trus.queryFlag isEqualToString:@"03"])
    {
        jointString = [NSString stringWithFormat:
                       @"%@%@%@%@ (%@ %@%@) %@%@, %@:%@%@%@",
                       NSLocalizedString(@"于", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.reqtTime],
                       NSLocalizedString(@"把病人", nil),
                       trus.linkManUserName,
                       trus.linkManSex,
                       age,
                       NSLocalizedString(@"岁", nil),
                       NSLocalizedString(@"托管给医生", nil),
                       trus.trusExptName,
                       NSLocalizedString(@"预计托管时间", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.trusBeginTime],
                       NSLocalizedString(@"至", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.trusEndTime]];
    }
    
    
    NSRange range = [jointString rangeOfString:trus.trusExptName];
    attString = [self configureAttributedString:jointString range:range];
    range = [jointString rangeOfString:trus.linkManUserName];
    attString = [self configureAttributedString:attString range:range];
    
    return attString;
}

- (NSAttributedString *)configureEnglishAttributedStringWithTrusteeship:(Trusteeship *)trus
{
    
    NSString *jointString;
    NSAttributedString *attString;
    
    NSDate *birthDay = [NSDate dateByString:trus.linkManBirthday dateFormat:@"yyyyMMdd"];
    NSString *age = [NSString ageWithDateOfBirth:birthDay];
    
    if ([trus.queryFlag isEqualToString:@"01"])
    {
        jointString = [NSString stringWithFormat:
                       @"Commited patient %@(%@ %@) to doctor%@, Expected time:from %@to%@",
                       trus.linkManUserName,
                       trus.linkManSex,
                       age,
                       trus.trusExptName,
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.trusBeginTime],
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.trusEndTime]];
    }
    else if ([trus.queryFlag isEqualToString:@"02"])
    {
        jointString = [NSString stringWithFormat:
                       @"expert %@ accept patient %@(%@ %@) at %@ ，time:from %@ to %@",
                       trus.trusExptName,
                       trus.linkManUserName,
                       trus.linkManSex,
                       age,
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.reqtTime],
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.trusBeginTime],
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.trusEndTime]];
        
    }
    else if ([trus.queryFlag isEqualToString:@"04"])
    {
        jointString = [NSString stringWithFormat:
                       @"Doctor %@ reject request of patient %@(%@ %@) at %@",
                       trus.trusExptName,
                       trus.linkManUserName,
                       trus.linkManSex,
                       age,
                       [NSString dateFormattingByBeforeFormat:@"YYYYMMddHHmmss" toFormat:@"YYYY-MM-dd HH:mm" string:trus.reqtTime]
                       ];
    }
    else if ([trus.queryFlag isEqualToString:@"03"])
    {
        jointString = [NSString stringWithFormat:
                       @"Commit patient %@(%@ (%@) to doctor %@,estimated time:from %@ to %@",
                       trus.linkManUserName,
                       trus.linkManSex,
                       age,
                       trus.trusExptName,
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.trusBeginTime],
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:trus.trusEndTime]];
    }
    
    
    NSRange range = [jointString rangeOfString:trus.trusExptName];
    attString = [self configureAttributedString:jointString range:range];
    range = [jointString rangeOfString:trus.linkManUserName];
    attString = [self configureAttributedString:attString range:range];
    
    return attString;
}


- (NSMutableAttributedString *)configureAttributedString:(id)string range:(NSRange)range
{
    if ([string isKindOfClass:[NSAttributedString class]])
    {
        NSAttributedString *attString = (NSAttributedString *)string;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attString];
        [attributedString setAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]} range:range];
        return attributedString;
    }
    else if ([string isKindOfClass:[NSString class]])
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:(NSString *)string];
        [attributedString setAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]} range:range];
        return attributedString;
    }
    else
    {
        return nil;
    }
}



@end
