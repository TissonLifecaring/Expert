//
//  Diet.h
//  SugarNursing
//
//  Created by Ian on 15-1-23.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DietLog;

@interface Diet : NSManagedObject

@property (nonatomic, retain) NSString * calorie;
@property (nonatomic, retain) NSString * food;
@property (nonatomic, retain) NSString * sort;
@property (nonatomic, retain) NSString * unit;
@property (nonatomic, retain) NSString * weight;
@property (nonatomic, retain) DietLog *dietLog;

@end
