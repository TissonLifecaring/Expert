//
//  ServCenter.h
//  SugarNursing
//
//  Created by Ian on 15-1-6.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ServCenter : NSManagedObject

@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSString * centerId;
@property (nonatomic, retain) NSString * centerName;
@property (nonatomic, retain) NSString * seq;

+ (NSString *)getCenterNameByID:(NSString *)centerId;


+ (NSString *)getCenterIdByName:(NSString *)centerName;

@end
