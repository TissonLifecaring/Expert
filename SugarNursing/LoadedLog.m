//
//  LoadedLog.m
//  SugarNursing
//
//  Created by Ian on 15-3-12.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "LoadedLog.h"
#import "CoreDataStack.h"
#import "NSManagedObject+Finders.h"
#import "NSString+dateFormatting.h"
#import "VendorMacro.h"


@implementation LoadedLog

@dynamic department;
@dynamic patient;
@dynamic serviceCenter;
@dynamic trusExpt;
@dynamic trusPatient;
@dynamic userInfo;
@dynamic temporaryInfo;


static NSDictionary *intervalDic;

+ (LoadedLog *)shareLoadedLog
{
    
    NSArray *objects = [LoadedLog findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    
    LoadedLog *log;
    if (objects.count <= 0)
    {
        log = [LoadedLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
    }
    else
    {
        log = objects[0];
    }
    
    return log;
}



+ (BOOL)needReloadedByKey:(NSString *)key
{
    
    intervalDic = @{@"department":GC_FORMATTER_MONTH,
                    @"serviceCenter":GC_FORMATTER_DAY,
                    @"trusPatient":GC_FORMATTER_MINUTE,
                    @"trusExpt":GC_FORMATTER_MINUTE,
                    @"patient":GC_FORMATTER_MINUTE,
                    @"userInfo":GC_FORMATTER_MINUTE,
                    @"temporaryInfo":GC_FORMATTER_MINUTE
                    };
    
    NSString *interval = [intervalDic objectForKey:key];
    
    LoadedLog *log = [LoadedLog shareLoadedLog];
    
    NSString *lastDate = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND
                                                       toFormat:interval
                                                         string:[log valueForKey:key]];
    if (!lastDate || lastDate.length <=0)
    {
        return YES;
    }
    
    
    NSString *now = [NSString stringWithDateFormatting:interval date:[NSDate date]];
    
    if ([now isEqualToString:lastDate])
    {
        return NO;
    }
    
    
    return YES;
}




@end
