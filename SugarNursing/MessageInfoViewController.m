//
//  MessageInfoViewController.m
//  SugarNursing
//
//  Created by Ian on 14-12-24.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "MessageInfoViewController.h"
#import "MsgInfo_Cell.h"
#import "UtilsMacro.h"
#import <MBProgressHUD.h>
#import <SSPullToRefresh.h>
#import "NoDataLabel.h"
#import "MsgRemind.h"
#import "NotificationName.h"
#import "AppDelegate+MessageControl.h"




static NSString *identifier = @"MsgInfo_Cell";

static CGFloat kEstimatedCellHeight = 150;
static NSString *loadSize = @"15";

@interface MessageInfoViewController ()<NSFetchedResultsControllerDelegate,SSPullToRefreshViewDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD *hud;
    NSArray *_serverData;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchController;
@property (strong, nonatomic) SSPullToRefreshView *refreshView;

@property (assign, nonatomic) BOOL isAll;
@property (assign, nonatomic) BOOL loading;

@end

@implementation MessageInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.myTableView delegate:self];
    
    [self configureFetchController];
    [self.myTableView reloadData];
    [self configureTableViewFooterView];
    
    //重置未读消息数
    [self resetMsgCount];
    
    
//    [self.refreshView startLoadingAndExpand:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    //防止刚进入页面时autolayout的计算错误 ,把tabBarController.tabBar也计算在内
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - Configure
- (void)configureFetchController
{
    if (self.msgType == MsgTypeApprove)
    {
        self.fetchController = [Notice fetchAllGroupedBy:nil sortedBy:@"sendTime" ascending:NO withPredicate:nil delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    }
    else if (self.msgType == MsgTypeBulletin)
    {
        self.fetchController = [Bulletin fetchAllGroupedBy:nil sortedBy:@"sendTime" ascending:NO withPredicate:nil delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    }
    else
    {
        self.fetchController = [AgentMsg fetchAllGroupedBy:nil sortedBy:@"sendTime" ascending:NO withPredicate:nil delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.myTableView reloadData];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self requestMsgListWithIsRefresh:YES];
}

- (void)requestMsgListWithIsRefresh:(BOOL)isRefresh
{
    
    self.loading = YES;
    
    
    if (self.msgType == MsgTypeApprove)
    {
        NSDictionary *parameters = @{@"method":@"getNoticeList",
                                     @"sessionToken":[NSString sessionToken],
                                     @"sign":@"sign",
                                     @"sessionId":[NSString sessionID],
                                     @"recvUser":[NSString exptId],
                                     @"messageType":@"personalAppr",
                                     @"size":loadSize,
                                     @"start":isRefresh ? @"1" : [NSString stringWithFormat:@"%ld",self.fetchController.fetchedObjects.count + 1]};
        
        
        [GCRequest getNoticeListWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
            
            self.loading = NO;
            
            if (!error)
            {
                
                NSString *ret_code = responseData[@"ret_code"];
                if ([ret_code isEqualToString:@"0"])
                {
                    
                    NSInteger listSize = [responseData[@"noticeListSize"] integerValue];
                    if (listSize < [loadSize integerValue])
                    {
                        self.isAll = YES;
                    }
                    else
                    {
                        self.isAll = NO;
                    }
                    
                    
                    if (listSize <=0)
                    {
                        
                    }
                    else
                    {
                        
                        NSArray *notices = responseData[@"noticeList"];
                        
                        NSString *identifierKey = @"noticeId";
                        
                        isRefresh ? [Notice synchronizationDataWithListArray:notices identifierKey:identifierKey] :
                        [Notice updateCoreDataWithListArray:notices identifierKey:identifierKey];
                        
                        [[CoreDataStack sharedCoreDataStack] saveContext];
                    }
                }
                else
                {
                    hud = [[MBProgressHUD alloc] initWithView:self.view];
                    [self.view addSubview:hud];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                    [hud show:YES];
                    [hud hide:YES afterDelay:HUD_TIME_DELAY];
                }
            }
            else
            {
                hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedErrorMesssagesFromError:error];
                [hud show:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
            if (self.refreshView)
            {
                [self.refreshView finishLoading];
            }
        }];
        
        
    }
    else if (self.msgType == MsgTypeBulletin)
    {
        
        
        UserInfomation *info = [UserInfomation findAllInContext:[CoreDataStack sharedCoreDataStack].context][0];
        
        NSDictionary *parameters = @{@"method":@"getBulletinList",
                                     @"sign":@"sign",
                                     @"sessionId":[NSString sessionID],
                                     @"centerId":info.centerId,
                                     @"groupId":@"3",
                                     @"recvUser":[NSString exptId],
                                     @"size":loadSize,
                                     @"start":isRefresh ? @"1" : [NSString stringWithFormat:@"%ld",self.fetchController.fetchedObjects.count + 1]
                                     };
        
        [GCRequest getBulletinListWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
            
            self.loading = NO;
            
            if (!error)
            {
                NSString *ret_code = responseData[@"ret_code"];
                if ([ret_code isEqualToString:@"0"])
                {
                    
                    NSInteger listSize = [responseData[@"bulletinListSize"] integerValue];
                    
                    if (listSize < [loadSize integerValue])
                    {
                        self.isAll = YES;
                    }
                    else
                    {
                        self.isAll = NO;
                    }
                    
                    if (listSize <=0)
                    {
                        
                    }
                    else
                    {
                        
                        NSArray *bulletinArray = responseData[@"bulletinList"];
                        NSString *identifierKey = @"bulletinId";
                        
                        isRefresh ? [Bulletin synchronizationDataWithListArray:bulletinArray identifierKey:identifierKey] :
                        [Bulletin updateCoreDataWithListArray:bulletinArray identifierKey:identifierKey];
                        
                        [[CoreDataStack sharedCoreDataStack] saveContext];
                    }
                    
                    
                    [hud hide:YES];
                    
                }
                else
                {
                    
                    hud = [[MBProgressHUD alloc] initWithView:self.view];
                    [self.view addSubview:hud];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                    [hud show:YES];
                    [hud hide:YES afterDelay:HUD_TIME_DELAY];
                }
            }
            else
            {
                
                hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedErrorMesssagesFromError:error];
                [hud show:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
            
            
            if (self.refreshView)
            {
                [self.refreshView finishLoading];
            }
        }];
    }
    else if (self.msgType == MsgTypeAgent)
    {
        
        NSDictionary *parameters = @{@"method":@"getNoticeList",
                                     @"sessionToken":[NSString sessionToken],
                                     @"sign":@"sign",
                                     @"sessionId":[NSString sessionID],
                                     @"recvUser":[NSString exptId],
                                     @"messageType":@"agentMsg",
                                     @"size":loadSize,
                                     @"start":isRefresh ? @"1" : [NSString stringWithFormat:@"%ld",self.fetchController.fetchedObjects.count + 1]};
        

        [GCRequest getNoticeListWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
            
            self.loading = NO;
            
            if (!error)
            {
                
                NSString *ret_code = responseData[@"ret_code"];
                if ([ret_code isEqualToString:@"0"])
                {
                    
                    NSInteger listSize = [responseData[@"noticeListSize"] integerValue];
                    if (listSize < [loadSize integerValue])
                    {
                        self.isAll = YES;
                    }
                    else
                    {
                        self.isAll = NO;
                    }
                    
                    
                    if (listSize <=0)
                    {
                        
                    }
                    else
                    {
                        
                        NSArray *notices = responseData[@"noticeList"];
                        NSString *identifierKey = @"noticeId";
                        
                        isRefresh ? [AgentMsg synchronizationDataWithListArray:notices identifierKey:identifierKey] :
                        [AgentMsg updateCoreDataWithListArray:notices identifierKey:identifierKey];
                        
                        [[CoreDataStack sharedCoreDataStack] saveContext];
                        
                    }
                    
                    
                }
                else
                {
                    hud = [[MBProgressHUD alloc] initWithView:self.view];
                    [self.view addSubview:hud];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                    [hud show:YES];
                    [hud hide:YES afterDelay:HUD_TIME_DELAY];
                }
            }
            else
            {
                hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedErrorMesssagesFromError:error];
                [hud show:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
            
            if (self.refreshView)
            {
                [self.refreshView finishLoading];
            }
        }];
    }
}


#pragma mark - TableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchController.fetchedObjects.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kEstimatedCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellHeightWithIndexPath:indexPath];
}

- (CGFloat)cellHeightWithIndexPath:(NSIndexPath *)indexPath
{
    static MsgInfo_Cell *cell = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        cell = [self.myTableView dequeueReusableCellWithIdentifier:identifier];
        
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), kEstimatedCellHeight);
        cell.contentView.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), kEstimatedCellHeight);
        
        [cell.contentView setNeedsLayout];
        [cell.contentView layoutIfNeeded];
    });
    
    [self configureCell:cell indexPath:indexPath];
    
    return [self calculateCellHeight:cell];
}

