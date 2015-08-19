//
//  AreaNameAndCodeViewController.h
//  SugarNursing
//
//  Created by Dan on 14-12-17.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Block)(NSString *countryName, NSString *areCode);


@interface AreaNameAndCodeViewController : UIViewController


@property (strong, nonatomic) Block block;

@end
