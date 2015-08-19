//
//  NetworkURLMacro.h
//  SugarNursing
//
//  Created by Dan on 14-12-18.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#ifndef SugarNursing_NetworkURLMacro_h
#define SugarNursing_NetworkURLMacro_h

/*  URLSession Configuration  */

#define TIMEOUT_INTERVAL_FORREQUEST 15

static NSString * const GCHttpBaseURLString = @"http://192.168.1.6:8080/lcp-laop/";
static NSString * const GCHttpOfficialURLString = @"http://172.16.24.72:8083/lcp-laop/";
static NSString * const GCHttpCloudURLString = @"http://120.24.60.25:8081/lcp-laop/";
static NSString * const GCHttpProductionURLString = @"http://user.lifecaring.cn/lcp-laop/";
static NSString * const GCHttpJuanURLString = @"http://172.16.27.223:8080/lcp-laop/";

// Login URL
//#define GC_LOGIN_URL @"rest/laop/linkMan/account"
//#define GC_USER_REGISTER_URL @"rest/laop/linkMan/account"
//#define GC_USER_GETINFO_URL @"rest/laop/linkMan/account"

#define GC_EXPERT_REGISTER_URL @"rest/laop/expert/account"
#define GC_EXPERT_VERIFY_URL @"rest/laop/expert/account"
#define GC_EXPERT_USERINFO_URL @"rest/laop/expert/account"
#define GC_EXPERT_ACCOUNTEDIT_URL @"rest/laop/expert/account"
#define GC_EXPERT_INFOEDIT_URL @"rest/laop/expert/account"
#define GC_EXPERT_QUERYPATIENT_URL @"rest/laop/expert/patient"
#define GC_EXPERT_GETPATIENT_URL @"rest/laop/expert/patient"
#define GC_EXPERT_SENDSUGGEST_URL @"rest/laop/expert/suggest"
#define GC_EXPERT_GETTRUSTEESHIP_URL @"rest/laop/expert/trusteeship"
#define GC_EXPERT_GETTAKEOVER_URL @"rest/laop/expert/takeOver"
#define GC_EXPERT_SENDTRUSTEESHIP_URL @"rest/laop/expert/trusteeship"
#define GC_EXPERT_APPRTRUSTEESHIP_URL @"rest/laop/expert/trusteeship"
#define GC_EXPERT_GETTRUSEXPTLIST_URL @"rest/laop/expert/trusteeship"
#define GC_EXPERT_GETLASTINFO_URL @"rest/laop/expert/account"
#define GC_EXPERT_GETADVICETEMPLATE_URL @"rest/laop/expert/suggest"
#define GC_EXPERT_ADVICETEMPLATEADD_URL @"rest/laop/expert/suggest"


#define GC_USER_GETMEDIRECORD_URL @"rest/laop/linkMan/mediRecord"
#define GC_USER_GETDETECTLINE_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_GETCURELOG_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_GETDOCTORSUGGESTS_URL @"rest/laop/linkMan/suggest"
#define GC_USER_QUERYCONCLUSION_URL @"rest/laop/linkMan/cureLog"
#define GC_USER_GETPERSONALINFO_URL @"rest/laop/linkMan/account"
#define GC_USER_GETMEDIRECORDATTACH_URL @"rest/laop/linkMan/mediRecord"

#define GC_EXPERT_GETDOCTORSUGGESTATTACH_URL @"rest/laop/linkMan/suggest"
#define GC_EXPERT_GETDOCTORSUGGESTSWITHATTACH_URL @"rest/laop/linkMan/suggest"




#define GC_COMMON_GETCAPTCHA_URL @"rest/laop/common/captcha"
#define GC_COMMON_GETCENTERLIST_URL @"rest/laop/common/hospital"
#define GC_COMMON_RESETPASSWORD_URL @"rest/laop/common/account"
#define GC_COMMON_UPLOADFILE_URL @"rest/laop/common/upload"
#define GC_COMMON_GETDEPARTMENT_URL @"rest/laop/common/hospital"
#define GC_COMMON_GETMSGCOUNT_URL @"rest/laop/common/message"
#define GC_COMMON_GETVERSION_URL @"rest/laop/common/version"
#define GC_COMMON_ISMEMBER_URL @"rest/laop/common/account"
#define GC_COMMON_GETNOTICELIST_URL @"rest/laop/common/message"
#define GC_COMMON_GETBULLETINLIST_URL @"rest/laop/common/message"
#define GC_COMMON_SENDFEEDBACK_URL @"rest/laop/common/feedBack"
#define GC_COMMON_SETLANGUAGE_URL @"rest/laop/common/language"
#define GC_COMMON_RESETMSGCOUNT_URL @"rest/laop/common/message"
#define GC_COMMON_DELSESSION_URL @"rest/laop/common/account"


#endif
