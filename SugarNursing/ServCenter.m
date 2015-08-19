//
//  ServCenter.m
//  SugarNursing
//
//  Created by Ian on 15-1-6.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "ServCenter.h"
#import "CoreDataStack.h"
#import "NSManagedObject+Finders.h"

@implementation ServCenter

@dynamic parentId;
@dynamic centerId;
@dynamic centerName;
@dynamic seq;



+ (NSString *)getCenterNameByID:(NSString *)centerId
{
    NSArray *array = [self findAllWithPredicate:[NSPredicate predicateWithFormat:@"centerId = %@",centerId]
                                      inContext:[CoreDataStack sharedCoreDataStack].context];
    if (array.count <= 0)
    {
        return @"";
    }
    else
    {
        ServCenter *serv = array[0];
        return serv.centerName;
    }
}


+ (NSString *)getCenterIdByName:(NSString *)centerName
{
    NSArray *array = [self findAllWithPredicate:[NSPredicate predicateWithFormat:@"centerName = %@",centerName]
                                      inContext:[CoreDataStack sharedCoreDataStack].context];
    if (array.count <= 0)
    {
        return @"";
    }
    else
    {
        ServCenter *serv = array[0];
        return serv.centerId;
    }
}

@end
