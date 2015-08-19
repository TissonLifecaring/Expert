//
//  AboutUsViewController.m
//  SugarNursing
//
//  Created by Ian on 15-2-2.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "AboutUsViewController.h"
#import <MobClick.h>
#import <CoreText/CoreText.h>
#import "VendorMacro.h"
#import <MBProgressHUD.h>


@interface AboutUsViewController ()<UIAlertViewDelegate>
{
    MBProgressHUD *hud;

}
@property (weak, nonatomic) IBOutlet UILabel *alertViewTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertViewContentLabel;
@property (strong, nonatomic) IBOutlet UIView *myAlertView;


@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) NSString *update_path;

@end

@implementation AboutUsViewController

- (void)viewDidLoad
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Version", nil),version];
}

- (IBAction)updateButtonEvent:(id)sender
{
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    [MobClick checkUpdateWithDelegate:self selector:@selector(callBackEvent:)];
}

- (void)callBackEvent:(NSDictionary *)info
{
    
    BOOL update = [[info objectForKey:@"update"] boolValue];
    
    if (update)
    {
        
        self.update_path = info[@"path"];
        NSString *newVersion = [info objectForKey:@"version"];
        
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = self.myAlertView;
        hud.margin = 0;
        
        
        NSString *titleString = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Find the new Version", nil),newVersion];
        NSString *contentString = info[@"update_log"];
        
        [self.alertViewTitleLabel setText:titleString];
        [self.alertViewContentLabel setText:contentString];
    }
    else
    {
        hud.mode = MBProgressHUDModeText;
        hud.labelText =NSLocalizedString(@"It's the newest version", nil);
        [hud hide:YES afterDelay:1.2];
    }
}


- (IBAction)alertViewButtonEvent:(UIButton *)sender
{
    if (sender.tag == 0)
    {
        
        [hud hide:YES];
    }
    else
    {
        
        [hud hide:YES];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.update_path]];
    }
}


@end
