//
//  UIApplication+ResponseAPNS.h
//  SugarNursing
//
//  Created by Ian on 15-3-4.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (ResponseAPNS)

+ (void)responseAPNS:(NSDictionary *)info;

@end
