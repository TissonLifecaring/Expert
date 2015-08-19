//
//  LoadedLog.h
//  SugarNursing
//
//  Created by Ian on 15-3-12.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LoadedLog : NSManagedObject

@property (nonatomic, retain) NSString * department;
@property (nonatomic, retain) NSString * patient;
@property (nonatomic, retain) NSString * serviceCenter;
@property (nonatomic, retain) NSString * trusExpt;
@property (nonatomic, retain) NSString * trusPatient;
@property (nonatomic, retain) NSString * userInfo;
@property (nonatomic, retain) NSString * temporaryInfo;


+ (LoadedLog *)shareLoadedLog;

+ (BOOL)needReloadedByKey:(NSString *)key;
@end
