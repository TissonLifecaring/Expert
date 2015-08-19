//
//  RegistViewController.h
//  SugarNursing
//
//  Created by Dan on 14-11-16.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"

@interface RegistViewController : UIViewController

@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *areaCode;

@property (weak, nonatomic) IBOutlet CustomLabel *codeField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UITextField *hospitalTextField;

@property (weak, nonatomic) IBOutlet UIButton *getCodeAginBtn;
@property (weak, nonatomic) IBOutlet UIButton *genderBtn;
@property (weak, nonatomic) IBOutlet UIButton *dateBtn;
@property (weak, nonatomic) IBOutlet UIButton *departmentBtn;
@property (weak, nonatomic) IBOutlet UIButton *servicecenterBtn;


@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIView *datePickerView;

@property (strong, nonatomic) IBOutlet UIView *departmentCustomView;
@property (weak, nonatomic) IBOutlet UIPickerView *departmentPicker;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollHeight;



@end
