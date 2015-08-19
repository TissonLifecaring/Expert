//
//  NSManagedObject+Savers.m
//  SugarNursing
//
//  Created by Dan on 14-12-29.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "NSManagedObject+Savers.h"
#import "UtilsMacro.h"
#import <objc/runtime.h>
#import "NSString+ParseData.h"
#import "NSDictionary+Formatting.h"
#import "ParseData.h"

@implementation NSManagedObject (Savers)



+ (NSString *)entityName
{
    NSString *entityName;
    if ([entityName length] == 0) {
        entityName = NSStringFromClass(self);
    }
    return entityName;
}



+ (void)coverCoreDataWithArray:(NSArray *)array
{
    
    [self deleteAllEntityInContext:[CoreDataStack sharedCoreDataStack].context];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *dic = (NSDictionary *)obj;
        
        NSManagedObject *managedObj = [self createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
        [managedObj updateCoreDataForData:dic withKeyPath:nil];
        
    }];
}


- (void)updateCoreDataForData:(NSDictionary *)data withKeyPath:(NSString *)keyPath
{
    
    // Data is responseObject from server
    // Stay NSManagedObject's property the same with responseObject's key
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if (propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            
            NSString *aKeyPath;
            if (keyPath) {
                aKeyPath = [NSString stringWithFormat:@"%@.%@",keyPath,propertyName];
            }else{
                aKeyPath = propertyName;
            }
            //            NSString *propertyValue = [NSString parseDictionary:data ForKeyPath:aKeyPath];
            id propertyValue = [ParseData parseDictionary:data ForKeyPath:aKeyPath];
            
            
            // Only when data return a un-nil value does it invoke setValue:key:
            if (propertyValue && ([propertyValue isKindOfClass:[NSString class]] || [propertyValue isKindOfClass:[NSNumber class]])) {
                propertyValue = [NSString stringWithFormat:@"%@",propertyValue];
                [self setValue:propertyValue forKey:propertyName];
            }            
            if (propertyValue && [propertyValue isKindOfClass:[NSDate class]]) {
                [self setValue:propertyValue forKey:propertyName];
            }

        }
        
    }
    
    
}



#pragma mark 用于存放拥有唯一标识的数据, 标识重复时会覆盖
+ (void)updateCoreDataWithListArray:(NSArray *)array identifierKey:(NSString *)identifierKey
{
    
    if (!identifierKey)
    {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *dic = (NSDictionary *)obj;
            
            NSManagedObject *managedObj = [self createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
            [managedObj updateCoreDataForData:dic withKeyPath:nil];
        }];
        
    
    }
    else
    {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *dic = (NSDictionary *)obj;
            
            NSString *identifier = dic[identifierKey];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",identifierKey,identifier];
            NSArray *results = [self findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context];
            
            if (results.count<=0)
            {
                
                NSManagedObject *managedObj = [self createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                [managedObj updateCoreDataForData:dic withKeyPath:nil];
            }
            else
            {
                
                NSManagedObject *result = results[0];
                [result updateCoreDataForData:dic withKeyPath:nil];
            }
        }];
    }
}


#pragma mark 持久化维护手段(刷新操作,当返回数组的最后一个元素不存在与本地数据库时,则先删除全部本地数据再保存,避免本地数据跟后台不同步)
+ (void)synchronizationDataWithListArray:(NSArray *)parameters identifierKey:(NSString *)identifierKey
{
    
    
    NSDictionary *parameter = [parameters lastObject];
    
    
    NSString *identifier = [parameter objectForKey:identifierKey];
    if (identifier)
    {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",identifierKey,identifier];
        NSArray *array = [self findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context];
        
        if (!array || array.count <= 0)
        {
            [self deleteAllEntityInContext:[CoreDataStack sharedCoreDataStack].context];
            [self updateCoreDataWithListArray:parameters identifierKey:nil];
        }
        else
        {
            [self updateCoreDataWithListArray:parameters identifierKey:identifierKey];
        }
    }
}


@end
