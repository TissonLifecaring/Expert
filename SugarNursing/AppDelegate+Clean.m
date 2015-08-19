//
//  AppDelegate+Clean.m
//  SugarNursing
//
//  Created by Ian on 15-1-12.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "AppDelegate+Clean.h"
#import "UtilsMacro.h"
#import "MsgRemind.h"

@implementation AppDelegate (Clean)

+ (void)cleanAllCoreData
{
    NSManagedObjectContext *context = [CoreDataStack sharedCoreDataStack].context;
    [UserInfomation deleteAllEntityInContext:context];
    [Patient deleteAllEntityInContext:context];
    [PatientInfo deleteAllEntityInContext:context];
    [Department deleteAllEntityInContext:context];
    [ServCenter deleteAllEntityInContext:context];
    [MediRecord deleteAllEntityInContext:context];
    [Advice deleteAllEntityInContext:context];
    [TrusExpt deleteAllEntityInContext:context];
    [TrusPatient deleteAllEntityInContext:context];
    [Trusteeship deleteAllEntityInContext:context];
    [Takeover deleteAllEntityInContext:context];
    [TemporaryInfo deleteAllEntityInContext:context];
    [RecordLog deleteAllEntityInContext:context];
    [Notice deleteAllEntityInContext:context];
    [Bulletin deleteAllEntityInContext:context];
    [AgentMsg deleteAllEntityInContext:context];
    [MsgRemind deleteAllEntityInContext:context];
    [LoadedLog deleteAllEntityInContext:context];
    [[CoreDataStack sharedCoreDataStack] saveContext];
}

@end
