//
//  NSString+dateFormatting.h
//  SugarNursing
//
//  Created by Ian on 15-1-10.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (dateFormatting)

+ (NSString *)stringWithDateFormatting:(NSString *)formatter date:(NSDate *)date;


+ (NSString *)dateFormattingByBeforeFormat:(NSString *)beforeFormer toFormat:(NSString *)targetFormat string:(NSString *)dateStrin;


+ (NSString *)ageWithDateOfBirth:(NSDate *)birthDay;

+ (NSString *)numberOfDaysBetweenFirstDay:(NSDate *)firstDay endDay:(NSDate *)endDay;


+ (NSString *)compareNearDate:(NSDate *)date;
@end


