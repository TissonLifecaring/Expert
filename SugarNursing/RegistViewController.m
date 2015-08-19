//
//  RegistViewController.m
//  SugarNursing
//
//  Created by Dan on 14-11-16.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "RegistViewController.h"
#import "AppDelegate+UserLogInOut.h"
#import <MBProgressHUD.h>
#import "GCRequest.h"
#import <UIAlertView+AFNetworking.h>
#import "UtilsMacro.h"

@interface RegistViewController ()<UIAlertViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,UIScrollViewDelegate,MBProgressHUDDelegate,UIPopoverControllerDelegate>
{
    MBProgressHUD *hud;
    
    NSMutableArray *_departmentsArray;
    
    NSArray *_departCom0Array;
    NSArray *_departCom1Array;
    Department *_selectDepart;
    NSInteger _countDown;
    NSTimer *_timer;
}

@property (strong, nonatomic) UIPopoverController *popoverController;

@end


@implementation RegistViewController
@synthesize popoverController;

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    [_timer invalidate];
    _timer = nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Register", nil);
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"departments" ofType:@"plist"];
    NSArray *departments = [[NSArray alloc] initWithContentsOfFile:path];
    
    _departmentsArray = [departments mutableCopy];
    
    [self startCountDown];
    
    [self getDepartment];
    
    [self getServiceCenter];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    
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

- (void)getDepartment
{
    
    
}


- (void)getServiceCenter
{
    
    NSDictionary *paramters = @{@"method":@"getCenterInfoList",
                                @"centerId":@"1",
                                @"type":@"3"};
    [GCRequest getCenterInfoListWithParameters:paramters block:^(NSDictionary *responseData, NSError *error) {
        if (!error)
        {
            
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                
            }
            else
            {
                
            }
        }
        else
        {
            
        }
    }];
}


#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    hud2 = nil;
}


#pragma mark - IBAction

- (IBAction)getCodeAgain:(id)sender
{
    NSString *confirmInfo = [NSString stringWithFormat:@"%@:%@ %@",NSLocalizedString(@"willsendthecodeto", nil),self.areaCode, self.phoneNumber];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"suretosendphonenumber", nil) message:confirmInfo delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex) {
        
        
        if (buttonIndex == 1)
        {
            
            
            NSDictionary *parameters = @{@"method":@"getCaptcha",
                                         @"mobile":self.phoneNumber,
                                         @"zone":self.areaCode};
            
            
            [GCRequest getCaptchaWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
                
                if (!error)
                {
                    if ([responseData[@"ret_code"] isEqualToString:@"0"])
                    {
                        
                        _countDown = 60;
                        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownEvent:) userInfo:nil repeats:YES];
                        
                        
                        hud = [[MBProgressHUD alloc] initWithView:self.view];
                        [self.view addSubview:hud];
                        [hud setMode:MBProgressHUDModeText];
                        [hud setLabelText:NSLocalizedString(@"Verification code has been sent", nil)];
                        [hud show:YES];
                        [hud hide:YES afterDelay:HUD_TIME_DELAY];
                    }
                    else
                    {
                        
                        //获取验证码失败
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
                    
                    //获取验证码失败
                    NSString* str=[NSString stringWithFormat:NSLocalizedString(@"codesenderrormsg", nil)];
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"codesenderrtitle", nil) message:str delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
                    [alert show];
                }
            }];
        }
    }
}



- (IBAction)genderPicker:(id)sender
{
    
    [self resignFirstResponderForAllTextField];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"choosegender", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"male", nil),NSLocalizedString(@"female", nil), nil];
    [sheet setTag:1];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1)
    {
        
        if (buttonIndex > 0)
        {
            [self.genderBtn setTitle:[actionSheet buttonTitleAtIndex:buttonIndex]
                            forState:UIControlStateNormal];
        }
    }
    else
    {
        
        if (buttonIndex > 0)
        {
            [self.servicecenterBtn setTitle:[actionSheet buttonTitleAtIndex:buttonIndex]
                                   forState:UIControlStateNormal];
        }
    }
}

- (IBAction)datePicker:(id)sender
{
    [self resignFirstResponderForAllTextField];
    
    
    if ([DeviceHelper phone])
    {
        
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = self.datePickerView;
        hud.margin = 0;
        [self.view addSubview:hud];
        
        [hud show:YES];
    }
    else
    {
        
        if (self.popoverController)
        {
            [self.popoverController dismissPopoverAnimated:NO];
            self.popoverController = nil;
        }
        
        UIViewController* popoverContent = [[UIViewController alloc] init];
        popoverContent.view = self.datePickerView;
        
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.popoverController.popoverContentSize = self.datePickerView.bounds.size;
        
        CGRect rect = [self.scrollView convertRect:self.dateBtn.frame toView:self.view];
        [self.popoverController presentPopoverFromRect:CGRectMake(self.dateBtn.frame.origin.x+30, rect.origin.y+self.dateBtn.frame.size.height, 0, 0)
                                                inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionUp
                                              animated:YES];
    }
    
}



