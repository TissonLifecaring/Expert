//
//  MyMessageViewController.m
//  SugarNursing
//
//  Created by Ian on 14-11-25.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "MyMessageViewController.h"
#import "MyMessageCell.h"
#import "UtilsMacro.h"
#import "MessageInfoViewController.h"
#import "NoDataLabel.h"
#import <MBProgressHUD.h>
#import <SSPullToRefresh.h>
#import "MsgRemind.h"
#import "M13BadgeView.h"
#import "NotificationName.h"
#import "VendorMacro.h"
#import "SPKitExample.h"
#include "AppDelegate+UserLogInOut.h"


@interface MyMessageViewController ()<NSFetchedResultsControllerDelegate,SSPullToRefreshViewDelegate,MBProgressHUDDelegate>
{
    NSInteger _selectIndexRow;
    MBProgressHUD *hud;
    NSInteger _finishLog;
    
    BOOL _loadBulletin;
    BOOL _loadAgent;
    BOOL _loadNotice;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchControllerNotice;
@property (strong, nonatomic) NSFetchedResultsController *fetchControllerBulletin;
@property (strong, nonatomic) NSFetchedResultsController *fetchControllerAgentMsg;

@property (strong, nonatomic) SSPullToRefreshView *refreshView;

@property (strong, nonatomic) YWConversationListViewController *conversationListController;
@property (strong, nonatomic) UIView *conversationListView;
@property (nonatomic) AppDelegate *appDelegate;
@end

@implementation MyMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.myTableView delegate:self];
    
    
    [self configureFetchControllerNotice];
    [self configureFetchControllerBulletin];
    [self configureFetchControllerAgentMsg];
    
    
    [self configureTableViewFooterView];
    
    [self.refreshView startLoadingAndExpand:YES animated:YES];
    
//    [self configureConversationList];
}


- (void)configureConversationList
{
    
    __weak typeof(self) weakSelf = self;
    YWConversationListViewController *conversationController = [[SPKitExample sharedInstance] exampleMakeConversationListControllerWithSelectItemBlock:^(YWConversation *aConversation) {
        weakSelf.tabBarController.tabBar.hidden = YES;
        [[SPKitExample sharedInstance] exampleOpenConversationViewControllerWithConversation:aConversation fromNavigationController:weakSelf.navigationController];
    }];
    
    
    if (conversationController)
    {
        
        UIView *conversationView = conversationController.view;
        
        [self addChildViewController:conversationController];
        [self.view addSubview:conversationView];
        
        
        NSDictionary *views = NSDictionaryOfVariableBindings(conversationView);
//        NSDictionary *metrics = @{@"statusBarHeight":@((int)(([UIApplication sharedApplication].statusBarFrame.size.height) +self.navigationController.navigationBar.frame.size.height))};
        NSDictionary *metrics = @{@"statusBarHeight":@(200)};
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[conversationView]-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(64)-[conversationView]-|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views]];
        
        
        
        
        self.conversationListView = conversationView;
        self.conversationListController = conversationController;
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMsgTableView:) name:NOT_RELOADMSGMENU object:nil];
    
    
    _loadBulletin = NO;
    _loadAgent = NO;
    _loadNotice = NO;
    [self.myTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadMsgTableView:(NSNotification *)notification
{
    [self.refreshView startLoadingAndExpand:YES animated:YES];
}


#pragma mark - Getter
- (AppDelegate *)appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

#pragma mark - FetchedController
- (void)configureFetchControllerNotice
{
    self.fetchControllerNotice = [Notice fetchAllGroupedBy:nil sortedBy:@"sendTime" ascending:NO withPredicate:nil delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
}

- (void)configureFetchControllerBulletin
{
    self.fetchControllerBulletin = [Bulletin fetchAllGroupedBy:nil sortedBy:@"sendTime" ascending:NO withPredicate:nil delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
}

- (void)configureFetchControllerAgentMsg
{
    self.fetchControllerAgentMsg = [AgentMsg fetchAllGroupedBy:nil sortedBy:@"sendTime" ascending:NO withPredicate:nil delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    _loadBulletin = NO;
    _loadAgent = NO;
    _loadNotice = NO;
    [self.myTableView reloadData];
    [self configureTableViewFooterView];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    
}


#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    [hud2 removeFromSuperview];
    hud2 = nil;
}


#pragma mark - Refresh View
- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self refreshData];
}

- (void)refreshData
{
    _loadBulletin = NO;
    _loadAgent = NO;
    _loadNotice = NO;
    [self requestNotice];
    [self requestBulletin];
    [self requestAgentMsg];
}



#pragma mark - Net Working
- (void)requestNotice
{
    
    
    NSDictionary *parameters = @{@"method":@"getNoticeList",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"recvUser":[NSString exptId],
                                 @"messageType":@"personalAppr",
                                 @"size":@"15",
                                 @"start":@"1"};
    
    [GCRequest getNoticeListWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        
        
        if (!error)
        {
            
            NSString *ret_code = responseData[@"ret_code"];
            if ([ret_code isEqualToString:@"0"])
            {
                NSArray *notices = responseData[@"noticeList"];
                
                [Notice synchronizationDataWithListArray:notices identifierKey:@"noticeId"];
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
            }
            else
            {
                
            }
        }
        else
        {
            
        }
        
        _finishLog++;
        if (_finishLog >=3)
        {
            _finishLog = 0;
            if (self.refreshView)
            {
                [self.refreshView finishLoading];
            }
        }
        
    }];
    
    
}



