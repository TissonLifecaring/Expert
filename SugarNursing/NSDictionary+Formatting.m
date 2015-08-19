//
//  NSDictionary+Formatting.m
//  SugarNursing
//
//  Created by Dan on 14-12-30.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "NSDictionary+Formatting.h"
#import "UtilsMacro.h"

@implementation NSDictionary (Formatting)

- (void)dateObjectFormattingForKey:(NSString *)key
{
    // Formatting to date Object "2015-01-01"
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@",self[key]]];
    
    [self setValue:date forKey:key];
}


- (void)dateFormattingToUserForKey:(NSString *)key
{
    // Formatting to "2015-01-01"
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@",self[key]]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    [self setValue:[dateFormatter stringFromDate:date] forKey:key];
}

- (void)dateFormattingToServerForKey:(NSString *)key
{
    // Formatting to "20150101"
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:self[key]];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    [self setValue:[dateFormatter stringFromDate:date] forKey:key];
    
}

- (void)dateFormattingFromServer:(NSString *)dateFormatting ForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormatting];
    NSString *dateString = [NSString stringWithFormat:@"%@",self[key]];
    NSDate *date = [dateFormatter dateFromString:dateString];
    [self setValue:date forKey:key];
}


- (void)monthFormattingToUserForKey:(NSString *)key
{
    // Formatting to "2015-01"
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *birthDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@",self[key]]];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    
    [self setValue:[dateFormatter stringFromDate:birthDate] forKey:key];
    
}

- (void)monthFormattingToServerForKey:(NSString *)key
{
    // Formatting to "201501"
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSDate *date = [dateFormatter dateFromString:self[key]];
    [dateFormatter setDateFormat:@"yyyyMM"];
    
    [self setValue:[dateFormatter stringFromDate:date] forKey:key];
}

- (void)minuteFormattingToServerForKey:(NSString *)key
{
    
    // Formatting to "2015-01"
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *birthDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@",self[key]]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//    NSLog(@"%@",[dateFormatter stringFromDate:birthDate]);
    [self setValue:[dateFormatter stringFromDate:birthDate] forKey:key];
}


- (void)dateFormattingByFormat:(NSString *)former toFormat:(NSString *)targetFormat key:(NSString *)key
{
    
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:former];
    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@",self[key]]];
    [dateFormatter setDateFormat:targetFormat];
    
    [self setValue:[dateFormatter stringFromDate:date] forKey:key];
}


- (void)sexFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *sex = [NSString stringWithFormat:@"%@",self[key]];
    
    [self setValue:[sex isEqualToString:@"01"] ? NSLocalizedString(@"male2", nil) :[sex isEqualToString:@"00"] ? NSLocalizedString(@"female2", nil) : nil forKey:key];
}

- (void)sexFormattingToServerForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *sex = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self[key]]];
    
    [self setValue:[sex isEqualToString:NSLocalizedString(@"female", nil)] ? @"00" :[sex isEqualToString:NSLocalizedString(@"male", nil)] ? @"01" : nil forKey:key];
    
}

#pragma mark - 服务等级格式化
- (void)servLevelFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *level = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self[key]]];
    
    [self setValue:[level isEqualToString:@"00"] ? NSLocalizedString(@"none", nil) :[level isEqualToString:@"01"] ? NSLocalizedString(@"open", nil) : nil forKey:key];
}

- (void)servLevelFormattingToServerForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *level = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self[key]]];
    
    [self setValue:[level isEqualToString:NSLocalizedString(@"none", nil)] ? @"00" :[level isEqualToString:NSLocalizedString(@"open", nil)] ? @"01" : nil forKey:key];

}



#pragma mark - 专家等级格式化
- (void)expertLevelFormattingToUserForKey:(NSString *)key
{
    
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *level = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self[key]]];
    
    NSString *value;
    
    if ([level isEqualToString:@"00"])
    {
        value = NSLocalizedString(@"physician", nil);
    }
    else if ([level isEqualToString:@"01"])
    {
        value = NSLocalizedString(@"director", nil);
    }
    else if ([level isEqualToString:@"02"])
    {
        value = NSLocalizedString(@"professor", nil);
    }
    else
    {
        value = @"";
    }
    [self setValue:value forKey:key];
    
}


