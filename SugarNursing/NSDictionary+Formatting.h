//
//  NSDictionary+Formatting.h
//  SugarNursing
//
//  Created by Dan on 14-12-30.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Formatting)


#pragma mark - 时间格式化
- (void)dateObjectFormattingForKey:(NSString *)key;
- (void)dateFormattingToUserForKey:(NSString *)key;
- (void)dateFormattingToServerForKey:(NSString *)key;
- (void)dateFormattingFromServer:(NSString *)dateFormatting ForKey:(NSString *)key;
- (void)monthFormattingToUserForKey:(NSString *)key;
- (void)monthFormattingToServerForKey:(NSString *)key;
- (void)minuteFormattingToServerForKey:(NSString *)key;
- (void)dateFormattingByFormat:(NSString *)former toFormat:(NSString *)targetFormat key:(NSString *)key;

#pragma mark - 性别格式化
- (void)sexFormattingToUserForKey:(NSString *)key;
- (void)sexFormattingToServerForKey:(NSString *)key;

#pragma mark - 服务等级格式化
- (void)servLevelFormattingToUserForKey:(NSString *)key;
- (void)servLevelFormattingToServerForKey:(NSString *)key;

#pragma mark - 专家等级格式化
- (void)expertLevelFormattingToUserForKey:(NSString *)key;
- (void)expertLevelFormattingToServerForKey:(NSString *)key;

#pragma mark - 病人状态格式化
- (void)patientStateFormattingToUserForKey:(NSString *)key;
- (void)patientStateFormattingToServerForKey:(NSString *)key;

#pragma mark - 运动时段格式化
- (void)sportPeriodFormattingToUserForKey:(NSString *)key;


#pragma mark - 药物单位状态格式化
- (void)drugUnitFormattingToUserForKey:(NSString *)key;


#pragma mark - 药物用法格式化
- (void)drugUsageFormattingToUserForKey:(NSString *)key;


#pragma mark - 食物单位格式化
- (void)foodUnitFormattingToUserForKey:(NSString *)key;

#pragma mark - 进食时间段格式化
- (void)dietPeriodFormattingToUserForKey:(NSString *)key;

#pragma mark - 数据来源格式化
- (void)dataSourceFormattingToUserForKey:(NSString *)key;

#pragma mark - 病人状态格式化
- (void)feelingFormattingToUserForKey:(NSString *)key;

@end
