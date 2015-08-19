//
//  Advice.m
//  SugarNursing
//
//  Created by Ian on 15/6/12.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "Advice.h"
#import "AdviceAttach.h"
#import "CoreDataStack.h"
#import "NSManagedObject+Savers.h"
#import "NSManagedObject+Finders.h"
#import "NSDictionary+Formatting.h"
#import "AdviceAttach.h"



@implementation Advice

@dynamic adviceId;
@dynamic adviceTime;
@dynamic content;
@dynamic exptId;
@dynamic linkManId;
@dynamic exptName;
@dynamic adviceAttach;


+ (void)updateAdviceListArray:(NSArray *)array identifierKey:(NSString *)identifierKey
{
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *dic = [obj mutableCopy];
        
        [dic minuteFormattingToServerForKey:@"adviceTime"];
        
        NSString *identifier = dic[identifierKey];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",identifierKey,identifier];
        NSArray *results = [self findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context];
        
        Advice *advice;
        if (results.count<=0)
        {
            advice = [self createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
        }
        else
        {
            advice = results[0];
        }
        
        [advice updateCoreDataForData:dic withKeyPath:nil];
        
        
        NSArray *attachArray = dic[@"attach"];
        NSMutableOrderedSet *orderSet = [[NSMutableOrderedSet alloc] init];
        for (NSDictionary *dic in attachArray)
        {
            AdviceAttach *attach = [AdviceAttach createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
            [attach updateCoreDataForData:dic withKeyPath:nil];
            [orderSet addObject:attach];
        }
        
        advice.adviceAttach = orderSet;
    }];
    
}

@end
