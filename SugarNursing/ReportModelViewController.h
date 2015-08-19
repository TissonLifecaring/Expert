//
//  ReportModelViewController.h
//  SugarNursing
//
//  Created by Ian on 15/5/29.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportModelViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end
