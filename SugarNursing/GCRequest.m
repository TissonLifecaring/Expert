//
//  GCRequest.m
//  SugarNursing
//
//  Created by Ian on 14-12-30.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "GCRequest.h"



@implementation GCRequest

#pragma mark Verify
+ (NSURLSessionDataTask *)verifyWithParameters:(id)parameters block:(void (^)(NSDictionary *, NSError *))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_VERIFY_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    //MD5
    parameters = [parameters mutableCopy];
    
    [parameters setValue:[[NSString parseDictionary:parameters forKeyPath:@"password"] md5] forKey:@"password"];
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_VERIFY_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"Verify resoponseData:%@",responseObject);
                                                                                  
                                         if (block) {
                                             block(responseObject, nil);
                                         }
                                         
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil,error);
                                         }
                                     }];
}

#pragma mark AccountRegister
+ (NSURLSessionDataTask *)accountRegistWithParameters:(id)parameters block:(void (^)(NSDictionary *, NSError *))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_REGISTER_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    //MD5
    parameters = [parameters mutableCopy];
    
    [parameters setValue:[[NSString parseDictionary:parameters forKeyPath:@"password"] md5] forKey:@"password"];
    
    // Sex
    [(NSDictionary *)parameters sexFormattingToServerForKey:@"sex"];
    
    //birthday
    [(NSDictionary *)parameters dateFormattingToServerForKey:@"birthday"];
    
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_REGISTER_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"Account Register resoponseData:%@",responseObject);
                                         
                                                                                  
                                         if (block) {
                                             block(responseObject,nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block) {
                                             block(nil,error);
                                         }
                                     }];
}


#pragma mark GetCaptcha
+ (NSURLSessionDataTask *)getCaptchaWithParameters:(id)parameters block:(void (^) (NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_GETCAPTCHA_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    
    
    return [[GCHttpClient sharedClient] POST:GC_COMMON_GETCAPTCHA_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"Account Register resoponseData:%@",responseObject);
                                         
                                         
                                         if (block) {
                                             block(responseObject,nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block) {
                                             block(nil,error);
                                         }
                                     }];
}



#pragma mark GetPersonalInfo
+ (NSURLSessionDataTask *)getPersonalInfoWithParameters:(id)parameters block:(void (^)(NSDictionary *, NSError *))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_USERINFO_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_USERINFO_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"Get Personal Info resoponseData:%@",responseObject);
                                         
                                         LoadedLog *log = [LoadedLog shareLoadedLog];
                                         log.userInfo = [NSString stringWithDateFormatting:GC_FORMATTER_SECOND date:[NSDate date]];
                                         [[CoreDataStack sharedCoreDataStack] saveContext];
                                         
                                         if (block) {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil,error);
                                         }
                                     }];
}

#pragma mark AccountEdit
+ (NSURLSessionDataTask *)accountEditWithParameters:(id)parameters block:(void (^)(NSDictionary *, NSError *))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_ACCOUNTEDIT_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_ACCOUNTEDIT_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"Account Edit resoponseData:%@",responseObject);
                                                                                  
                                         if (block)
                                         {
                                             block(responseObject,nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil,error);
                                         }
                                         
                                     }];
}


#pragma mark ExpertInfoEdit
+ (NSURLSessionDataTask *)expertInfoEditWithParameters:(id)parameters block:(void (^)(NSDictionary *, NSError *))block
{
    
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_INFOEDIT_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    // Sex
    [(NSDictionary *)parameters sexFormattingToServerForKey:@"sex"];
    
    //birthday
    [(NSDictionary *)parameters dateFormattingToServerForKey:@"birthday"];
    
    
    [self signValueFor:parameters];
    
    
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_INFOEDIT_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"Expert Info Edit resoponseData:%@",responseObject);
                                                                                  
                                         block(responseObject,nil);
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         block(nil,error);
                                     }];
}


#pragma mark RsetPassword
+ (NSURLSessionDataTask *)resetPasswordWithParameters:(id)parameters block:(void (^)(NSDictionary *, NSError *))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_RESETPASSWORD_URL relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    //MD5
    parameters = [parameters mutableCopy];
    
    [parameters setValue:[[NSString parseDictionary:parameters forKeyPath:@"password"] md5] forKey:@"password"];
    
    
    return [[GCHttpClient sharedClient] POST:GC_COMMON_RESETPASSWORD_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"Reset Password resoponseData:%@",responseObject);
                                                                                  
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         block(nil, error);
                                     }];
}


#pragma mark UploadFile
+ (NSURLSessionDataTask *)userUploadFileWithParameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))bodyBlock withBlock:(void (^)(NSDictionary *, NSError *))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_UPLOADFILE_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    return [[GCHttpClient sharedClient] POST:GC_COMMON_UPLOADFILE_URL parameters:parameters constructingBodyWithBlock:bodyBlock success:^(NSURLSessionDataTask *task, id responseObject) {
        
                                         
                                         DDLogDebug(@"Reset Password resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         block(nil, error);
                                     }];
}

