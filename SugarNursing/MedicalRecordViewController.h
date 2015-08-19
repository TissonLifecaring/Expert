//
//  MedicalRecordViewController.h
//  SugarNursing
//
//  Created by Ian on 15/5/13.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilsMacro.h"
#import <MBProgressHUD.h>
#import <SSPullToRefreshView.h>

@interface MedicalRecordViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
MBProgressHUDDelegate
>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) NSString *linkManId;

@property (assign, nonatomic) BOOL isMyPatient;

@property (strong, nonatomic) SSPullToRefreshView *refreshView;

@end
