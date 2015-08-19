//
//  MyTakeoverViewController.m
//  SugarNursing
//
//  Created by Ian on 14-12-30.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "MyTakeoverViewController.h"
#import "TakeoverStandby_Cell.h"
#import <MBProgressHUD.h>
#import "UIStoryboard+Storyboards.h"
#import "UtilsMacro.h"
#import <SSPullToRefreshView.h>
#import "NoDataLabel.h"
#import "SinglePatient_ViewController.h"
#import "MsgRemind.h"
#import "NotificationName.h"
#import "AppDelegate+MessageControl.h"
#import "DeviceHelper.h"

static const NSString *loadSize = @"15";




@interface MyTakeoverViewController ()<NSFetchedResultsControllerDelegate,SSPullToRefreshViewDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD *hud;
    
    NSInteger _selectRow;
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

@implementation MyTakeoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTakeoverList) name:NOT_RELOADTAKEOVERLIST object:nil];
    
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
    [self.myTabBar.items[1] setTitle:NSLocalizedString(@"Confirmed", nil)];
    [self.myTabBar.items[2] setTitle:NSLocalizedString(@"Refused", nil)];
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
    
    
}



#pragma mark - APNS
- (void)reloadTakeoverList
{
    MsgRemind *remind = [MsgRemind shareMsgRemind];
    UITabBarItem *item = self.myTabBar.items[0];
    
    NSInteger msgCount = [remind.takeoverWaittingRemindCount integerValue];
    if (msgCount >0)
    {
        [item setBadgeValue:[NSString stringWithFormat:@"%ld",msgCount]];
    }
    else
    {
        [item setBadgeValue:nil];
    }
    
    if (self.flag == RefreshTableViewFlagWaitting)
    {
        [self refreshPresentTableViewWithFlag:self.flag];
    }
    else
    {
        [self.loadedArray setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:1];
    }
}

- (void)resetMsgCount
{
    MsgRemind *remind = [MsgRemind shareMsgRemind];
    if ([remind.takeoverWaittingRemindCount integerValue]>0)
    {
        MsgRemind *remind = [MsgRemind shareMsgRemind];
        remind.takeoverWaittingRemindCount = [NSNumber numberWithInteger:0];
        [MsgRemind saveContext];
        
        [self.myTabBar.items[0] setBadgeValue:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTABBAR object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADMEMBERLIST object:nil];
    }
}

#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    [hud2 removeFromSuperview];
    hud2 = nil;
}


//#pragma mark - Message Remind
//- (void)showUnreadRemind
//{
//    
//    MsgRemind *remind = [MsgRemind shareMsgRemind];
//    
//    if ([remind.takeoverWaittingRemindCount integerValue]>0)
//    {
//        [self addMessagePointWithSegmentIndex:0];
//    }
//}
//
//- (void)addMessagePointWithSegmentIndex:(NSInteger )index
//{
//    
//    
//    UIImageView *messagePoint = (UIImageView *)[self.takeoverSegment viewWithTag:BADGE_VIEW_TAG];
//    
//    if (!messagePoint)
//    {
//        
//        [self.takeoverSegment setNeedsLayout];
//        [self.takeoverSegment layoutIfNeeded];
//        
//        
//        NSInteger remindImgWidthHeight = 13;
//        
//        CGSize size = self.takeoverSegment.bounds.size;
//        CGFloat originX  = (size.width/4) * (index +1) - remindImgWidthHeight;
//        
//        UIImageView *messagePoint = [[UIImageView alloc] initWithFrame:CGRectMake(originX, 0, remindImgWidthHeight, remindImgWidthHeight)];
//        messagePoint.tag = BADGE_VIEW_TAG;
//        [messagePoint setImage:[UIImage imageNamed:@"messagePoint"]];
//        [self.takeoverSegment addSubview:messagePoint];
//    }
//    
//    
//}