- (void)expertLevelFormattingToServerForKey:(NSString *)key
{
    
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *level = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self[key]]];
    
    
    NSString *value;
    

    if ([level isEqualToString:NSLocalizedString(@"physician", nil)])
    {
        value = @"00";
    }
    else if ([level isEqualToString:NSLocalizedString(@"director", nil)])
    {
        value = @"01";
    }
    else if ([level isEqualToString:NSLocalizedString(@"professor", nil)])
    {
        value = @"02";
    }
    else
    {
        value = @"";
    }
    
    [self setValue:value forKey:key];
    
}



#pragma mark - 病人状态格式化
- (void)patientStateFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *state = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self[key]]];
    
    NSString *value;
    if ([state isEqualToString:@"00"])
    {
        value = NSLocalizedString(@"manage", nil);
    }
    else if ([state isEqualToString:@"01"])
    {
        value = NSLocalizedString(@"trusteeship", nil);
    }
    else if ([state isEqualToString:@"02"])
    {
        value = NSLocalizedString(@"takeover", nil);
    }
    else
    {
        value = @"";
    }
    
    [self setValue:value forKey:key];
    
}
- (void)patientStateFormattingToServerForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *state = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self[key]]];
    
    NSString *value;
    if ([state isEqualToString:NSLocalizedString(@"manage", nil)])
    {
        value = @"00";
    }
    else if ([state isEqualToString:NSLocalizedString(@"trusteeship", nil)])
    {
        value = @"01";
    }
    else if ([state isEqualToString:NSLocalizedString(@"takeover", nil)])
    {
        value = @"02";
    }
    else
    {
        value = @"";
    }
    
    [self setValue:value forKey:key];
}


#pragma mark - 运动时段格式化
- (void)sportPeriodFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *sportPeriod = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self[key]]];
    
    NSString *value;
    if ([sportPeriod isEqualToString:@"01"])
    {
        value = NSLocalizedString(@"before breakfast", nil);
    }
    else if ([sportPeriod isEqualToString:@"02"])
    {
        value = NSLocalizedString(@"after breakfast", nil);
    }
    else if ([sportPeriod isEqualToString:@"03"])
    {
        value = NSLocalizedString(@"before lunch", nil);
    }
    else if ([sportPeriod isEqualToString:@"04"])
    {
        value = NSLocalizedString(@"after lunch", nil);
    }
    else if ([sportPeriod isEqualToString:@"05"])
    {
        value = NSLocalizedString(@"before dinner", nil);
    }
    else if ([sportPeriod isEqualToString:@"06"])
    {
        value = NSLocalizedString(@"after dinner", nil);
    }
    else
    {
        value = @"";
    }
    
    
    [self setValue:value forKey:key];
    
}




#pragma mark - 药物单位状态格式化
- (void)drugUnitFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *state = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self[key]]];
    
    NSString *value;
    if ([state isEqualToString:@"01"])
    {
        value = NSLocalizedString(@"milligram", nil);
    }
    else if ([state isEqualToString:@"02"])
    {
        value = NSLocalizedString(@"gram", nil);
    }
    else if ([state isEqualToString:@"03"])
    {
        value = NSLocalizedString(@"grain", nil);
    }
    else if ([state isEqualToString:@"04"])
    {
        value = NSLocalizedString(@"piece", nil);
    }
    else if ([state isEqualToString:@"05"])
    {
        value = NSLocalizedString(@"unit", nil);
    }
    else if ([state isEqualToString:@"06"])
    {
        value = NSLocalizedString(@"milliliter", nil);
    }
    else if ([state isEqualToString:@"07"])
    {
        value = NSLocalizedString(@"branch", nil);
    }
    else if ([state isEqualToString:@"08"])
    {
        value = NSLocalizedString(@"bottle", nil);
    }
    else
    {
        value = @"";
    }
    
    
