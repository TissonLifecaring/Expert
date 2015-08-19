//
//  RecoveryLogViewController.h
//  SugarNursing
//
//  Created by Ian on 14-11-26.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilsMacro.h"
#import <SSPullToRefresh.h>

@interface RecoveryLogViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate
>

@property (assign, nonatomic) BOOL isMyPatient;
@property (strong, nonatomic) NSString *linkManId;

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) SSPullToRefreshView *refreshView;


@end
