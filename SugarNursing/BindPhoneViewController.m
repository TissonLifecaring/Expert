//
//  BindPhoneViewController.m
//  SugarNursing
//
//  Created by Ian on 14-12-18.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "BindPhoneViewController.h"
#import "UIViewController+Notifications.h"
#import "UtilsMacro.h"
#import <MBProgressHUD.h>
#import "VerificationViewController.h"
#import "UIStoryboard+Storyboards.h"


@interface BindPhoneViewController ()<MBProgressHUDDelegate>
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIImageView *phoneButtonView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordButtonView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleYCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topYCons;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation BindPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self registerForKeyboardNotification:@selector(keyBoardWillShow:) :@selector(keyBoardWillHide:)];
}

- (void)keyBoardWillShow:(NSNotification *)notification
{
    
    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat kbHeight = kbSize.height;
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if (screenHeight - kbHeight >= 120)
    {
        return;
    }
    else
    {
        self.topYCons.constant = 30;
        [self.view setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:0.4 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)keyBoardWillHide:(NSNotification *)notaification
{
    
    self.topYCons.constant = 80;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case 101:
            [self.phoneButtonView setImage:[UIImage imageNamed:@"003"]];
            break;
        case 102:
            [self.passwordButtonView setImage:[UIImage imageNamed:@"003"]];
            break;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case 101:
            [self.phoneButtonView setImage:[UIImage imageNamed:@"004"]];
            break;
        case 102:
            [self.passwordButtonView setImage:[UIImage imageNamed:@"004"]];
            break;
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([string isEqualToString:@"\n"])
    {
        
        if (textField.tag == 101)
        {
            
            UITextField *tv = (UITextField *)[self.view viewWithTag:102];
            [tv becomeFirstResponder];
        }
        else
        {
            [textField resignFirstResponder];
        }
        
        return NO;
    }
    
    return YES;
}



- (IBAction)verificationButtonEvent:(id)sender
{
    UserInfomation *info = [UserInfomation shareInfo];
    User *user = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context][0];
    
    
    if (![self.phoneTextField.text isEqualToString:info.mobilePhone])
    {
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"This Telephone is not belong you", nil);
        [hud show:YES];
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
    }
    else if (![[self.passwordTextField.text md5] isEqualToString:user.password])
    {
        
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"phoneNumber or password error", nil);
        [hud show:YES];
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
    }
    else
    {
        
        VerificationViewController *verfication = [[UIStoryboard loginStoryboard] instantiateViewControllerWithIdentifier:@"Verification"];
        
        verfication.title = NSLocalizedString(@"Reset telephone", nil);
        verfication.verifiedType = VerifiedTypeBindPhone;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        {
            [self showViewController:verfication sender:nil];
            
        }
        else
        {
            [self.navigationController pushViewController:verfication animated:YES];
        }

    }
}


#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    hud2 = nil;
}


- (IBAction)back:(UIStoryboardSegue *)sender
{
    
}

@end