#pragma mark GetDepartment
+ (NSURLSessionDataTask *)getDepartmentInfoListWithParameters:(id)parameters block:(void (^)(NSDictionary *, NSError *))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_GETDEPARTMENT_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];

    
    return [[GCHttpClient sharedClient] POST:GC_COMMON_GETDEPARTMENT_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"Get Department resoponseData:%@",responseObject);
                                         
                                         
                                         LoadedLog *log = [LoadedLog shareLoadedLog];
                                         log.department = [NSString stringWithDateFormatting:GC_FORMATTER_SECOND date:[NSDate date]];
                                         [[CoreDataStack sharedCoreDataStack] saveContext];
                                         
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}


#pragma mark GetNewMessageCount
+ (NSURLSessionDataTask *)getNewMessageCountWithParameters:(id)parameters block:(void (^)(NSDictionary *, NSError *))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_GETMSGCOUNT_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_COMMON_GETMSGCOUNT_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"Get Message Count resoponseData:%@",responseObject);
                                                                                  
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}


#pragma mark GetLastVersion
+(NSURLSessionDataTask *)getLastVersionWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_GETVERSION_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];

    return [[GCHttpClient sharedClient] POST:GC_COMMON_GETVERSION_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"Get Last Version resoponseData:%@",responseObject);
                                                                                  
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}


#pragma mark IsMember
+ (NSURLSessionDataTask *)isMemberWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_ISMEMBER_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];

    return [[GCHttpClient sharedClient] POST:GC_COMMON_ISMEMBER_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"Is Member resoponseData:%@",responseObject);
                                                                                  
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}



#pragma mark SendDoctorSuggest
+ (NSURLSessionDataTask *)sendDoctorSuggestsWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_SENDSUGGEST_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_SENDSUGGEST_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"Send Doctor Suggest resoponseData:%@",responseObject);
                                                                                  
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}



#pragma mark GetDoctorSuggests
+ (NSURLSessionDataTask *)getDoctorSuggestsWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_USER_GETDOCTORSUGGESTS_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GETDOCTORSUGGESTS_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"GetDoctorSuggests resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}


#pragma mark QueryPatientList
+ (NSURLSessionDataTask *)queryPatientListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_QUERYPATIENT_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_QUERYPATIENT_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"QueryPatientList resoponseData:%@",responseObject);
                                         
                                         
                                         LoadedLog *log = [LoadedLog shareLoadedLog];
                                         log.patient = [NSString stringWithDateFormatting:GC_FORMATTER_SECOND date:[NSDate date]];
                                         [[CoreDataStack sharedCoreDataStack] saveContext];
                                         
                                                                                  
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}



#pragma mark GetPatientList
+ (NSURLSessionDataTask *)getPatientListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_GETPATIENT_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_GETPATIENT_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"GetPatientList resoponseData:%@",responseObject);
                                         
                                         
                                         LoadedLog *log = [LoadedLog shareLoadedLog];
                                         log.trusPatient = [NSString stringWithDateFormatting:GC_FORMATTER_SECOND date:[NSDate date]];
                                         [[CoreDataStack sharedCoreDataStack] saveContext];
                                         
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}


#pragma mark GetMediRecordList
+ (NSURLSessionDataTask *)getMediRecordListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_USER_GETMEDIRECORD_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GETMEDIRECORD_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"GetMediRecordList resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}


#pragma mark GetCenterInfoList
+ (NSURLSessionDataTask *)getCenterInfoListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_GETCENTERLIST_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_COMMON_GETCENTERLIST_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"GetCenterInfoList resoponseData:%@",responseObject);
                                         
                                         
                                         LoadedLog *log = [LoadedLog shareLoadedLog];
                                         log.serviceCenter = [NSString stringWithDateFormatting:GC_FORMATTER_SECOND date:[NSDate date]];
                                         [[CoreDataStack sharedCoreDataStack] saveContext];
                                         
                                         
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}



#pragma mark GetTrusteeshipList
+ (NSURLSessionDataTask *)getTrusteeshipListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_GETTRUSTEESHIP_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_GETTRUSTEESHIP_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"GetTrusteeshipList resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}

#pragma mark GetTakeOverList
+ (NSURLSessionDataTask *)getTakeOverListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_GETTAKEOVER_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_GETTAKEOVER_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"GetTakeOverList resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}




#pragma mark SendTrusteeship
+ (NSURLSessionDataTask *)sendTrusteeshipWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_SENDTRUSTEESHIP_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_SENDTRUSTEESHIP_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"SendTrusteeship resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];

}




#pragma mark ApprTrusteeship
+ (NSURLSessionDataTask *)apprTrusteeshipWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_APPRTRUSTEESHIP_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_APPRTRUSTEESHIP_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"ApprTrusteeship resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}

#pragma mark GetTrusExptList
+ (NSURLSessionDataTask *)getTrusExptListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_GETTRUSEXPTLIST_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_GETTRUSEXPTLIST_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"GetTrusExptList resoponseData:%@",responseObject);
                                         
                                         LoadedLog *log = [LoadedLog shareLoadedLog];
                                         log.trusExpt = [NSString stringWithDateFormatting:GC_FORMATTER_SECOND date:[NSDate date]];
                                         [[CoreDataStack sharedCoreDataStack] saveContext];
                                         
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];

}