//- (void)cancelMsgPointWithFlag:(NSString *)flag
//{
//    
//    MsgRemind *remind = [MsgRemind shareMsgRemind];
//    if ([flag isEqualToString:@"01"] && [remind.takeoverWaittingRemindCount integerValue]>0)
//    {
//        remind.takeoverWaittingRemindCount = [NSNumber numberWithInteger:0];
//        [MsgRemind saveContext];
//        UIView *view = [self.takeoverSegment viewWithTag:BADGE_VIEW_TAG];
//        if (view)
//        {
//            [view removeFromSuperview];
//            view = nil;
//            [self.takeoverSegment setNeedsLayout];
//            [self.takeoverSegment layoutIfNeeded];
//        }
//    }
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTABBAR object:nil];
//}


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
        self.fetchControllerWaitting = [Takeover fetchAllGroupedBy:nil sortedBy:sort ascending:NO withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    }
    else if (flag == RefreshTableViewFlagConfirm)
    {
        sort = @"apprTime";
        
        self.fetchControllerConfirm = [Takeover fetchAllGroupedBy:nil sortedBy:sort ascending:NO withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    }
    else if (flag == RefreshTableViewFlagRefuse)
    {
        sort = @"apprTime";
        self.fetchControllerRefuse = [Takeover fetchAllGroupedBy:nil sortedBy:sort ascending:NO withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    }
    else
    {
        sort = @"trusEndTime";
        self.fetchControllerOver = [Takeover fetchAllGroupedBy:nil sortedBy:sort ascending:NO withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
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


#pragma mark - Net Working
- (void)requestTrusteeshipWithQueryFlag:(RefreshTableViewFlag)flag isRefresh:(BOOL)isRefresh
{
    
    //设置消息已读
    if (flag == RefreshTableViewFlagWaitting)
    {
        [self resetMsgCount];
    }
    
    
    self.loading = YES;
    [self.loadedArray setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:flag];

    
    
    NSString *queryFlag = [self getQueryFlagWithFlag:flag];
    
    NSFetchedResultsController *fetchController = [self getFetchedControllerWithFlag:flag];
    RefreshTableView *tableView = [self getRefreshTableViewWithFlag:flag];
    
    NSDictionary *parameter = @{@"method":@"getTakeOverList",
                                @"sessionToken":[NSString sessionToken],
                                @"sign":@"sign",
                                @"sessionId":[NSString sessionID],
                                @"exptId":[NSString exptId],
                                @"queryFlag":queryFlag,
                                @"size":loadSize,
                                @"start":isRefresh ? @"1" : [NSString stringWithFormat:@"%ld",fetchController.fetchedObjects.count+1]
                                };
    
    
    [GCRequest getTakeOverListWithParameters:parameter block:^(NSDictionary *responseData, NSError *error) {
        if (!error)
        {
            
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                [hud hide:YES];
                
                
                //刷新时先删除再添加
                if (isRefresh)
                {
                    [self deleteTakeoverListWithQueryFlag:queryFlag];
                }
                
                NSInteger size = [responseData[@"takeOverListSize"] integerValue];
                if (size <= 0)
                {
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
                    
                    
                    
                    NSArray *array = responseData[@"takeOverList"];
                    
                    NSMutableArray *objects = [@[] mutableCopy];
                    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSMutableDictionary *dic = [obj mutableCopy];
                        [dic setObject:queryFlag forKey:@"queryFlag"];
                        [dic sexFormattingToUserForKey:@"linkManSex"];
                        [objects addObject:dic];
                    }];
                    
                    
                    [Takeover updateCoreDataWithListArray:objects identifierKey:@"reqtId"];
                    
                    
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
                [hud hide:YES afterDelay:1.2];
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
        
        
        self.loading = NO;
        if (tableView.refreshView)
        {
            [tableView.refreshView finishLoading];
        }
    }];
    
}




- (void)deleteTakeoverListWithQueryFlag:(NSString *)queryFlag
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"queryFlag = %@",queryFlag];
    NSArray *deleteArray = [Takeover findAllWithPredicate:predicate
                                                inContext:[CoreDataStack sharedCoreDataStack].context];
    for (Takeover *takeover in deleteArray)
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

#pragma mark - TakeoverStanbyCell
- (TakeoverStandby_Cell *)getTakeoverStandbyCellWithIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *standyIdentifier = @"TakeoverStandby_Cell";
    
    
    Takeover *takeover = [self.fetchControllerWaitting.fetchedObjects objectAtIndex:indexPath.row];
    TakeoverStandby_Cell *cell = [self.tableViewWaitting dequeueReusableCellWithIdentifier:standyIdentifier];
    
    [cell configureCellWithContent:[self configureContentStringWithModel:self.fetchControllerWaitting.fetchedObjects[indexPath.row]
                                                                      language:[DeviceHelper deviceLanguage]]
                       acceptBlock:^(TakeoverStandby_Cell *cell) {
                           
                           NSString *message = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"sure to confirm takeover", nil),takeover.linkManUserName];
                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil),nil];
                           _selectRow = [self.tableViewWaitting indexPathForCell:cell].row;
                           alert.tag = 1;
                           [alert show];
                                                  }
                       refuseBlock:^(TakeoverStandby_Cell *cell) {
                           
                           
                           NSString *message = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"sure to refuse takeover", nil),takeover.linkManUserName];
                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil),nil];
                           _selectRow = [self.tableViewWaitting indexPathForCell:cell].row;
                           alert.tag = 2;
                           [alert show];

                       }];
    
    cell.contentLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.view.bounds) - 16 - 8;
    [cell layoutSubviews];
    
    return cell;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        
        if (alertView.tag == 1)
        {
            
            [self acceptTakeoverWithRow:_selectRow];
        }
        else
        {
            [self refuseTakeoverWithRow:_selectRow];
        }
    }
}


