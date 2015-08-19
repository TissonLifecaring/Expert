//
//  DietLog.h
//  SugarNursing
//
//  Created by Ian on 15/5/13.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Diet, RecordLog;

@interface DietLog : NSManagedObject

@property (nonatomic, retain) NSString * calorie;
@property (nonatomic, retain) NSString * eatId;
@property (nonatomic, retain) NSString * eatPeriod;
@property (nonatomic, retain) NSDate * eatTime;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) NSString * glucose;
@property (nonatomic, retain) NSOrderedSet *diet;
@property (nonatomic, retain) RecordLog *recordLog;
@end

@interface DietLog (CoreDataGeneratedAccessors)

- (void)insertObject:(Diet *)value inDietAtIndex:(NSUInteger)idx;
- (void)removeObjectFromDietAtIndex:(NSUInteger)idx;
- (void)insertDiet:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeDietAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInDietAtIndex:(NSUInteger)idx withObject:(Diet *)value;
- (void)replaceDietAtIndexes:(NSIndexSet *)indexes withDiet:(NSArray *)values;
- (void)addDietObject:(Diet *)value;
- (void)removeDietObject:(Diet *)value;
- (void)addDiet:(NSOrderedSet *)values;
- (void)removeDiet:(NSOrderedSet *)values;
@end
