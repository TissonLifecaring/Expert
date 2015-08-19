//
//  ControlEffectViewController.h
//  SugarNursing
//
//  Created by Dan on 14-11-21.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilsMacro.h"

@interface ControlEffectViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>


@property (assign, nonatomic) BOOL isMyPatient;
@property (strong, nonatomic) NSString *linkManId;

@end
