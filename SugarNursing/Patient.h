//
//  Patient.h
//  SugarNursing
//
//  Created by Ian on 15/7/28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OtherMappingInfo;

@interface Patient : NSManagedObject

@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSString * headImageUrl;
@property (nonatomic, retain) NSString * linkManId;
@property (nonatomic, retain) NSString * mobilePhone;
@property (nonatomic, retain) NSString * nextReportTime;
@property (nonatomic, retain) NSString * notTubeExptId;
@property (nonatomic, retain) NSString * notTubeExptName;
@property (nonatomic, retain) NSString * patientStat;
@property (nonatomic, retain) NSString * prevReportTime;
@property (nonatomic, retain) NSString * servBeginTime;
@property (nonatomic, retain) NSString * servLevel;
@property (nonatomic, retain) NSString * servRelation;
@property (nonatomic, retain) NSString * servStartTime;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * trusteeFlag;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) OtherMappingInfo *otherMappintInfo;

@end