- (CGFloat)calculateCellHeight:(UITableViewCell *)cell
{
    
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height;
}
//
//- (void)configureCell:(MsgInfo_Cell *)cell indexPath:(NSIndexPath *)indexPath
//{
//    if (self.msgType == MsgTypeApprove)
//    {
//        
//        Notice *notice = self.fetchController.fetchedObjects[indexPath.row];
//        
//        [cell.contentLabel setText:notice.content];
//        
//        
//        NSString *dayString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:GC_FORMATTER_DAY string:notice.sendTime];
//        NSString *nearDayString = [NSString compareNearDate:[NSDate dateByString:dayString dateFormat:GC_FORMATTER_DAY]];
//        NSString *timeString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:@"HH:mm" string:notice.sendTime];
//        
//        NSString *msgDateString = [NSString stringWithFormat:@"%@ %@",nearDayString,timeString];
//        [cell.dateLabel setText:msgDateString];
//    }
//    else if (self.msgType == MsgTypeBulletin)
//    {
//        
//        Bulletin *bulletin = self.fetchController.fetchedObjects[indexPath.row];
//        
//        
//        [cell.contentLabel setText:bulletin.content];
//        
//        
//        NSString *dayString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:GC_FORMATTER_DAY string:bulletin.sendTime];
//        NSString *nearDayString = [NSString compareNearDate:[NSDate dateByString:dayString dateFormat:GC_FORMATTER_DAY]];
//        
//        
//        NSString *timeString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:@"HH:mm" string:bulletin.sendTime];
//        
//        NSString *msgDateString = [NSString stringWithFormat:@"%@ %@",nearDayString,timeString];
//        [cell.dateLabel setText:msgDateString];
//    }
//    else
//    {
//        
//        AgentMsg *notice = self.fetchController.fetchedObjects[indexPath.row];
//        
//        [cell.contentLabel setText:notice.content];
//        
//        
//        NSString *dayString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:GC_FORMATTER_DAY string:notice.sendTime];
//        NSString *nearDayString = [NSString compareNearDate:[NSDate dateByString:dayString dateFormat:GC_FORMATTER_DAY]];
//        NSString *timeString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:@"HH:mm" string:notice.sendTime];
//        
//        NSString *msgDateString = [NSString stringWithFormat:@"%@ %@",nearDayString,timeString];
//        [cell.dateLabel setText:msgDateString];
//    }
//}


