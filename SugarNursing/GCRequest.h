//
//  GCRequest.h
//  SugarNursing
//
//  Created by Ian on 14-12-30.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilsMacro.h"
#import "GCHttpClient.h"
#import <objc/runtime.h>


#pragma mark - Model

#pragma mark - Network Method
@interface GCRequest : NSObject


#pragma mark Verify
+ (NSURLSessionDataTask *)verifyWithParameters:(id)parameters block:(void (^) (NSDictionary *responseData, NSError *error))block;


#pragma mark AccountRegist
+ (NSURLSessionDataTask *)accountRegistWithParameters:(id)parameters block:(void (^) (NSDictionary *responseData, NSError *error))block;


#pragma mark GetCaptcha
+ (NSURLSessionDataTask *)getCaptchaWithParameters:(id)parameters block:(void (^) (NSDictionary *responseData, NSError *error))block;



#pragma mark GetPersonalInfo
+ (NSURLSessionDataTask *)getPersonalInfoWithParameters:(id)parameters block:(void (^) (NSDictionary *responseData, NSError *error))block;

#pragma mark AccountEdit
+ (NSURLSessionDataTask *)accountEditWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;

#pragma mark ExpertInfoEdit
+ (NSURLSessionDataTask *)expertInfoEditWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;

#pragma mark ResetPassword
+ (NSURLSessionDataTask *)resetPasswordWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark UploadFile
+ (NSURLSessionDataTask *)userUploadFileWithParameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))bodyBlock withBlock:(void (^)(NSDictionary *, NSError *))block;

#pragma mark GetDepartment
+ (NSURLSessionDataTask *)getDepartmentInfoListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;

#pragma mark GetNewMessageCount
+ (NSURLSessionDataTask *)getNewMessageCountWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;

#pragma mark GetLastVersion
+ (NSURLSessionDataTask *)getLastVersionWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;

#pragma mark IsMember
+ (NSURLSessionDataTask *)isMemberWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark SendDoctorSuggest
+ (NSURLSessionDataTask *)sendDoctorSuggestsWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;

#pragma mark GetDoctorSuggests
+ (NSURLSessionDataTask *)getDoctorSuggestsWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark QueryPatientList
+ (NSURLSessionDataTask *)queryPatientListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark GetPatientList
+ (NSURLSessionDataTask *)getPatientListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark GetCenterInfoList
+ (NSURLSessionDataTask *)getCenterInfoListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark GetMediRecordList
+ (NSURLSessionDataTask *)getMediRecordListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark GetTrusteeshipList
+ (NSURLSessionDataTask *)getTrusteeshipListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;

#pragma mark GetTakeOverList
+ (NSURLSessionDataTask *)getTakeOverListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;

#pragma mark SendTrusteeship
+ (NSURLSessionDataTask *)sendTrusteeshipWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark ApprTrusteeship
+ (NSURLSessionDataTask *)apprTrusteeshipWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark GetTrusExptList
+ (NSURLSessionDataTask *)getTrusExptListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;



#pragma mark QueryDetectLine
+ (NSURLSessionDataTask *)QueryDetectLineWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark QueryCureLogTimeLine
+ (NSURLSessionDataTask *)queryCureLogTimeLineWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark GetNoticeList
+ (NSURLSessionDataTask *)getNoticeListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark GetBulletinList
+ (NSURLSessionDataTask *)getBulletinListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;




#pragma mark QueryConclusion
+ (NSURLSessionDataTask *)queryConclusionWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark GetLinkManInfo
+ (NSURLSessionDataTask *)getLinkmanInfoWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;



#pragma mark GetMediRecordAttach
+ (NSURLSessionDataTask *)getMediRecordAttachWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark SendFeedBack
+ (NSURLSessionDataTask *)sendFeedBackWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark SetUserLanguage
+ (NSURLSessionDataTask *)setUserLanguageWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark GetLastPersonalInfo
+ (NSURLSessionDataTask *)getLastPersonalInfoWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;

#pragma mark ResetNewMessageCount
+ (NSURLSessionDataTask *)resetNewMessageCountWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;

#pragma mark DelSession
+ (NSURLSessionDataTask *)delSessionWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark GetAdviceTemplate
+ (NSURLSessionDataTask *)getAdviceTemplateWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark AdviceTemplateAdd
+ (NSURLSessionDataTask *)adviceTemplateAddWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark GetDoctorSuggestAttach
+ (NSURLSessionDataTask *)getDoctorSuggestAttachWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;


#pragma mark GetDoctorSuggestsWithAttach
+ (NSURLSessionDataTask *)getDoctorSuggestsWithAttachWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;




+ (id)signValueFor:(id)parameters;
@end
