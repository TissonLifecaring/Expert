//
//  MediRecord.h
//  SugarNursing
//
//  Created by Ian on 15-2-6.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MediAttach;

@interface MediRecord : NSManagedObject

@property (nonatomic, retain) NSString * diagHosp;
@property (nonatomic, retain) NSString * diagTime;
@property (nonatomic, retain) NSString * linkManId;
@property (nonatomic, retain) NSString * mediHistId;
@property (nonatomic, retain) NSString * mediName;
@property (nonatomic, retain) NSString * mediRecord;
@property (nonatomic, retain) NSString * treatMent;
@property (nonatomic, retain) NSString * treatPlan;
@property (nonatomic, retain) NSOrderedSet *mediAttach;
@end

@interface MediRecord (CoreDataGeneratedAccessors)

- (void)insertObject:(MediAttach *)value inMediAttachAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMediAttachAtIndex:(NSUInteger)idx;
- (void)insertMediAttach:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMediAttachAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMediAttachAtIndex:(NSUInteger)idx withObject:(MediAttach *)value;
- (void)replaceMediAttachAtIndexes:(NSIndexSet *)indexes withMediAttach:(NSArray *)values;
- (void)addMediAttachObject:(MediAttach *)value;
- (void)removeMediAttachObject:(MediAttach *)value;
- (void)addMediAttach:(NSOrderedSet *)values;
- (void)removeMediAttach:(NSOrderedSet *)values;
@end
