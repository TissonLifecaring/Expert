//
//  UtilsMacro.h
//  SugarNursing
//
//  Created by Dan on 14-12-18.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//


#import <DDLog.h>
#import "AppDelegate.h"
#import "GCRequest.h"
#import <UIAlertView+AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import <AFNetworkActivityIndicatorManager.h>

#import "CoreDataStack.h"
#import "NSManagedObject+Finders.h"
#import "NSManagedObject+Savers.h"

#import "UIViewController+PushHelper.h"

#import "NSArray+Departments.h"

#import "NSString+Signatrue.h"
#import "NSString+MD5.h"
#import "NSString+UserCommon.h"
#import "NSString+ParseData.h"
#import "NSString+Ret_msg.h"
#import "NSString+dateFormatting.h"
#import "NSDictionary+LowerCaseKey.h"
#import "NSDictionary+Formatting.h"
#import "NSDate+Formatting.h"
#import "ParseData.h"
#import "DeviceHelper.h"

#import "User.h"
#import "UserInfomation.h"
#import "Department.h"
#import "Patient.h"
#import "MediRecord.h"
#import "MediAttach.h"
#import "ServCenter.h"
#import "Advice.h"
#import "TrusExpt.h"
#import "TrusPatient.h"
#import "Trusteeship.h"
#import "Takeover.h"
#import "LoadedLog.h"
#import "RecordLog.h"
#import "DietLog.h"
#import "Diet.h"
#import "ExerciseLog.h"
#import "DrugLog.h"
#import "Drug.h"
#import "DetectLog.h"
#import "ControlEffect.h"
#import "EffectList.h"
#import "Notice.h"
#import "Bulletin.h"
#import "TemporaryInfo.h"
#import "PatientInfo.h"
#import "AgentMsg.h"
#import "AdviceAttach.h"
#import "OtherMappingInfo.h"

#import "VendorMacro.h"

#import <DDLog.h>
#import <DDLegacy.h>
#import "SystemVersion.h"

#ifndef SugarNursing_UtilsMacro_h
#define SugarNursing_UtilsMacro_h


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


/*  For Debug  */

static const int ddLogLevel = DDLogLevelOff;



#define HUD_TIME_DELAY 1.25


#endif