//    "milligram" = "毫克";
//    "gram" = "克";
//    "grain" = "粒";
//    "piece" = "片";
//    "unit" = "单位";
//    "milliliter" = "毫升";
//    "branch" = "支";
//    "bottle" = "瓶";

    [self setValue:value forKey:key];
    
}






#pragma mark - 药物用法格式化
- (void)drugUsageFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *usage = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self[key]]];
    
    NSString *value;
    if ([usage isEqualToString:@"01"])
    {
        value = NSLocalizedString(@"per os", nil);
    }
    else if ([usage isEqualToString:@"02"])
    {
        value = NSLocalizedString(@"insulin pump", nil);
    }
    else if ([usage isEqualToString:@"03"])
    {
        value = NSLocalizedString(@"injection", nil);
    }
    else
    {
        value = @"";
    }

    
    [self setValue:value forKey:key];
    
}



#pragma mark - 食物单位格式化
- (void)foodUnitFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *unit = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self[key]]];
    
    NSString *value;
    if ([unit isEqualToString:@"01"])
    {
        value = NSLocalizedString(@"gram", nil);
    }
    else if ([unit isEqualToString:@"02"])
    {
        value = NSLocalizedString(@"milliliter", nil);
    }
    else
    {
        value = @"";
    }
    
    
    [self setValue:value forKey:key];
    
}



#pragma mark - 进食时间段格式化
- (void)dietPeriodFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *usage = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self[key]]];
    
    NSString *value;
    if ([usage isEqualToString:@"01"])
    {
        value = NSLocalizedString(@"breakfast", nil);
    }
    else if ([usage isEqualToString:@"02"])
    {
        value = NSLocalizedString(@"lunch", nil);
    }
    else if ([usage isEqualToString:@"03"])
    {
        value = NSLocalizedString(@"dinner", nil);
    }
    else if ([usage isEqualToString:@"04"])
    {
        value = NSLocalizedString(@"extra meal", nil);
    }
    else
    {
        value = @"";
    }
    
    
    [self setValue:value forKey:key];
    
}



#pragma mark - 数据来源格式化
- (void)dataSourceFormattingToUserForKey:(NSString *)key
{
    
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    
    NSString *unit = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self[key]]];
    
    NSString *value;
    if ([unit isEqualToString:@"01"])
    {
        value = @"GlucoTrack";
    }
    else if ([unit isEqualToString:@"02"])
    {
        value = NSLocalizedString(@"Other's facility", nil);
    }
    else
    {
        value = @"";
    }
    
    
    [self setValue:value forKey:key];
}

#pragma mark - 病人状态格式化
- (void)feelingFormattingToUserForKey:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) {
        return;
    }
    if (![self isKindOfClass:[NSMutableDictionary class]]) {
        DDLogInfo(@"Running %@, %@ is not Mutable!",NSStringFromSelector(_cmd),self);
        return;
    }
    NSString *feeling = [NSString stringWithFormat:@"%@",self[key]];
    NSMutableArray *feelingArr = [NSMutableArray arrayWithArray:[feeling componentsSeparatedByString:@","]];
    
    NSDictionary *feelingDic = @{@"01":NSLocalizedString(@"正常", nil),
                                 @"02":NSLocalizedString(@"三多", nil),
                                 @"03":NSLocalizedString(@"乏力", nil),
                                 @"04":NSLocalizedString(@"腹痛", nil),
                                 @"05":NSLocalizedString(@"气短", nil),
                                 @"06":NSLocalizedString(@"胸闷", nil),
                                 @"07":NSLocalizedString(@"头晕", nil),
                                 @"08":NSLocalizedString(@"恶心", nil),
                                 @"09":NSLocalizedString(@"冷汗 ", nil),
                                 @"10":NSLocalizedString(@"其他", nil),
                                 };
    
    [feelingArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *feel = (NSString *)obj;
        NSString *feel_ = feelingDic[feel];
        if (feel_) {
            [feelingArr replaceObjectAtIndex:idx withObject:feelingDic[feel]];
        }
    }];
    
    feeling = [feelingArr componentsJoinedByString:@","];
    
    [self setValue:feeling forKey:key];
}



@end
