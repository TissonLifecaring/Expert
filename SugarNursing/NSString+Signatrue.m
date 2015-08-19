//
//  NSString+Signatrue.m
//  SugarNursing
//
//  Created by Ian on 14-12-25.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "NSString+Signatrue.h"
#import "NSString+MD5.h"
#import "NSString+UserCommon.h"
#import "User.h"
#import "NSManagedObject+Finders.h"
#import "CoreDataStack.h"

@implementation NSString (Signatrue)


+ (NSString *)generateSigWithParameters:(NSDictionary *)parameters
{
    NSMutableArray *keys = [[parameters allKeys] mutableCopy];
    NSMutableArray *keysToRemove = [@[] mutableCopy];
    
    for (NSString *key in keys)
    {
        if ([key isEqualToString:@"method"]) {
            [keysToRemove addObject:key];
        }
        if ([key isEqualToString:@"sign"]) {
            [keysToRemove addObject:key];
        }
        if ([key isEqualToString:@"sessionId"]) {
            [keysToRemove addObject:key];
        }
        if ([key isEqualToString:@"sessionToken"])
        {
            [keysToRemove addObject:key];
        }
        if ([[parameters objectForKey:key] isEqualToString:@""]) {
            [keysToRemove addObject:key];
        }
    }
    
    [keys removeObjectsInArray:keysToRemove];
    
    
    // SortedArray
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
    
    
    __block NSString *joinString = @"";
    [sortedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *akey = (NSString *)obj;
        NSString *keyAndValue = [akey stringByAppendingString:[parameters objectForKey:akey]];
        joinString = [joinString stringByAppendingString:keyAndValue];
    }];
    
    
    NSArray *fetchArray = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    if (fetchArray.count == 0)
    {
        return nil;
    }
    User *user = fetchArray[0];
    
    
    joinString = [joinString stringByAppendingString:user.sessionToken];
    
    
    
    return [joinString md5];
}



@end
