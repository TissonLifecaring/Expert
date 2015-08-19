//
//  MyPatientsViewController.h
//  SugarNursing
//
//  Created by Ian on 14-11-21.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyPatientsCell.h"

@interface MyPatientsViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate
>


@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end
