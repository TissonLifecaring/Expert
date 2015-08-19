//
//  ResetPwdViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-17.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "ResetPwdViewController.h"
#import "AppDelegate+UserLogInOut.h"
#import <MBProgressHUD.h>
#import "UIStoryboard+Storyboards.h"
#import "UtilsMacro.h"

@interface ResetPwdViewController ()
<
UIAlertViewDelegate,
MBProgressHUDDelegate
>
{
    MBProgressHUD *hud;
    
    NSInteger _countDown;
    NSTimer *_timer;
}

@end

@implementation ResetPwdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Reset", nil);
    
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


- (IBAction)getCodeAgain:(id)sender
{
    NSString *confirmInfo = [NSString stringWithFormat:@"%@:%@ %@",NSLocalizedString(@"willsendthecodeto", nil),self.areaCode, self.phoneNumber];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"surephonenumber", nil) message:confirmInfo delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        
        
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
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.passwordTextField])
    {
        
        NSString *fieldText = self.passwordTextField.text;
        if (fieldText.length + string.length >16)
        {
            return NO;
        }
    }
    
    return YES;
}



- (IBAction)resetAndLogin:(id)sender
{
    
    
    if (![ParseData parsePasswordIsAvaliable:self.passwordTextField.text])
    {
        return;
    }
    
    if (self.codeTextField.text.length <=0)
    {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"verification code can't be empty", nil);
        [self.view addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            sleep(HUD_TIME_DELAY);
            return;
        }];
    }
    
    if (self.passwordTextField.text.length <=0)
    {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"password can't be empty", nil);
        [self.view addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            sleep(HUD_TIME_DELAY);
            return;
        }];
    }
    
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    
    NSDictionary *parameters = @{@"method":@"reSetPassword",
                                 @"mobile":self.phoneNumber,
                                 @"zone":self.areaCode,
                                 @"captcha":self.codeTextField.text,
                                 @"appType":@"2",
                                 @"password":self.passwordTextField.text
                                 };
    
     [GCRequest resetPasswordWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        
        
        if (!error)
        {
            
            
            if ([[responseData objectForKey:@"ret_code"] isEqualToString:@"0"])
            {
                [hud hide:YES];
//                //判断入口是登陆页面的'忘记密码'还是系统设置的'重设密码'
//                if (![NSString sessionID] && ![NSString sessionToken])
//                {
//                    
//                    hud.mode = MBProgressHUDModeText;
//                    hud.labelText = NSLocalizedString(@"password reset successful", nil);
//                    [AppDelegate userLogOut];
//                    [hud hide:YES afterDelay:HUD_TIME_DELAY];
//                }
//                else
//                {
//                    
//                    
//                    hud.mode = MBProgressHUDModeText;
//                    hud.labelText = NSLocalizedString(@"password reset successful", nil);
//                    [hud showAnimated:YES whileExecutingBlock:^{
//                        sleep(HUD_TIME_DELAY);
//                    } completionBlock:^{
//                        
//                        User *user = [User findAllInContext:[CoreDataStack sharedCoreDataStack].context][0];
//                        user.password = self.passwordTextField.text;
//                        
//                        [[CoreDataStack sharedCoreDataStack] saveContext];
//                        
//                        
//                        [self.navigationController popToRootViewControllerAnimated:YES];
//                    }];
//                }
                
                [AppDelegate userLogOut];
                
                UIView *view = [UIApplication sharedApplication].keyWindow.viewForBaselineLayout;
                hud = [[MBProgressHUD alloc] initWithView:view];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"Reset successed, Please login again", nil);
                [view addSubview:hud];
                [hud show:YES];
                [hud hide:YES afterDelay:2];
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


#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    hud2 = nil;
}


@end
