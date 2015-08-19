//
//  MsgRemind.h
//  SugarNursing
//
//  Created by Ian on 15-3-17.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MsgRemind : NSManagedObject

@property (nonatomic, retain) NSNumber * hostingConfirmRemindCount;
@property (nonatomic, retain) NSNumber * hostingRefuseRemindCount;
@property (nonatomic, retain) NSNumber * messageAgentRemindCount;
@property (nonatomic, retain) NSNumber * messageApproveRemindCount;
@property (nonatomic, retain) NSNumber * messageBulletinRemindCount;
@property (nonatomic, retain) NSNumber * takeoverWaittingRemindCount;


+ (MsgRemind *)shareMsgRemind;

+ (void)saveContext;

@end
