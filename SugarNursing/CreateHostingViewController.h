//
//  CreateHostingViewController.h
//  SugarNursing
//
//  Created by Ian on 14-11-25.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateHostingViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate
>



@property (strong, nonatomic) IBOutlet UIView *personPicker;
@property (strong, nonatomic) IBOutlet UIView *datePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;


@end
