//
//  DrugLog.h
//  SugarNursing
//
//  Created by Ian on 15/5/13.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Drug, Medicine, RecordLog;

@interface DrugLog : NSManagedObject

@property (nonatomic, retain) NSString * medicineId;
@property (nonatomic, retain) NSString * medicinePeriod;
@property (nonatomic, retain) NSDate * medicineTime;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) NSString * glucose;
@property (nonatomic, retain) NSOrderedSet *drug;
@property (nonatomic, retain) RecordLog *recordLog;
@property (nonatomic, retain) NSOrderedSet *beforeMedicineList;
@property (nonatomic, retain) NSOrderedSet *medicineList;
@property (nonatomic, retain) NSOrderedSet *nowMedicineList;
@end

@interface DrugLog (CoreDataGeneratedAccessors)

- (void)insertObject:(Drug *)value inDrugAtIndex:(NSUInteger)idx;
- (void)removeObjectFromDrugAtIndex:(NSUInteger)idx;
- (void)insertDrug:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeDrugAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInDrugAtIndex:(NSUInteger)idx withObject:(Drug *)value;
- (void)replaceDrugAtIndexes:(NSIndexSet *)indexes withDrug:(NSArray *)values;
- (void)addDrugObject:(Drug *)value;
- (void)removeDrugObject:(Drug *)value;
- (void)addDrug:(NSOrderedSet *)values;
- (void)removeDrug:(NSOrderedSet *)values;
- (void)insertObject:(Medicine *)value inBeforeMedicineListAtIndex:(NSUInteger)idx;
- (void)removeObjectFromBeforeMedicineListAtIndex:(NSUInteger)idx;
- (void)insertBeforeMedicineList:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeBeforeMedicineListAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInBeforeMedicineListAtIndex:(NSUInteger)idx withObject:(Medicine *)value;
- (void)replaceBeforeMedicineListAtIndexes:(NSIndexSet *)indexes withBeforeMedicineList:(NSArray *)values;
- (void)addBeforeMedicineListObject:(Medicine *)value;
- (void)removeBeforeMedicineListObject:(Medicine *)value;
- (void)addBeforeMedicineList:(NSOrderedSet *)values;
- (void)removeBeforeMedicineList:(NSOrderedSet *)values;
- (void)insertObject:(Medicine *)value inMedicineListAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMedicineListAtIndex:(NSUInteger)idx;
- (void)insertMedicineList:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMedicineListAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMedicineListAtIndex:(NSUInteger)idx withObject:(Medicine *)value;
- (void)replaceMedicineListAtIndexes:(NSIndexSet *)indexes withMedicineList:(NSArray *)values;
- (void)addMedicineListObject:(Medicine *)value;
- (void)removeMedicineListObject:(Medicine *)value;
- (void)addMedicineList:(NSOrderedSet *)values;
- (void)removeMedicineList:(NSOrderedSet *)values;
- (void)insertObject:(Medicine *)value inNowMedicineListAtIndex:(NSUInteger)idx;
- (void)removeObjectFromNowMedicineListAtIndex:(NSUInteger)idx;
- (void)insertNowMedicineList:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeNowMedicineListAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInNowMedicineListAtIndex:(NSUInteger)idx withObject:(Medicine *)value;
- (void)replaceNowMedicineListAtIndexes:(NSIndexSet *)indexes withNowMedicineList:(NSArray *)values;
- (void)addNowMedicineListObject:(Medicine *)value;
- (void)removeNowMedicineListObject:(Medicine *)value;
- (void)addNowMedicineList:(NSOrderedSet *)values;
- (void)removeNowMedicineList:(NSOrderedSet *)values;
@end
