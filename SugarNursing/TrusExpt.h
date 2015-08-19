//
//  TrusExpt.h
//  SugarNursing
//
//  Created by Ian on 15-1-14.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TrusExpt : NSManagedObject

@property (nonatomic, retain) NSString * departmentId;
@property (nonatomic, retain) NSString * departmentName;
@property (nonatomic, retain) NSString * exptId;
@property (nonatomic, retain) NSString * exptName;

@end
