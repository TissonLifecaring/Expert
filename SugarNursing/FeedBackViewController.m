//
//  FeedBackViewController.m
//  SugarNursing
//
//  Created by Ian on 14-12-16.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "FeedBackViewController.h"
#import "UtilsMacro.h"
#import <MBProgressHUD.h>
#import "DeviceHelper.h"

@interface FeedBackViewController ()<MBProgressHUDDelegate>
{
    MBProgressHUD *hud;
}
@end

@implementation FeedBackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myTextView.placeholder = @"请输入您的反馈";
    self.myTextView.placeholderColor = [UIColor lightGrayColor];
    
    
    self.myTextView.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    [self.myTextView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor];
    self.myTextView.layer.borderWidth = 1.0f;
}

- (IBAction)submitFeedBack:(id)sender
{
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    [hud show:YES];
    
    NSDictionary *parameters = @{@"method":@"sendFeedBack",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"sessionToken":[NSString sessionToken],
                                 @"content":self.myTextView.text,
                                 @"sendUser":[NSString exptId]};
    
    [GCRequest sendFeedBackWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        
        if (!error)
        {
            
            NSString *ret_code = responseData[@"ret_code"];
            if ([ret_code isEqualToString:@"0"])
            {
                
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"Send Succeed", nil);
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
                [self.navigationController popViewControllerAnimated:YES];
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
            hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
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