- (void)acceptTakeoverWithRow:(NSInteger)row
{
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    [hud show:YES];
    
    Takeover *takeover = [self.fetchControllerWaitting.fetchedObjects objectAtIndex:row];
    
    NSDictionary *parameters = @{@"method":@"apprTrusteeship",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"apprRet":@"1",
                                 @"exptId":[NSString exptId],
                                 @"reqtId":takeover.reqtId};
    
    [GCRequest apprTrusteeshipWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        if (!error)
        {
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                
                [takeover deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                
                [self.loadedArray setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:RefreshTableViewFlagConfirm];
                
                
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"you are confirm the trusteeship", nil);
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [hud hide:YES afterDelay:1.2];
            }
        }
        else
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
    }];
    
}

- (void)refuseTakeoverWithRow:(NSInteger)row
{
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    [hud show:YES];
    
    Takeover *takeover = [self.fetchControllerWaitting.fetchedObjects objectAtIndex:row];
    
    NSDictionary *parameters = @{@"method":@"apprTrusteeship",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"apprRet":@"0",
                                 @"exptId":[NSString exptId],
                                 @"reqtId":takeover.reqtId};
    
    [GCRequest apprTrusteeshipWithParameters:parameters block:^(NSDictionary *responseData, NSError *error)
    {
        if (!error)
        {
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                [takeover deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                
                [self.loadedArray setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:RefreshTableViewFlagRefuse];
                
                
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"you are refuse the trusteeship", nil);
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [hud hide:YES afterDelay:1.2];
            }
        }
        else
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
    }];
    
}




