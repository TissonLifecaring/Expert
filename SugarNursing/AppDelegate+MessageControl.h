//
//  AppDelegate+MessageControl.h
//  SugarNursing
//
//  Created by Ian on 15-3-17.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (MessageControl)



+ (void)updateNewMessageCountToServer;

+ (void)updateNewMessageCountToCoreData;

+ (NSString *)configureMessageListJsonString;


+ (void)updateSectionBadgeWithParameter:(NSDictionary *)parameter;


+ (NSInteger)msgCountOfMessageSection;

+ (NSInteger)msgCountOfMemberCenter;

+ (NSInteger)NewMessageCount;

@end
