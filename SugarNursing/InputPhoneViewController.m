//
//  InputPhoneViewController.m
//  SugarNursing
//
//  Created by Ian on 14-12-18.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "InputPhoneViewController.h"
#import "UtilsMacro.h"
#import <MBProgressHUD.h>
#import "InputNumberViewController.h"

@interface InputPhoneViewController ()<MBProgressHUDDelegate>
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIImageView *phoneButtonView;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;

@end

@implementation InputPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
            [self.phoneButtonView setImage:[UIImage imageNamed:@"003"]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
            [self.phoneButtonView setImage:[UIImage imageNamed:@"007"]];
}


- (IBAction)getNumberButtonEvent:(id)sender
{
    UserInfomation *info = [UserInfomation shareInfo];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    hud.labelText = NSLocalizedString(@"Sending code", nil);
    [hud show:YES];
    
    NSDictionary *parameters = @{@"method":@"getCaptcha",
                                 @"mobile":self.phoneField.text,
                                 @"zone":info.areaId};
    
    [GCRequest getCaptchaWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        
        if (!error)
        {
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                [hud hide:YES];
                
                [self performSegueWithIdentifier:@"inputVerificationNum" sender:nil];
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [hud hide:YES afterDelay:1.2];
            }
        }
        else
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    InputNumberViewController *vc = (InputNumberViewController *)[segue destinationViewController];
    vc.phoneNumber = self.phoneField.text;
}


- (IBAction)back:(UIStoryboardSegue *)sender
{
    
}

#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    hud2 = nil;
}



@end
