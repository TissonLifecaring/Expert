//
//  Department.m
//  SugarNursing
//
//  Created by Ian on 14-12-31.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "Department.h"
#import "UtilsMacro.h"


@implementation Department

@dynamic departmentId;
@dynamic departmentName;
@dynamic introduction;
@dynamic parentId;
@dynamic seq;


+ (NSString *)getDepartmentNameByID:(NSString *)departmentID
{
    NSArray *array = [self findAllWithPredicate:[NSPredicate predicateWithFormat:@"departmentId = %@",departmentID]
                            inContext:[CoreDataStack sharedCoreDataStack].context];
    if (array.count <= 0)
    {
        return @"";
    }
    else
    {
        Department *depart = array[0];
        return depart.departmentName;
    }
}



+ (NSString *)getDepartmentIdByName:(NSString *)departmentName
{
    NSArray *array = [self findAllWithPredicate:[NSPredicate predicateWithFormat:@"departmentName = %@",departmentName]
                                      inContext:[CoreDataStack sharedCoreDataStack].context];
    if (array.count <= 0)
    {
        return @"";
    }
    else
    {
        Department *depart = array[0];
        return depart.departmentId;
    }
}

@end
