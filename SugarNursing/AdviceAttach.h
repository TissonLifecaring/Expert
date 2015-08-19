//
//  AdviceAttach.h
//  SugarNursing
//
//  Created by Ian on 15/6/10.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Advice;

@interface AdviceAttach : NSManagedObject

@property (nonatomic, retain) NSString * attachName;
@property (nonatomic, retain) NSString * attachPath;
@property (nonatomic, retain) Advice *advice;

@end
