//
//  NSString+dateFormatting.m
//  SugarNursing
//
//  Created by Ian on 15-1-10.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "NSString+dateFormatting.h"

@implementation NSString (dateFormatting)


+ (NSString *)stringWithDateFormatting:(NSString *)formatter date:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    return [dateFormatter stringFromDate:date];
}


+ (NSString *)dateFormattingByBeforeFormat:(NSString *)beforeFormer toFormat:(NSString *)targetFormat string:(NSString *)dateString
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:beforeFormer];
    NSDate *date = [dateFormatter dateFromString:dateString];
    [dateFormatter setDateFormat:targetFormat];
    return [dateFormatter stringFromDate:date];
}


+ (NSString *)ageWithDateOfBirth:(NSDate *)birthDay
{
    if (!birthDay)
    {
        return @"0";
    }
    
    NSDate* now = [NSDate date];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    unsigned int unitFlags = NSCalendarUnitYear;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:birthDay  toDate:now  options:0];
    NSInteger year = [comps year];
    
    return [NSString stringWithFormat:@"%ld",(long)year];
}

+ (NSString *)numberOfDaysBetweenFirstDay:(NSDate *)firstDay endDay:(NSDate *)endDay
{
    if (!firstDay || !endDay)
    {
        return @"0";
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    unsigned int unitFlags = NSCalendarUnitDay;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:firstDay toDate:endDay options:0];
    NSInteger days = [comps day];
    
    return [NSString stringWithFormat:@"%ld",days];
}


+ (NSString *)compareNearDate:(NSDate *)date
{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday,*beforeYesterday;
    
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    beforeYesterday = [today dateByAddingTimeInterval:-2*secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
//    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    NSString * beforeYesterdayString = [[beforeYesterday description] substringToIndex:10];
    
    
    NSString * dateString = [[NSString stringWithDateFormatting:@"yyyy-MM-dd" date:date] substringToIndex:10];
    
    
    if ([dateString isEqualToString:todayString])
    {
        return NSLocalizedString(@"today", nil);
    }
    else if ([dateString isEqualToString:yesterdayString])
    {
        return NSLocalizedString(@"yesterday", nil);
    }
//    else if ([dateString isEqualToString:tomorrowString])
//    {
//        return NSLocalizedString(@"tomorrow", nil);
//    }
    else if ([dateString isEqualToString:beforeYesterdayString])
    {
        return NSLocalizedString(@"beforeYesterday", nil);
    }
    else
    {
        return dateString;
    }
}


@end
