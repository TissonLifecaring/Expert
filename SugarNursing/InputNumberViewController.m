//
//  InputNumberViewController.m
//  SugarNursing
//
//  Created by Ian on 14-12-18.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "InputNumberViewController.h"
#import <MBProgressHUD.h>
#import "UtilsMacro.h"
#import "AppDelegate+UserLogInOut.h"

@interface InputNumberViewController ()<MBProgressHUDDelegate>
{
    MBProgressHUD *hud;
    NSInteger _countDown;
    NSTimer *_timer;
}
@property (weak, nonatomic) IBOutlet UIImageView *numberBottonView;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIButton *getCodeAginBtn;


@end

@implementation InputNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startCountDown];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_timer invalidate];
    _timer = nil;
}


- (void)startCountDown
{
    
    _countDown = 60;
    [self.getCodeAginBtn setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1]];
    self.getCodeAginBtn.userInteractionEnabled = NO;
    [self.getCodeAginBtn setTitle:[NSString stringWithFormat:@"%lds%@",_countDown,NSLocalizedString(@"Get", nil)]
                         forState:UIControlStateNormal];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownEvent:) userInfo:nil repeats:YES];
}


- (void)countDownEvent:(NSTimer *)timer
{
    
    _countDown--;
    if (_countDown > 0)
    {
        
        self.getCodeAginBtn.userInteractionEnabled = NO;
        [self.getCodeAginBtn setTitle:[NSString stringWithFormat:@"%lds%@",_countDown,NSLocalizedString(@"Get", nil)]
                             forState:UIControlStateNormal];
        
    }
    else
    {
        [_timer invalidate];
        [self.getCodeAginBtn setUserInteractionEnabled:YES];
        [self.getCodeAginBtn setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:128.0/255.0 blue:0.0/255.0 alpha:1]];
        [self.getCodeAginBtn setTitle:NSLocalizedString(@"Get Again", nil) forState:UIControlStateNormal];
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.numberBottonView setImage:[UIImage imageNamed:@"003"]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.numberBottonView setImage:[UIImage imageNamed:@"007"]];
}

- (IBAction)sendVerificationButtonEvent:(id)sender
{
    if ([self.codeTextField isFirstResponder])
    {
        [self.codeTextField resignFirstResponder];
    }
    
    
    NSDictionary *parameters = @{@"method":@"getCaptcha",
                                 @"mobile":self.phoneNumber,
                                 @"zone":self.areaCode};
    
    [GCRequest getCaptchaWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        
        if (!error)
        {
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                
                [self startCountDown];
                
                hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                [hud setMode:MBProgressHUDModeText];
                [hud setLabelText:NSLocalizedString(@"Verification code has been sent", nil)];
                [hud show:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
            else
            {
                
                hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [hud show:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
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

- (IBAction)bindPhoneButtonEvent:(id)sender
{
    
    if ([self.codeTextField isFirstResponder])
    {
        [self.codeTextField resignFirstResponder];
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    [hud show:YES];
    
    NSDictionary *parameters = @{@"method":@"accountEdit",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"sessionToken":[NSString sessionToken],
                                 @"exptId":[NSString exptId],
                                 @"mobile":self.phoneNumber,
                                 @"captcha":self.codeTextField.text,
                                 @"zone":self.areaCode
                                 };

    [GCRequest accountEditWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        if (!error)
        {
            
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                [hud hide:YES];
                
                [AppDelegate userLogOut];
                
                UIView *view = [UIApplication sharedApplication].keyWindow.viewForBaselineLayout;
                hud = [[MBProgressHUD alloc] initWithView:view];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"PhoneNumber binding successed, Please login again", nil);
                [view addSubview:hud];
                [hud show:YES];
                [hud hide:YES afterDelay:2];
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
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



#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    hud2 = nil;
}


@end
