//
//  NSDictionary+Configure.m
//  SugarNursing
//
//  Created by Ian on 15-1-8.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "NSDictionary+Configure.h"
#import <objc/runtime.h>
#import "UtilsMacro.h"

@implementation NSDictionary (Configure)

+ (NSDictionary *)configureByModel:(id)model
{
    NSMutableDictionary *modelDictionary = [NSMutableDictionary dictionary];
    unsigned int outCount,i;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char *proName = property_getName(property);
        if (proName)
        {
            
            NSString *propertyName = [NSString stringWithUTF8String:proName];
            
            id propertyValue = [model valueForKey:propertyName];
            
            if ([propertyValue isKindOfClass:[NSString class]] || [propertyValue isKindOfClass:[NSNumber class]])
            {
                [modelDictionary setValue:propertyValue forKey:propertyName];
            }
        }
    }
    
    return modelDictionary;
}

@end
