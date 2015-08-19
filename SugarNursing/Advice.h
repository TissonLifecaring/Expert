//
//  Advice.h
//  SugarNursing
//
//  Created by Ian on 15/6/12.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AdviceAttach;

@interface Advice : NSManagedObject

@property (nonatomic, retain) NSString * adviceId;
@property (nonatomic, retain) NSString * adviceTime;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * exptId;
@property (nonatomic, retain) NSString * linkManId;
@property (nonatomic, retain) NSString * exptName;
@property (nonatomic, retain) NSOrderedSet *adviceAttach;

+ (void)updateAdviceListArray:(NSArray *)array identifierKey:(NSString *)identifierKey;

@end

@interface Advice (CoreDataGeneratedAccessors)

- (void)insertObject:(AdviceAttach *)value inAdviceAttachAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAdviceAttachAtIndex:(NSUInteger)idx;
- (void)insertAdviceAttach:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAdviceAttachAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAdviceAttachAtIndex:(NSUInteger)idx withObject:(AdviceAttach *)value;
- (void)replaceAdviceAttachAtIndexes:(NSIndexSet *)indexes withAdviceAttach:(NSArray *)values;
- (void)addAdviceAttachObject:(AdviceAttach *)value;
- (void)removeAdviceAttachObject:(AdviceAttach *)value;
- (void)addAdviceAttach:(NSOrderedSet *)values;
- (void)removeAdviceAttach:(NSOrderedSet *)values;
@end
