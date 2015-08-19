//
//  ResetPwdViewController.h
//  SugarNursing
//
//  Created by Dan on 14-11-17.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPwdViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *getCodeAginBtn;
@property (strong, nonatomic) NSString *areaCode;
@property (strong, nonatomic) NSString *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@end
