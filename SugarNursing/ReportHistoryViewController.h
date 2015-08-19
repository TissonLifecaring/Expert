//
//  SendSuggestViewController.h
//  SugarNursing
//
//  Created by Ian on 14-11-27.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilsMacro.h"
#import "MyTextView.h"


@interface ReportHistoryViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate
>

@property (strong, nonatomic) NSString *linkManId;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
