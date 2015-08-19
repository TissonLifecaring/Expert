//
//  ReportCache.h
//  SugarNursing
//
//  Created by Ian on 15/6/15.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ImageCache;

@interface ReportCache : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * linkManId;
@property (nonatomic, retain) NSOrderedSet *imageCache;
@end

@interface ReportCache (CoreDataGeneratedAccessors)

- (void)insertObject:(ImageCache *)value inImageCacheAtIndex:(NSUInteger)idx;
- (void)removeObjectFromImageCacheAtIndex:(NSUInteger)idx;
- (void)insertImageCache:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeImageCacheAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInImageCacheAtIndex:(NSUInteger)idx withObject:(ImageCache *)value;
- (void)replaceImageCacheAtIndexes:(NSIndexSet *)indexes withImageCache:(NSArray *)values;
- (void)addImageCacheObject:(ImageCache *)value;
- (void)removeImageCacheObject:(ImageCache *)value;
- (void)addImageCache:(NSOrderedSet *)values;
- (void)removeImageCache:(NSOrderedSet *)values;
@end
