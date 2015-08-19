//
//  NSString+UserCommon.h
//  SugarNursing
//
//  Created by Dan on 14-12-27.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UserCommon)

+ (NSString *)exptId;
+ (NSString *)sessionID;
+ (NSString *)sessionToken;
+ (NSString *)username;

@end