#pragma mark QueryDetectLine
+ (NSURLSessionDataTask *)QueryDetectLineWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_USER_GETDETECTLINE_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GETDETECTLINE_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"QueryDetectLine resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}



#pragma mark QueryCureLogTimeLine
+ (NSURLSessionDataTask *)queryCureLogTimeLineWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_USER_GETCURELOG_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GETCURELOG_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"QueryCureLogTimeLine resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}



#pragma mark GetNoticeList
+ (NSURLSessionDataTask *)getNoticeListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_GETNOTICELIST_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    return [[GCHttpClient sharedClient] POST:GC_COMMON_GETNOTICELIST_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"GetNoticeList resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}


#pragma mark GetBulletinList
+ (NSURLSessionDataTask *)getBulletinListWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_GETNOTICELIST_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_COMMON_GETNOTICELIST_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"GetBulletinList resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}


#pragma mark QueryConclusion
+ (NSURLSessionDataTask *)queryConclusionWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_USER_QUERYCONCLUSION_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_USER_QUERYCONCLUSION_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"QueryConclusion resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
    
}



#pragma mark GetLinkManInfo
+ (NSURLSessionDataTask *)getLinkmanInfoWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_USER_GETPERSONALINFO_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GETPERSONALINFO_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"GetLinkManInfo resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
    
}



#pragma mark GetMediRecordAttach
+ (NSURLSessionDataTask *)getMediRecordAttachWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_USER_GETMEDIRECORDATTACH_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_USER_GETMEDIRECORDATTACH_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"GetMediRecordAttach resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}


#pragma mark SendFeedBack
+ (NSURLSessionDataTask *)sendFeedBackWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_SENDFEEDBACK_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_COMMON_SENDFEEDBACK_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"SendFeedBack resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}



#pragma mark SetUserLanguage
+ (NSURLSessionDataTask *)setUserLanguageWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_SETLANGUAGE_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_COMMON_SETLANGUAGE_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"SetUserLanguage resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}


#pragma mark GetLastPersonalInfo
+ (NSURLSessionDataTask *)getLastPersonalInfoWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_GETLASTINFO_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_GETLASTINFO_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"GetLastPersonalInfo resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}



#pragma mark ResetNewMessageCount
+ (NSURLSessionDataTask *)resetNewMessageCountWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_RESETMSGCOUNT_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_COMMON_RESETMSGCOUNT_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"ResetNewMessageCount resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}



#pragma mark DelSession
+ (NSURLSessionDataTask *)delSessionWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_COMMON_DELSESSION_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_COMMON_DELSESSION_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"ResetNewMessageCount resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}



#pragma mark GetAdviceTemplate
+ (NSURLSessionDataTask *)getAdviceTemplateWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_GETADVICETEMPLATE_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_GETADVICETEMPLATE_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"ResetNewMessageCount resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}


#pragma mark AdviceTemplateAdd
+ (NSURLSessionDataTask *)adviceTemplateAddWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_ADVICETEMPLATEADD_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_ADVICETEMPLATEADD_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"ResetNewMessageCount resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}


#pragma mark GetDoctorSuggestAttach
+ (NSURLSessionDataTask *)getDoctorSuggestAttachWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_GETDOCTORSUGGESTATTACH_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_GETDOCTORSUGGESTATTACH_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"ResetNewMessageCount resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}


#pragma mark GetDoctorSuggestsWithAttach
+ (NSURLSessionDataTask *)getDoctorSuggestsWithAttachWithParameters:(id)parameters block:(void(^)(NSDictionary *responseData, NSError *error))block;
{
    
    DDLogInfo(@"Running %@ %@",[self class],NSStringFromSelector(_cmd));
    DDLogInfo(@"Requesting for URL:%@",[NSURL URLWithString:GC_EXPERT_GETDOCTORSUGGESTSWITHATTACH_URL
                                              relativeToURL:[GCHttpClient sharedClient].baseURL]);
    
    parameters = [parameters mutableCopy];
    
    [self signValueFor:parameters];
    
    
    return [[GCHttpClient sharedClient] POST:GC_EXPERT_GETDOCTORSUGGESTSWITHATTACH_URL
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         DDLogDebug(@"ResetNewMessageCount resoponseData:%@",responseObject);
                                         
                                         if (block)
                                         {
                                             block(responseObject, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error){
                                         
                                         DDLogDebug(@"Request Error: %@ %@",[error localizedFailureReason], NSStringFromSelector(_cmd));
                                         
                                         if (block)
                                         {
                                             block(nil, error);
                                         }
                                     }];
}



+ (id)signValueFor:(id)parameters
{
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        if ([[parameters allKeys] containsObject:@"sign"]) {
            [parameters setValue:[NSString generateSigWithParameters:parameters] forKey:@"sign"];
        }
    }
    
    return parameters;
}

@end