- (void)requestAgentMsg
{
    
    
    NSDictionary *parameters = @{@"method":@"getNoticeList",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"recvUser":[NSString exptId],
                                 @"messageType":@"agentMsg",
                                 @"size":@"15",
                                 @"start":@"1"};
    
    [GCRequest getNoticeListWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        
        
        if (!error)
        {
            
            NSString *ret_code = responseData[@"ret_code"];
            if ([ret_code isEqualToString:@"0"])
            {
                NSArray *notices = responseData[@"noticeList"];
                
                [AgentMsg synchronizationDataWithListArray:notices identifierKey:@"noticeId"];
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
            }
            else
            {
                
            }
        }
        else
        {
            
        }
        
        _finishLog++;
        if (_finishLog >=3)
        {
            _finishLog = 0;
            if (self.refreshView)
            {
                [self.refreshView finishLoading];
            }
        }
        
    }];
    
    
}


- (void)requestBulletin
{
    
    UserInfomation *info = [UserInfomation findAllInContext:[CoreDataStack sharedCoreDataStack].context][0];
    
    NSDictionary *parameters = @{@"method":@"getBulletinList",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"centerId":info.centerId,
                                 @"groupId":@"3",
                                 @"recvUser":[NSString exptId],
                                 @"size":@"15",
                                 @"start":@"1"};
    
    [GCRequest getBulletinListWithParameters:parameters block:^(NSDictionary *responseData, NSError *error)
     {
         
         if (!error)
         {
             NSString *ret_code = responseData[@"ret_code"];
             if ([ret_code isEqualToString:@"0"])
             {
                 
                 NSArray *bulletinArray = responseData[@"bulletinList"];
                 [Bulletin synchronizationDataWithListArray:bulletinArray identifierKey:@"bulletinId"];
                 
                 [[CoreDataStack sharedCoreDataStack] saveContext];
                 
             }
             else
             {
                 hud.mode = MBProgressHUDModeText;
                 hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                 [hud hide:YES afterDelay:1.2];
             }
         }
         else
         {
             hud.mode = MBProgressHUDModeText;
             hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
             [hud hide:YES afterDelay:HUD_TIME_DELAY];
         }
         
         
         _finishLog++;
         if (_finishLog >=3)
         {
             _finishLog = 0;
             if (self.refreshView)
             {
                 [self.refreshView finishLoading];
             }
         }
     }];
    
}