#pragma mark - UITableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self getFetchedControllerWithFlag:tableView.tag].fetchedObjects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == RefreshTableViewFlagWaitting)
    {
        
        return 130;
    }
    
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == RefreshTableViewFlagWaitting)
    {
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        return [self getTakeoverStandbyCellWithIndexPath:indexPath];
    }
    else
    {
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
        static NSString *identifier = @"MyTakeoverCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setNumberOfLines:0];
            [cell.textLabel setFont:[UIFont systemFontOfSize:13]];
        }
        
        
        if (tableView.tag == RefreshTableViewFlagWaitting || tableView.tag == RefreshTableViewFlagConfirm)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        else
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        Takeover *takeover = [self getFetchedControllerWithFlag:tableView.tag].fetchedObjects[indexPath.row];
        NSAttributedString *content = [self configureContentStringWithModel:takeover language:[DeviceHelper deviceLanguage]];
        [cell.textLabel setAttributedText:content];
        
        return cell;
    }
    
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.tag == RefreshTableViewFlagWaitting || tableView.tag == RefreshTableViewFlagConfirm)
    {
        
        Takeover *takeover = [self getFetchedControllerWithFlag:tableView.tag].fetchedObjects[indexPath.row];
        SinglePatient_ViewController *singleVC = [[UIStoryboard myPatientStoryboard] instantiateViewControllerWithIdentifier:@"SinglePatientVC"];
        singleVC.linkManId = takeover.linkManId;
        singleVC.isMyPatient = tableView.tag == RefreshTableViewFlagWaitting ? NO : YES;
        
        [self skipToViewController:singleVC];
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
    else if ([item.title isEqualToString:NSLocalizedString(@"Confirmed", nil)])
    {
        flag = RefreshTableViewFlagConfirm;
        tableView = self.tableViewConfirm;
    }
    else if ([item.title isEqualToString:NSLocalizedString(@"Refused", nil)])
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
- (NSAttributedString *)configureContentStringWithModel:(Takeover *)takeover language:(GCLanguage)language
{
    if (language == GCLanguageChineseSimple ||
        language == GCLanguageChineseTradition)
    {
        return [self configureChineseAttributedStringWithModel:takeover];
    }
    else if (language == GCLanguageEnglish)
    {
        return [self configureEnglishAttributedStringWithModel:takeover];
    }
    else
    {
        return [self configureChineseAttributedStringWithModel:takeover];
    }
}



#pragma mark - AttributedString
- (NSAttributedString *)configureChineseAttributedStringWithModel:(Takeover *)takeover
{
    NSString *jointString;
    NSAttributedString *attString;
    
    NSDate *birthDay = [NSDate dateByString:takeover.linkManBirthday dateFormat:@"yyyyMMdd"];
    NSString *age = [NSString ageWithDateOfBirth:birthDay];
    
    if ([takeover.queryFlag isEqualToString:@"01"])
    {
        jointString = [NSString stringWithFormat:
                       @"%@%@%@%@%@%@ (%@ %@%@) %@, %@:%@%@%@",
                       NSLocalizedString(@"医生", nil),
                       takeover.reqtExptName,
                       NSLocalizedString(@"于", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.reqtTime],
                       NSLocalizedString(@"把病人", nil),
                       takeover.linkManUserName,
                       takeover.linkManSex,
                       age,
                       NSLocalizedString(@"岁", nil),
                       NSLocalizedString(@"托管给我", nil),
                       NSLocalizedString(@"预计托管时间", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.trusBeginTime],
                       NSLocalizedString(@"至", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.trusEndTime]
                       ];
    }
    else if ([takeover.queryFlag isEqualToString:@"02"])
    {
        jointString = [NSString stringWithFormat:
                       @"%@%@%@%@%@%@ (%@ %@%@) ,%@:%@%@%@",
                       NSLocalizedString(@"于", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.reqtTime],
                       NSLocalizedString(@"接管医生", nil),
                       takeover.reqtExptName,
                       NSLocalizedString(@"的病人", nil),
                       takeover.linkManUserName,
                       takeover.linkManSex,
                       age,
                       NSLocalizedString(@"岁", nil),
                       NSLocalizedString(@"接管时间", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.trusBeginTime],
                       NSLocalizedString(@"至", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.trusEndTime]];
        
    }
    else if ([takeover.queryFlag isEqualToString:@"04"])
    {
        jointString = [NSString stringWithFormat:
                       @"%@%@%@%@%@%@ (%@ %@%@)%@",
                       NSLocalizedString(@"于", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.reqtTime],
                       NSLocalizedString(@"退回医生", nil),
                       takeover.reqtExptName,
                       NSLocalizedString(@"接管病人", nil),
                       takeover.linkManUserName,
                       takeover.linkManSex,
                       age,
                       NSLocalizedString(@"岁", nil),
                       NSLocalizedString(@"的请求", nil)];
    }
    else if ([takeover.queryFlag isEqualToString:@"03"])
    {
        jointString = [NSString stringWithFormat:
                       @"%@%@%@%@%@%@ (%@ %@%@) %@, %@:%@%@%@",
                       NSLocalizedString(@"医生", nil),
                       takeover.reqtExptName,
                       NSLocalizedString(@"于", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.reqtTime],
                       NSLocalizedString(@"把病人", nil),
                       takeover.linkManUserName,
                       takeover.linkManSex,
                       age,
                       NSLocalizedString(@"岁", nil),
                       NSLocalizedString(@"托管给我", nil),
                       NSLocalizedString(@"预计托管时间", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.trusBeginTime],
                       NSLocalizedString(@"至", nil),
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.trusEndTime]];
    }
    
    NSRange range = [jointString rangeOfString:takeover.reqtExptName];
    attString = [self configureAttributedString:jointString range:range];
    range = [jointString rangeOfString:takeover.linkManUserName];
    attString = [self configureAttributedString:attString range:range];
    
    
    return attString;
}


