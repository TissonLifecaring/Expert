//
//  NSArray+Departments.m
//  SugarNursing
//
//  Created by Ian on 15-1-28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "NSArray+Departments.h"

@implementation NSArray (Departments)

+ (NSArray *)getDepartmentArray
{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"departments" ofType:@"plist"];
    NSArray *departments = [[NSArray alloc] initWithContentsOfFile:path];
    return departments;
}

@end