- (IBAction)datePickerButtonEvent:(id)sender
{
    
    UIButton *button = (UIButton *)sender;
    if (button.tag == 1)
    {
        
        NSDate *date = [self.datePicker date];
        
        NSTimeInterval interval = [date timeIntervalSinceNow];
        
        if (interval >= 0)
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil)
                                                            message:NSLocalizedString(@"Can't be late for today", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            NSString *dateString = [dateFormatter stringFromDate:date];
            
            
            [self.dateBtn setTitle:dateString forState:UIControlStateNormal];
            
        }
    }
    else
    {
        
    }
    
    
    if ([DeviceHelper phone])
    {
        [hud hide:YES];
    }
    else
    {
        if (self.popoverController)
        {
            [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController = nil;
        }
    }
    
}

- (IBAction)departmentPicker:(id)sender
{
    [self resignFirstResponderForAllTextField];
    
    
    
    NSDictionary *parameters = @{@"method":@"getDepartmentInfoList",
                                 @"departmentId":@"1",
                                 @"type":@"3"};
    
    NSArray *departObjects = [Department findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentId = 1"]
                                                    inContext:[CoreDataStack sharedCoreDataStack].context];
    
    
    if (departObjects.count <= 0)
    {
        
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        hud.labelText = NSLocalizedString(@"Loading Department Parameters", nil);
        [self.navigationController.view addSubview:hud];
        [hud show:YES];
        
        
        [GCRequest getDepartmentInfoListWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
            if (!error)
            {
                NSString *ret_code = responseData[@"ret_code"];
                if ([ret_code isEqualToString:@"0"])
                {
                    
                    [hud hide:YES];
                    
                    
                    [departObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Department *entity = (Department *)obj;
                        [entity deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    }];
                    
                    
                    for (NSDictionary *departDic in responseData[@"departmentList"])
                    {
                        
                        Department *department = [Department createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        
                        [department updateCoreDataForData:departDic withKeyPath:nil];
                        
                    }
                    
                    [[CoreDataStack sharedCoreDataStack] saveContext];
                    
                    [self configureDepartmentPickerDataSource];
                    [self.departmentPicker selectRow:0 inComponent:0 animated:NO];
                    [self.departmentPicker selectRow:0 inComponent:1 animated:NO];
                    
                    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                    [self.navigationController.view addSubview:hud];
                    
                    hud.mode = MBProgressHUDModeCustomView;
                    hud.customView = self.departmentCustomView;
                    hud.margin = 0;
                    [hud show:YES];
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
    else
    {
        [self configureDepartmentPickerDataSource];
        [self.departmentPicker selectRow:0 inComponent:0 animated:NO];
        [self.departmentPicker selectRow:0 inComponent:1 animated:NO];
        
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = self.departmentCustomView;
        hud.margin = 0;
        [hud show:YES];
        
    }
}


- (void)configureDepartmentPickerDataSource
{
    _departCom0Array = [NSArray arrayWithArray:[Department findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentId = %@",@"1"]
                                                                      inContext:[CoreDataStack sharedCoreDataStack].context]];
    Department *depart = _departCom0Array[0];
    _departCom1Array = [NSArray arrayWithArray:[Department findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentId = %@",depart.departmentId]
                                                                      inContext:[CoreDataStack sharedCoreDataStack].context]];
}


- (IBAction)serviceCenterPickerEvent:(id)sender
{
    
    [self resignFirstResponderForAllTextField];
    
    NSArray *objects = [ServCenter findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    
    if (objects.count <=0)
    {
        
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        [hud show:YES];
        
        
        NSDictionary *parameters = @{@"method":@"getCenterInfoList",
                                     @"centerId":@"1",
                                     @"type":@"3"};
        
        
        [GCRequest getCenterInfoListWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
            
            [hud hide:YES];
            
            if (!error)
            {
                NSArray *objects = responseData[@"centerList"];
                
                if (objects.count <= 0)
                {
                    
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = NSLocalizedString(@"none Service Center", nil);
                    [hud hide:YES afterDelay:2];
                }
                else
                {
                    
                    if ([responseData[@"ret_code"] isEqualToString:@"0"])
                    {
                        NSArray *objects = responseData[@"centerList"];
                        
                        [ServCenter deleteAllEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        
                        [ServCenter updateCoreDataWithListArray:objects identifierKey:@"centerId"];
                        
                        [[CoreDataStack sharedCoreDataStack] saveContext];
                        
                        [self showServicerSelectActionSheet];
                        
                    }
                }
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }];
    }
    else
    {
        [self showServicerSelectActionSheet];
    }
    
}

- (void)showServicerSelectActionSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"服务中心" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:nil];
    
    
    
    NSArray *objects = [ServCenter findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ServCenter *serv = (ServCenter *)obj;
        
        [sheet addButtonWithTitle:serv.centerName];
    }];
    
    [sheet showInView:self.view];
}


#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSInteger tag = textField.tag;
    tag += 100;
    UIImageView *bottomView = (UIImageView *)[self.view viewWithTag:tag];
    [bottomView setImage:[UIImage imageNamed:@"003"]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    NSInteger tag = textField.tag;
    tag += 100;
    UIImageView *bottomView = (UIImageView *)[self.view viewWithTag:tag];
    [bottomView setImage:[UIImage imageNamed:@"004"]];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.passwordField])
    {
        
        NSString *fieldText = self.passwordField.text;
        if (fieldText.length + string.length >16)
        {
            return NO;
        }
    }
    
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        return NO;
    }
    
    
    
    return YES;
}


#pragma mark - UIPickerView DataSource & Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if (component == 0)
    {
        return _departCom0Array.count;
    }
    else
    {
        return _departCom1Array.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (component == 0)
    {
        
        Department *department = _departCom0Array[row];
        
        
        return department.departmentName;
    }
    else
    {
        Department *department;
        
        if (row < _departCom1Array.count)
        {
            department = _departCom1Array[row];
        }
        
        
        return department.departmentName;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (component == 0)
    {
        
        if (row >= _departCom0Array.count)
        {
            return;
        }
        
        
        Department *department = _departCom0Array[row];
        NSString *parentId = department.departmentId;
        
        _departCom1Array = [Department findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentId = %@",parentId]
                                                  inContext:[CoreDataStack sharedCoreDataStack].context];
        
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [self.departmentPicker reloadComponent:1];
    }
    else
    {
        
        if (row >= _departCom1Array.count)
        {
            return;
        }
        
        //        Department *department = _departCom0Array[[pickerView selectedRowInComponent:0]];
        //        NSString *parentId = department.departmentId;
        //
        //        NSArray *objects = [Department findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentId = %@",parentId]
        //                                                  inContext:[CoreDataStack sharedCoreDataStack].context];
    }
}

- (IBAction)departmentPickerButtonEvent:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 1)
    {
        
        Department *department = _departCom0Array[[self.departmentPicker selectedRowInComponent:0]];
        NSString *parentId = department.departmentId;
        
        NSArray *objects = [Department findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentId = %@",parentId]
                                                  inContext:[CoreDataStack sharedCoreDataStack].context];
        department = objects[[self.departmentPicker selectedRowInComponent:1]];
        
        
        
        _selectDepart = department;
        
        NSString *title = department.departmentName;
        
        
        if (title && title.length > 0)
        {
            [self.departmentBtn setTitle:title forState:UIControlStateNormal];
        }
        
        [hud hide:YES];
    }
    else
    {
        
        [hud hide:YES];
    }
}




