//
//  NSString+ParseData.m
//  SugarNursing
//
//  Created by Ian on 14-12-30.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "NSString+ParseData.h"
#import "UtilsMacro.h"

@implementation NSString (ParseData)

+ (NSString *)parseDictionary:(NSDictionary *)data forKeyPath:(NSString *)keyPath
{
    
    if (!data) {
        DDLogDebug(@"Dictionary to parese is nil.");
        return nil;
    }
    if (!keyPath) {
        DDLogDebug(@"Keypath of Dictionary is nil.");
        return nil;
    }
    if (![data isKindOfClass:[NSDictionary class]]) {
        DDLogDebug(@"Data to parse is not NSDictionaray class.");
        return nil;
    }
    
    NSString *aString;
    id  parseData = data;
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    
    for (__block NSString *key in keys) {
        
        
        if ([parseData isKindOfClass:[NSDictionary class]] || [parseData isKindOfClass:[NSMutableDictionary class]]) {
            if (![[parseData allKeys] containsObject:key]) {
                DDLogDebug(@"%@ does not contains key:%@",data, key);
                return nil;
            }
            parseData = parseData[key];
            
        }else if ([parseData isKindOfClass:[NSArray class]] || [parseData isKindOfClass:[NSMutableArray class]]){
            if (0 == [key integerValue] && ![key isEqualToString:@"0"]) {
                DDLogDebug(@"Array keypath is not a integer Value.");
                return nil;
            }
            if (!([key integerValue] >= 0 && [key integerValue] < [parseData count])) {
                DDLogDebug(@"Index %ld beyond array bounds",(long)[key integerValue]);
                return nil;
            }
            
            parseData = [parseData objectAtIndex:[key integerValue]];
            
        }else{
            DDLogDebug(@"Unkonwn Error in parse data. Running %@ %@",[self class],NSStringFromSelector(_cmd));
            return nil;
        }
        
    }
    
    aString = [NSString stringWithFormat:@"%@",parseData];
    
    return aString;
}

@end
