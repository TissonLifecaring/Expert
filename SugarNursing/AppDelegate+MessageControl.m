//
//  AppDelegate+MessageControl.m
//  SugarNursing
//
//  Created by Ian on 15-3-17.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//


#import "AppDelegate+MessageControl.h"
#import "GCRequest.h"
#import "NSString+UserCommon.h"
#import "NotificationName.h"
#import "MsgRemind.h"
#import <AudioToolbox/AudioToolbox.h>


@implementation AppDelegate (MessageControl)

#pragma mark 上传消息数目,已弃用
+ (void)updateNewMessageCountToServer
{
    
    NSDictionary *parameters = @{@"method":@"resetNewMessageCount",
                                 @"sign":@"sign",
                                 @"recvUser":[NSString exptId],
                                 @"sessionId":[NSString sessionID],
                                 @"sessionToken":[NSString sessionToken],
                                 @"messageTypeList":[self configureMessageListJsonString]};
    
    [GCRequest resetNewMessageCountWithParameters:parameters block:^(NSDictionary *responseData, NSError *error)
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTABBAR object:nil];
     }];
}


+ (NSString *)configureMessageListJsonString
{
    
    MsgRemind *remind = [MsgRemind shareMsgRemind];
    
    NSArray *messageList = @[@{@"type":@"agentMsg",@"value":remind.messageAgentRemindCount},
                             @{@"type":@"bulletin",@"value":remind.messageBulletinRemindCount},
                             @{@"type":@"personalAppr",@"value":remind.messageApproveRemindCount},
                             @{@"type":@"trusPass",@"value":remind.hostingConfirmRemindCount},
                             @{@"type":@"trusObjection",@"value":remind.hostingRefuseRemindCount},
                             @{@"type":@"trusWait",@"value":remind.takeoverWaittingRemindCount}
                             ];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:messageList options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}


#pragma mark 获取新消息数目,每次获取后,后台数据库都会清零
+ (void)updateNewMessageCountToCoreData
{
    
    NSDictionary *parameters = @{@"method":@"getNewMessageCount",
                                 @"sessionId":[NSString sessionID],
                                 @"sessionToken":[NSString sessionToken],
                                 @"recvUser":[NSString exptId],
                                 @"sign":@"sign"};
    [GCRequest getNewMessageCountWithParameters:parameters block:^(NSDictionary *responseData, NSError *error)
     {
         
         if (!error)
         {
             
             if ([responseData[@"ret_code"] isEqualToString:@"0"])
             {
                 
                 [AppDelegate updateSectionBadgeWithParameter:responseData];
                 
                 [UIApplication sharedApplication].applicationIconBadgeNumber = [AppDelegate NewMessageCount];
                 
             }
         }
     }];
}


#pragma mark 更新本地新消息数目
+ (void)updateSectionBadgeWithParameter:(NSDictionary *)parameter
{
    
    if (!parameter || parameter.count<=0)
    {
        return;
    }
    
    NSArray *countList = parameter[@"countList"];
    
    
    BOOL _refreshTabBar = NO;
    BOOL _refreshTrusList = NO;
    BOOL _refreshTakeoverList = NO;
    BOOL _refreshMsgList = NO;
    BOOL _refreshMemberList = NO;
    
    
    
    NSString *trus_object = @"";
    NSString *msg_object = @"";
    
    MsgRemind *remind = [MsgRemind shareMsgRemind];
    for (NSDictionary *content in countList)
    {
        
        NSString *type = content[@"messageType"];
        NSInteger badge = [content[@"newNum"] integerValue];
        
        if (badge<=0) continue;
        
        _refreshTabBar = YES;
        
        if ([type isEqualToString:@"personalAppr"])
        {
            remind.messageApproveRemindCount = [NSNumber numberWithInteger:[remind.messageApproveRemindCount integerValue] + badge];
            _refreshMsgList = YES;
            msg_object = @"personalAppr";
        }
        else if ([type isEqualToString:@"bulletin"])
        {
            remind.messageBulletinRemindCount = [NSNumber numberWithInteger:[remind.messageBulletinRemindCount integerValue] +badge];
            _refreshMsgList = YES;
            msg_object = @"bulletin";
        }
        else if ([type isEqualToString:@"agentMsg"])
        {
            remind.messageAgentRemindCount = [NSNumber numberWithInteger:[remind.messageAgentRemindCount integerValue] +badge];
            _refreshMsgList = YES;
            msg_object = @"agentMsg";
        }
        else if ([type isEqualToString:@"trusPass"])
        {
            
            remind.hostingConfirmRemindCount = [NSNumber numberWithInteger:[remind.hostingConfirmRemindCount integerValue] +badge];
            _refreshTrusList = YES;
            _refreshMemberList = YES;
            trus_object = @"trusPass";
        }
        else if ([type isEqualToString:@"trusObjection"])
        {
            remind.hostingRefuseRemindCount = [NSNumber numberWithInteger:[remind.hostingRefuseRemindCount integerValue] +badge];
            _refreshTrusList = YES;
            _refreshMemberList = YES;
            trus_object = @"trusObjection";
        }
        else if ([type isEqualToString:@"trusWait"])
        {
            remind.takeoverWaittingRemindCount = [NSNumber numberWithInteger:[remind.takeoverWaittingRemindCount integerValue] +badge];
            _refreshTakeoverList = YES;
            _refreshMemberList = YES;
        }
    }
    
    [MsgRemind saveContext];
    
    if (_refreshTabBar || _refreshMsgList || _refreshTakeoverList || _refreshTrusList)
        [self setUpNotificationAudio];
    
    if (_refreshTabBar) [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTABBAR object:nil];
    if (_refreshMsgList) [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADMSGMENU object:msg_object];
    if (_refreshTrusList) [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTRUSLIST object:trus_object];
    if (_refreshTakeoverList) [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADTAKEOVERLIST object:nil];
    if (_refreshMemberList) [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADMEMBERLIST object:nil];
}

+ (NSInteger)msgCountOfMessageSection
{
    
    MsgRemind *remind = [MsgRemind shareMsgRemind];
    NSInteger count = 0;
    count += [remind.messageAgentRemindCount integerValue];
    count += [remind.messageApproveRemindCount integerValue];
    count += [remind.messageBulletinRemindCount integerValue];
    return count;
}

+ (NSInteger)msgCountOfMemberCenter
{
    MsgRemind *remind = [MsgRemind shareMsgRemind];
    NSInteger count = 0;
    count += [remind.hostingConfirmRemindCount integerValue];
    count += [remind.hostingRefuseRemindCount integerValue];
    count += [remind.takeoverWaittingRemindCount integerValue];
    return count;
}

+ (NSInteger)NewMessageCount
{
    
    MsgRemind *remind = [MsgRemind shareMsgRemind];
    NSInteger newCount = 0;
    
    unsigned int outCount,i;
    
    objc_property_t *properties = class_copyPropertyList([MsgRemind class], &outCount);
    for (i=0; i<outCount; i++)
    {
        
        objc_property_t property = properties[i];
        const char * proName = property_getName(property);
        if (proName)
        {
            NSString *propertyName = [NSString stringWithUTF8String:proName];
            NSNumber *number = (NSNumber *)[remind valueForKey:propertyName];
            
            newCount += [number integerValue];
        }
    }
    
    return newCount;
}


#pragma mark - 播放提示音乐
+ (void)setUpNotificationAudio
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"wav"];
    SystemSoundID soundID;
    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

@end
