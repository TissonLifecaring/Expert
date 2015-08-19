//
//  VerificationViewController.m
//  SugarNursing
//
//  Created by Dan on 14-12-16.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "VerificationViewController.h"
#import "AreaNameAndCodeViewController.h"
#import "RegistViewController.h"
#import "ResetPwdViewController.h"
#import <MBProgressHUD.h>
#import "UtilsMacro.h"
#import "InputNumberViewController.h"
#import "UIStoryboard+Storyboards.h"


@interface VerificationViewController ()<UIAlertViewDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *hud;
}

@property (strong, nonatomic) NSString *countryName;
@property (strong, nonatomic) NSString *areaCode;


@end

@implementation VerificationViewController

- (void)awakeFromNib
{
    
    self.countryName = NSLocalizedString(@"hongkong", nil);
    self.areaCode = @"852";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateLabels];

}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)updateLabels
{
    self.countryLabel.text = self.countryName;
    self.areaCodeLabel.text = [NSString stringWithFormat:@"+%@",self.areaCode];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    switch (indexPath.row)
    {
        case 0:
        case 3:
            height = 40;
            break;
        case 1:
        case 2:
            height = 48;
            break;
        default:
            break;
    }
    return height;
}

- (IBAction)GetVerificationCode:(id)sender
{
//    if ([self.phoneField.text isEqualToString:@"000"])
//    {
//        switch (self.verifiedType)
//        {
//            case VerifiedTypeRegister:
//                [self performSegueWithIdentifier:@"Register" sender:nil];
//                return;
//            case VerifiedTypeForget:
//                [self performSegueWithIdentifier:@"Reset" sender:nil];
//                return;
//            case VerifiedTypeReset:
//                [self performSegueWithIdentifier:@"Reset" sender:nil];
//                return;
//            case VerifiedTypeBindPhone:
//                [self performSegueWithIdentifier:@"goInputCode" sender:nil];
//                return;
//        }
//    }
//    
    if ([self.phoneField isFirstResponder])
    {
        [self.phoneField resignFirstResponder];
    }
    
    
    
    if (([self.areaCode isEqualToString:@"86"] && self.phoneField.text.length != 11) ||
        ([self.areaCode isEqualToString:@"852"] && self.phoneField.text.length != 8))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil) message:NSLocalizedString(@"errorphonenumber", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    
    if (self.verifiedType == VerifiedTypeReset)
    {
        
        UserInfomation *info = [UserInfomation shareInfo];
        NSString *phoneNumber = info.mobilePhone;
        NSString *zone = info.mobileZone;
        
        if (![self.phoneField.text isEqualToString:phoneNumber] || ![self.areaCode isEqualToString:zone])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil)
                                                            message:NSLocalizedString(@"This number is not belong you", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
    }

    
    
    NSArray *objects = [UserInfomation findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    if (objects.count > 0)
    {
        UserInfomation *info = objects[0];
        
        if (![info.mobilePhone isEqualToString:self.phoneField.text])
        {
            hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"phone inconformity With Your account", nil);
        }
    }
    
    
    
    
    NSString *confirmInfo = [NSString stringWithFormat:@"%@:%@ %@",NSLocalizedString(@"willsendthecodeto", nil),self.areaCode, self.phoneField.text];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"surephonenumber", nil) message:confirmInfo delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    if (buttonIndex == 1)
    {
        
        if (self.verifiedType == VerifiedTypeBindPhone)
        {
            
            [self requestIsMemberWithType:VerifiedTypeBindPhone];
        }
        else if (self.verifiedType == VerifiedTypeReset)
        {
            
            hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
            hud.labelText = NSLocalizedString(@"Sending code", nil);
            [hud show:YES];
            
            [self sendCaptcha];
        }
        else if (self.verifiedType == VerifiedTypeRegister)
        {
            
            //weishu
            [self requestIsMemberWithType:VerifiedTypeRegister];
        
        }
        else if (self.verifiedType == VerifiedTypeForget)
        {
            //必须已注册
            [self requestIsMemberWithType:VerifiedTypeForget];
        }
    }
}