#pragma mark - UITableView Delegate & DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    if (self.fetchControllerNotice.fetchedObjects.count >0)
    {
        rowCount ++;
    }
    if (self.fetchControllerBulletin.fetchedObjects.count >0)
    {
        rowCount ++;
    }
    if (self.fetchControllerAgentMsg.fetchedObjects.count >0)
    {
        rowCount ++;
    }
    
    //IM
    rowCount++;
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MyMessageCell";
    
    MyMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCellWithCell:cell indexPath:indexPath];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MyMessageCell *cell = (MyMessageCell *)[self.myTableView cellForRowAtIndexPath:indexPath];
    NSString *cellTitle = cell.msgTitleLabel.text;
    self.goMsgTitle = cellTitle;
    
    if ([cellTitle isEqualToString:NSLocalizedString(@"Approve Result", nil)])
    {
        self.goMsgType  = MsgTypeApprove;
        [self performSegueWithIdentifier:@"goMessageInfo" sender:nil];
    }
    else if ([cellTitle isEqualToString:NSLocalizedString(@"System Bulletin", nil)])
    {
        self.goMsgType = MsgTypeBulletin;
        [self performSegueWithIdentifier:@"goMessageInfo" sender:nil];
    }
    else if ([cellTitle isEqualToString:NSLocalizedString(@"Agent Message", nil)])
    {
        self.goMsgType = MsgTypeAgent;
        [self performSegueWithIdentifier:@"goMessageInfo" sender:nil];
    }
    else
    {
        [self goConversationList];
    }
    
    
}


- (void)configureCellWithCell:(MyMessageCell *)cell indexPath:(NSIndexPath *)indexPath
{
    
    if (self.fetchControllerNotice.fetchedObjects.count >0 && !_loadNotice)
    {
        [self configureNoticeCellWithCell:cell indexPath:indexPath];
    }
    else if (self.fetchControllerBulletin.fetchedObjects.count >0 && !_loadBulletin)
    {
        [self configureBulletinCellWithCell:cell indexPath:indexPath];
    }
    else if (self.fetchControllerAgentMsg.fetchedObjects.count >0 && !_loadAgent)
    {
        [self configureAgentCellWithCell:cell indexPath:indexPath];
    }
    else
    {
        [self configureIMCellWithCell:cell indexPath:indexPath];
    }
}


- (void)configureBulletinCellWithCell:(MyMessageCell *)cell indexPath:(NSIndexPath *)indexPath
{
    
    MsgRemind *msgRemind = [MsgRemind shareMsgRemind];
    
    _loadBulletin = YES;
    
    NSString *title = NSLocalizedString(@"System Bulletin", nil);
    cell.msgTitleLabel.text = title;
    
    NSArray *objects = self.fetchControllerBulletin.fetchedObjects;
    
    Bulletin *bulletin = objects[0];
    [cell.msgDetailLabel setText:bulletin.content];
    
    
    NSString *dayString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:GC_FORMATTER_DAY string:bulletin.sendTime];
    NSString *nearDayString = [NSString compareNearDate:[NSDate dateByString:dayString dateFormat:GC_FORMATTER_DAY]];
    
    
    NSString *timeString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:@"HH:mm" string:bulletin.sendTime];
    
    NSString *msgDateString = [NSString stringWithFormat:@"%@ %@",nearDayString,timeString];
    [cell.msgDateLabel setText:msgDateString];
    
    
    [cell.msgImageView setImage:[UIImage imageNamed:@"Bulletin"]];
    
    NSInteger messageCount =  [msgRemind.messageBulletinRemindCount integerValue];
    
    [self addBadgeViewWithView:cell.msgImageView messageCount:messageCount];
}

- (void)configureAgentCellWithCell:(MyMessageCell *)cell indexPath:(NSIndexPath *)indexPath
{
    _loadAgent = YES;
    
    MsgRemind *msgRemind = [MsgRemind shareMsgRemind];
    
    NSString *title = NSLocalizedString(@"Agent Message", nil);
    cell.msgTitleLabel.text = title;
    
    
    NSArray *objects = self.fetchControllerAgentMsg.fetchedObjects;
    
    AgentMsg *agentMsg = objects[0];
    [cell.msgDetailLabel setText:agentMsg.content];
    
    
    NSString *dayString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:GC_FORMATTER_DAY string:agentMsg.sendTime];
    NSString *nearDayString = [NSString compareNearDate:[NSDate dateByString:dayString dateFormat:GC_FORMATTER_DAY]];
    
    
    NSString *timeString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:@"HH:mm" string:agentMsg.sendTime];
    
    NSString *msgDateString = [NSString stringWithFormat:@"%@ %@",nearDayString,timeString];
    [cell.msgDateLabel setText:msgDateString];
    
    [cell.msgImageView setImage:[UIImage imageNamed:@"Agent"]];
    
    
    NSInteger messageCount =  [msgRemind.messageAgentRemindCount integerValue];
    [self addBadgeViewWithView:cell.msgImageView messageCount:messageCount];
}

