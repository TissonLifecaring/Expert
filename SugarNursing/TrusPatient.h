//
//  TrusPatient.h
//  SugarNursing
//
//  Created by Ian on 15-1-14.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TrusPatient : NSManagedObject

@property (nonatomic, retain) NSString * exptId;
@property (nonatomic, retain) NSString * linkManBirthday;
@property (nonatomic, retain) NSString * linkManHeadImageUrl;
@property (nonatomic, retain) NSString * linkManId;
@property (nonatomic, retain) NSString * linkManMobilePhone;
@property (nonatomic, retain) NSString * linkManUserName;
@property (nonatomic, retain) NSString * linkManServLevel;
@property (nonatomic, retain) NSString * linkManSex;
@property (nonatomic, retain) NSString * queryFlag;
@property (nonatomic, retain) NSString * servBeginTime;
@property (nonatomic, retain) NSString * servEndTime;
@property (nonatomic, retain) NSString * servId;
@property (nonatomic, retain) NSString * servRelation;
@property (nonatomic, retain) NSString * trusBeginTime;
@property (nonatomic, retain) NSString * trusEndTime;
@property (nonatomic, retain) NSString * trusteeFlag;

@end
