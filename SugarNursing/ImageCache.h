//
//  ImageCache.h
//  SugarNursing
//
//  Created by Ian on 15/6/15.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ReportCache;

@interface ImageCache : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) ReportCache *reportCache;

@end