- (NSAttributedString *)configureEnglishAttributedStringWithModel:(Takeover *)takeover
{
    NSString *jointString;
    NSAttributedString *attString;
    
    NSDate *birthDay = [NSDate dateByString:takeover.linkManBirthday dateFormat:@"yyyyMMdd"];
    NSString *age = [NSString ageWithDateOfBirth:birthDay];
    
    if ([takeover.queryFlag isEqualToString:@"01"])
    {
        jointString = [NSString stringWithFormat:
                       @"Expert(%@) commit patient(%@)(%@ %@) to me,estimated time:from %@ to %@",
                       takeover.reqtExptName,
                       takeover.linkManUserName,
                       takeover.linkManSex,
                       age,
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.trusBeginTime],
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.trusEndTime]
                       ];
    }
    else if ([takeover.queryFlag isEqualToString:@"02"])
    {
        jointString = [NSString stringWithFormat:
                       @"Accept patient(%@)(%@ %@) of doctor(%@),time:from %@ to %@",
                       takeover.linkManUserName,
                       takeover.linkManSex,
                       age,
                       takeover.reqtExptName,
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.trusBeginTime],
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.trusEndTime]];
        
    }
    else if ([takeover.queryFlag isEqualToString:@"04"])
    {
        jointString = [NSString stringWithFormat:
                       @"Reject doctor's(%@) trusteeship request of patient %@(%@ %@)",
                       takeover.reqtExptName,
                       takeover.linkManUserName,
                       takeover.linkManSex,
                       age
                       ];
    }
    else if ([takeover.queryFlag isEqualToString:@"03"])
    {
        jointString = [NSString stringWithFormat:
                       @"expert(%@) commit patient(%@)(%@ %@) to me,estimated time:from %@ to %@",
                       takeover.reqtExptName,
                       takeover.linkManUserName,
                       takeover.linkManSex,
                       age,
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.trusBeginTime],
                       [NSString dateFormattingByBeforeFormat:@"yyyyMMddHHmmss" toFormat:@"YYYY-MM-dd" string:takeover.trusEndTime]];
    }
    
    NSRange range = [jointString rangeOfString:takeover.reqtExptName];
    attString = [self configureAttributedString:jointString range:range];
    range = [jointString rangeOfString:takeover.linkManUserName];
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

