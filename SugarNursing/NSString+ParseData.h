//
//  NSString+ParseData.h
//  SugarNursing
//
//  Created by Ian on 14-12-30.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ParseData)

+ (NSString *)parseDictionary:(NSDictionary *)data forKeyPath:(NSString *)keyPath;

@end
