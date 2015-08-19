//
//  NSDate+Formatting.h
//  SugarNursing
//
//  Created by Ian on 15-1-13.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatting)


+ (NSDate *)dateByString:(NSString *)dateString dateFormat:(NSString *)dateFormat;


- (BOOL)laterThanDate:(NSDate *)date;
- (BOOL)laterAndEqualThanDate:(NSDate *)date;

- (BOOL)earlierThanDate:(NSDate *)date;
- (BOOL)earlierAndEqualThanDate:(NSDate *)date;



+ (NSInteger)ageWithDateOfBirth:(NSDate *)birthDay;
+ (NSInteger)numberOfDaysBetweenFirstDay:(NSDate *)firstDay endDay:(NSDate *)endDay;

@end
