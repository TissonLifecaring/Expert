//
//  NSDate+Formatting.m
//  SugarNursing
//
//  Created by Ian on 15-1-13.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "NSDate+Formatting.h"

@implementation NSDate (Formatting)


+ (NSDate *)dateByString:(NSString *)dateString dateFormat:(NSString *)dateFormat
{
    
    
    if (dateString && dateString.length>0)
    {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:dateFormat];
        
        return [formatter dateFromString:dateString];
    }
    else
    {
        return [NSDate date];
    }
    
    return nil;
}

- (BOOL)laterThanDate:(NSDate *)date
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    
    NSString *myDate = [formatter stringFromDate:self];
    NSString *otherDate = [formatter stringFromDate:date];
    
    return [myDate integerValue] > [otherDate integerValue] ? YES : NO ;
}


- (BOOL)laterAndEqualThanDate:(NSDate *)date
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    
    NSString *myDate = [formatter stringFromDate:self];
    NSString *otherDate = [formatter stringFromDate:date];
    
    return [myDate integerValue] >= [otherDate integerValue] ? YES : NO ;
}


- (BOOL)earlierAndEqualThanDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    
    NSString *myDate = [formatter stringFromDate:self];
    NSString *otherDate = [formatter stringFromDate:date];
    
    return [myDate integerValue] <= [otherDate integerValue] ? YES : NO ;
}


- (BOOL)earlierThanDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    
    NSString *myDate = [formatter stringFromDate:self];
    NSString *otherDate = [formatter stringFromDate:date];
    
    return [myDate integerValue] < [otherDate integerValue] ? YES : NO ;
}




+ (NSInteger)ageWithDateOfBirth:(NSDate *)birthDay
{
    if (!birthDay)
    {
        return 0;
    }
    
    NSDate* now = [NSDate date];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    unsigned int unitFlags = NSCalendarUnitYear;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:birthDay  toDate:now  options:0];
    NSInteger year = [comps year];
    
    return year;
}

+ (NSInteger)numberOfDaysBetweenFirstDay:(NSDate *)firstDay endDay:(NSDate *)endDay
{
    if (!firstDay || !endDay)
    {
        return 0;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    unsigned int unitFlags = NSCalendarUnitDay;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:firstDay toDate:endDay options:0];
    NSInteger days = [comps day];
    
    return days;
}

@end
