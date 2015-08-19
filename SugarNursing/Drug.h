//
//  Drug.h
//  SugarNursing
//
//  Created by Ian on 15-1-23.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DrugLog;

@interface Drug : NSManagedObject

@property (nonatomic, retain) NSString * dose;
@property (nonatomic, retain) NSString * drug;
@property (nonatomic, retain) NSString * sort;
@property (nonatomic, retain) NSString * unit;
@property (nonatomic, retain) NSString * usage;
@property (nonatomic, retain) DrugLog *drugLog;

@end
