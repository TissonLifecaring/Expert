//
//  Department.h
//  SugarNursing
//
//  Created by Ian on 14-12-31.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Department : NSManagedObject

@property (nonatomic, retain) NSString * departmentId;
@property (nonatomic, retain) NSString * departmentName;
@property (nonatomic, retain) NSString * introduction;
@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSString * seq;

+ (NSString *)getDepartmentNameByID:(NSString *)departmentID;

+ (NSString *)getDepartmentIdByName:(NSString *)departmentName;

@end
