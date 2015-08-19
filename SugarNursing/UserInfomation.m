//
//  UserInfomation.m
//  SugarNursing
//
//  Created by Ian on 15/7/17.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "UserInfomation.h"
#import "NSManagedObject+Savers.h"
#import "NSManagedObject+Finders.h"
#import "CoreDataStack.h"

@implementation UserInfomation

@dynamic areaId;
@dynamic birthday;
@dynamic centerId;
@dynamic departmentId;
@dynamic email;
@dynamic engName;
@dynamic expertLevel;
@dynamic exptId;
@dynamic exptName;
@dynamic headimageUrl;
@dynamic hospital;
@dynamic identifyCard;
@dynamic intro;
@dynamic mobilePhone;
@dynamic mobileZone;
@dynamic registerTime;
@dynamic sex;
@dynamic skilled;
@dynamic stat;
@dynamic updateTime;


+ (UserInfomation *)shareInfo
{
    static UserInfomation *info = nil;
    
    NSArray *objects = [UserInfomation findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    
    if (objects.count <= 0)
    {
        info = [UserInfomation createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
    }
    else
    {
        info = objects[0];
    }
    
    return info;
}

@end
