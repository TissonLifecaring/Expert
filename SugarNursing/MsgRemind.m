//
//  MsgRemind.m
//  SugarNursing
//
//  Created by Ian on 15-3-17.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "MsgRemind.h"
#import "NSManagedObject+Finders.h"
#import "CoreDataStack.h"
#import "NSManagedObject+Savers.h"
#import "NotificationName.h"
#import "AppDelegate+MessageControl.h"


@implementation MsgRemind

@dynamic hostingConfirmRemindCount;
@dynamic hostingRefuseRemindCount;
@dynamic messageAgentRemindCount;
@dynamic messageApproveRemindCount;
@dynamic messageBulletinRemindCount;
@dynamic takeoverWaittingRemindCount;


+ (MsgRemind *)shareMsgRemind
{
    
    NSArray *array = [MsgRemind findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    
    if (!array || array.count <= 0)
    {
        MsgRemind *remind = [MsgRemind createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
        remind.messageAgentRemindCount = [NSNumber numberWithInteger:0];
        remind.messageApproveRemindCount = [NSNumber numberWithInteger:0];
        remind.messageBulletinRemindCount = [NSNumber numberWithInteger:0];
        remind.hostingConfirmRemindCount = [NSNumber numberWithInteger:0];
        remind.hostingRefuseRemindCount = [NSNumber numberWithInteger:0];
        remind.takeoverWaittingRemindCount = [NSNumber numberWithInteger:0];
        [[CoreDataStack sharedCoreDataStack] saveContext];
        return remind;
    }
    else
    {
        return array[0];
    }
}


+ (void)saveContext
{
    NSInteger msgCount = [AppDelegate NewMessageCount];
    [UIApplication sharedApplication].applicationIconBadgeNumber = msgCount;
    [[CoreDataStack sharedCoreDataStack] saveContext];
}

@end