- (void)configureNoticeCellWithCell:(MyMessageCell *)cell indexPath:(NSIndexPath *)indexPath
{
    _loadNotice = YES;
    
    MsgRemind *msgRemind = [MsgRemind shareMsgRemind];
    
    NSString *title = NSLocalizedString(@"Approve Result", nil);
    cell.msgTitleLabel.text = title;
    
    
    NSArray *objects = self.fetchControllerNotice.fetchedObjects;
    
    
    Notice *notice = objects[0];
    [cell.msgDetailLabel setText:notice.content];
    
    
    NSString *dayString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:GC_FORMATTER_DAY string:notice.sendTime];
    NSString *nearDayString = [NSString compareNearDate:[NSDate dateByString:dayString dateFormat:GC_FORMATTER_DAY]];
    
    
    NSString *timeString = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:@"HH:mm" string:notice.sendTime];
    
    NSString *msgDateString = [NSString stringWithFormat:@"%@ %@",nearDayString,timeString];
    [cell.msgDateLabel setText:msgDateString];
    
    
    [cell.msgImageView setImage:[UIImage imageNamed:@"Approve"]];
    
    
    NSInteger messageCount =  [msgRemind.messageApproveRemindCount integerValue];
    [self addBadgeViewWithView:cell.msgImageView messageCount:messageCount];
}

- (void)configureIMCellWithCell:(MyMessageCell *)cell indexPath:(NSIndexPath *)indexPath
{
    
    NSString *title = NSLocalizedString(@"Conversation List", nil);
    cell.msgTitleLabel.text = title;
    
    [cell.msgImageView setImage:[UIImage imageNamed:@"Approve"]];
}


#pragma mark - Other
- (void)addBadgeViewWithView:(UIView *)view messageCount:(NSInteger)count
{
    
    M13BadgeView *_badgeView = (M13BadgeView *)[view viewWithTag:BADGE_VIEW_TAG];
    
    if (!_badgeView)
    {
        
        NSInteger badgeWidthHeitght = 20.0;
        
        _badgeView = [[M13BadgeView alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    badgeWidthHeitght,
                                                                    badgeWidthHeitght)];
        _badgeView.tag = BADGE_VIEW_TAG;
        _badgeView.hidesWhenZero = YES;
        [view addSubview:_badgeView];
        
        _badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
    }
    
    _badgeView.text = [NSString stringWithFormat:@"%ld",(long)count];
}




- (void)configureTableViewFooterView
{
    
//    if (self.fetchControllerNotice.fetchedObjects.count <= 0 && self.fetchControllerBulletin.fetchedObjects.count <= 0 && self.fetchControllerAgentMsg.fetchedObjects.count <= 0)
//    {
//        NoDataLabel *label = [[NoDataLabel alloc] initWithFrame:self.myTableView.bounds];
//        self.myTableView.tableFooterView = label;
//    }
//    else
//    {
//        self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    }
}


- (void)goConversationList
{
    
    if ([[self.appDelegate.ywIMKit.IMCore getLoginService] isCurrentLogined])
    {
        [self openConversationList];
    }
    else
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [AppDelegate loginIMWithSuccessBlock:^{
            [hud hide:YES];
            [self openConversationList];
        } failedBlock:^{
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"Server is busy", nil);
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }];
        
    }
    
}

- (void)openConversationList
{
    
    __weak typeof(self) weakSelf = self;
    YWConversationListViewController *conversationListController = [[SPKitExample sharedInstance] exampleMakeConversationListControllerWithSelectItemBlock:^(YWConversation *aConversation) {
        [[SPKitExample sharedInstance] exampleOpenConversationViewControllerWithConversation:aConversation fromNavigationController:weakSelf.navigationController];
    }];
    
    conversationListController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:conversationListController animated:YES];
}


- (IBAction)back:(UIStoryboardSegue *)sender
{
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    MessageInfoViewController *vc = (MessageInfoViewController *)[segue destinationViewController];
    
    vc.title = self.goMsgTitle;
    vc.msgType = self.goMsgType;
    
    //跳转隐藏tabBar
    vc.hidesBottomBarWhenPushed = YES;
    vc.tabBarController.tabBar.hidden = YES;
}


@end
