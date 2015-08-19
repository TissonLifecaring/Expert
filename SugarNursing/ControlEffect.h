//
//  ControlEffect.h
//  SugarNursing
//
//  Created by Ian on 15-1-20.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EffectList;

@interface ControlEffect : NSManagedObject

@property (nonatomic, retain) NSString * conclusion;
@property (nonatomic, retain) NSString * conclusionDesc;
@property (nonatomic, retain) NSString * conclusionScore;
@property (nonatomic, retain) NSString * countDay;
@property (nonatomic, retain) NSString * linkManId;
@property (nonatomic, retain) NSOrderedSet *effectList;
@end

@interface ControlEffect (CoreDataGeneratedAccessors)

- (void)insertObject:(EffectList *)value inEffectListAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEffectListAtIndex:(NSUInteger)idx;
- (void)insertEffectList:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEffectListAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEffectListAtIndex:(NSUInteger)idx withObject:(EffectList *)value;
- (void)replaceEffectListAtIndexes:(NSIndexSet *)indexes withEffectList:(NSArray *)values;
- (void)addEffectListObject:(EffectList *)value;
- (void)removeEffectListObject:(EffectList *)value;
- (void)addEffectList:(NSOrderedSet *)values;
- (void)removeEffectList:(NSOrderedSet *)values;
@end
