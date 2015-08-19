//
//  UserInfoViewController.h
//  SugarNursing
//
//  Created by Ian on 14-11-17.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
UITextViewDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
UIAlertViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@property (strong, nonatomic) IBOutlet UIView *genderPicker;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) IBOutlet UIView *datePickerView;

@property (strong, nonatomic) IBOutlet UIView *departmentPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *departmentsPicker;

@end