- (void)configureCell:(MsgInfo_Cell *)cell indexPath:(NSIndexPath *)indexPath
{
    
    NSManagedObject *object = self.fetchController.fetchedObjects[indexPath.row];
    
    [cell.contentLabel setText:[object valueForKey:@"content"]];
    
    NSString *sendTime = [object valueForKey:@"sendTime"];
    
    NSString *dayString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:GC_FORMATTER_DAY string:sendTime];
    NSString *nearDayString = [NSString compareNearDate:[NSDate dateByString:dayString dateFormat:GC_FORMATTER_DAY]];
    NSString *timeString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:@"HH:mm" string:sendTime];
    
    NSString *msgDateString = [NSString stringWithFormat:@"%@ %@",nearDayString,timeString];
    [cell.dateLabel setText:msgDateString];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MsgInfo_Cell *cell = (MsgInfo_Cell *)[self.myTableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell indexPath:indexPath];
    return cell;
}


- (void)configureTableViewFooterView
{
    if (self.fetchController.fetchedObjects.count > 0)
    {
        self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else
    {
        NoDataLabel *label = [[NoDataLabel alloc] initWithFrame:self.myTableView.bounds];
        label.text = (self.msgType == MsgTypeApprove ?
                      NSLocalizedString(@"have not approve result", nil) : NSLocalizedString(@"have not system bulletin", nil));
        self.myTableView.tableFooterView = label;
    }
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height)
    {
        if (!self.isAll && !self.loading)
        {
            [self requestMsgListWithIsRefresh:NO];
        }
    }
}



#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    [hud2 removeFromSuperview];
    hud2 = nil;
}


#pragma mark - Other

- (void)resetMsgCount
{
    
    MsgRemind *remind = [MsgRemind shareMsgRemind];
    
    if (self.msgType == MsgTypeAgent && [remind.messageAgentRemindCount integerValue]>0)
    {
        remind.messageAgentRemindCount = [NSNumber numberWithInteger:0];
        [MsgRemind saveContext];
    }
    else if (self.msgType == MsgTypeApprove && [remind.messageApproveRemindCount integerValue]>0)
    {
        remind.messageApproveRemindCount = [NSNumber numberWithInteger:0];
        [MsgRemind saveContext];
    }
    else if (self.msgType == MsgTypeBulletin && [remind.messageBulletinRemindCount integerValue]>0)
    {
        remind.messageBulletinRemindCount = [NSNumber numberWithInteger:0];
        [MsgRemind saveContext];
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTABBAR object:nil];
}


@end