- (void)requestIsMemberWithType:(VerifiedType)type
{
    
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    hud.labelText = NSLocalizedString(@"Sending code", nil);
    [hud show:YES];
    
    NSDictionary *parameters = @{@"method":@"isMember",
                                 @"mobile":self.phoneField.text,
                                 @"memberType":@"1"};
    
    
    [GCRequest isMemberWithParameters:parameters block:^(NSDictionary *responseData, NSError *error)
    {
        
        
        if (!error)
        {
            NSString *ret_code = responseData[@"ret_code"];
            if ([ret_code isEqualToString:@"0"])
            {
                
                
                if (type == VerifiedTypeForget)
                {
                    
                    
                    if ([responseData[@"isMember"] isEqualToString:@"1"])
                    {
                        [self sendCaptcha];
                    }
                    else
                    {
                        [hud hide:YES];
                        
                        NSString *message = NSLocalizedString(@"phone is not regist", nil);
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil];
                        [alert show];
                    }
                }
                else if (type == VerifiedTypeRegister)
                {
                    
                    if ([responseData[@"isMember"] isEqualToString:@"0"])
                    {
                        [self sendCaptcha];
                    }
                    else
                    {
                        [hud hide:YES];
                        
                        NSString *message = NSLocalizedString(@"This number is already regist", nil);
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil];
                        [alert show];
                    }
                }
                else if (type == VerifiedTypeReset)
                {
                    
                }
                else if (type == VerifiedTypeBindPhone)
                {
                    
                    if ([responseData[@"isMember"] isEqualToString:@"0"])
                    {
                        [self sendCaptcha];
                    }
                    else
                    {
                        [hud hide:YES];
                        
                        NSString *message = NSLocalizedString(@"number is Binding telephone", nil);
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil];
                        [alert show];
                    }
                }
                
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
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

- (void)sendCaptcha
{
    
    
    NSDictionary *parameters = @{@"method":@"getCaptcha",
                                 @"mobile":self.phoneField.text,
                                 @"zone":self.areaCode};
    
    
    [GCRequest getCaptchaWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {    
        if (!error)
        {
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                
                [hud hide:YES];
                
                switch (self.verifiedType)
                {
                    case VerifiedTypeRegister:
                        [self performSegueWithIdentifier:@"Register" sender:nil];
                        return;
                    case VerifiedTypeForget:
                        [self performSegueWithIdentifier:@"Reset" sender:nil];
                        return;
                    case VerifiedTypeReset:
                        [self performSegueWithIdentifier:@"Reset" sender:nil];
                        return;
                    case VerifiedTypeBindPhone:
                        [self performSegueWithIdentifier:@"goInputCode" sender:nil];
                        return;
                }
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [hud hide:YES afterDelay:YES];

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


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"AreaCode"])
    {
        AreaNameAndCodeViewController *areaNameAndCodeVC = [segue destinationViewController];
        
        areaNameAndCodeVC.block = ^void(NSString *countryName,NSString *areaCode){
            self.countryName = countryName;
            self.areaCode = areaCode;
        };
    }
    else if ([segue.identifier isEqual:@"Register"])
    {
        RegistViewController *registerVC = [segue destinationViewController];
        registerVC.areaCode = self.areaCode;
        registerVC.phoneNumber = self.phoneField.text;
    }
    else if ([segue.identifier isEqual:@"Reset"])
    {
        ResetPwdViewController *resetVC = [segue destinationViewController];
        resetVC.areaCode = self.areaCode;
        resetVC.phoneNumber = self.phoneField.text;
    }
    else if ([segue.identifier isEqual:@"goInputCode"])
    {
        InputNumberViewController *inputVC = [segue destinationViewController];
        inputVC.phoneNumber = self.phoneField.text;
        inputVC.areaCode = self.areaCode;
    }
}


- (IBAction)back:(UIStoryboardSegue*)unwindSegue
{
    
}
@end