#pragma mark - 注册
- (IBAction)regist:(id)sender
{
    
    
    
    if (![ParseData parsePasswordIsAvaliable:self.passwordField.text])
    {
        return;
    }
    
    if (![ParseData parseRealNameIsAvaliable:self.usernameField.text])
    {
        return;
    }
    
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    
    
    if (self.codeTextField.text.length <=0)
    {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Please input verification code", nil);
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    
    if (self.hospitalTextField.text.length <=0)
    {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Please Input Hospital", nil);
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    
    
    if (!_selectDepart)
    {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Please Choose Department", nil);
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    
    
    
    NSArray *servArray = [ServCenter findAllWithPredicate:[NSPredicate predicateWithFormat:@"centerName = %@",self.servicecenterBtn.currentTitle]
                                                inContext:[CoreDataStack sharedCoreDataStack].context];
    
    ServCenter *serv;
    if (servArray.count <= 0)
    {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Please Choose Service Center", nil);
        [hud hide:YES afterDelay:HUD_TIME_DELAY];
        return;
    }
    else
    {
        serv = servArray[0];
    }
    
    
    
    
    
    NSDictionary *parameters = @{@"captcha":self.codeTextField.text,
                                 @"method":@"accountRegist",
                                 @"mobile":self.phoneNumber,
                                 @"password":self.passwordField.text,
                                 @"exptName":self.usernameField.text,
                                 @"sex":self.genderBtn.currentTitle,
                                 @"birthday":self.dateBtn.currentTitle,
                                 @"departmentId":_selectDepart.departmentId,
                                 @"hospital":self.hospitalTextField.text,
                                 @"appType":@"2",
                                 @"centerId":serv.centerId,
                                 @"zone":self.areaCode};
    
    
    
    [GCRequest accountRegistWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        
        
        if (!error)
        {
            
            if ([[responseData objectForKey:@"ret_code"] isEqualToString:@"0"])
            {
                [self performSegueWithIdentifier:@"goRegistComplete" sender:nil];
                [hud hide:YES];
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [hud hide:YES afterDelay:1.2];
            }
            
        }
        else [hud hide:YES afterDelay:0.25];
        
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignFirstResponderForAllTextField];
}


- (void)resignFirstResponderForAllTextField
{
    [self.codeTextField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    [self.hospitalTextField resignFirstResponder];
}



@end
