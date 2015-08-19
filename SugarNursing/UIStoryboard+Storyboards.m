//
//  UIStoryboard+Storyboards.m
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "UIStoryboard+Storyboards.h"

@implementation UIStoryboard (Storyboards)

+ (UIStoryboard *)mainStoryboard
{
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}


+ (UIStoryboard *)loginStoryboard
{
    return [UIStoryboard storyboardWithName:@"Login" bundle:nil];
}

+ (UIStoryboard *)testTracker
{
    return [UIStoryboard storyboardWithName:@"TestTracker" bundle:nil];
}

+ (UIStoryboard *)myPatientStoryboard
{
    return [UIStoryboard storyboardWithName:@"MyPatient" bundle:nil];
}

+ (UIStoryboard *)myHostingStoryboard
{
    return [UIStoryboard storyboardWithName:@"MyHosting" bundle:nil];
}

+ (UIStoryboard *)myTakeoverStoryboard
{
    return [UIStoryboard storyboardWithName:@"MyTakeover" bundle:nil];
}

+ (UIStoryboard *)myMessageStoryboard
{
    return [UIStoryboard storyboardWithName:@"MyMessage" bundle:nil];
}

+ (UIStoryboard *)memberCenterStoryboard
{
    return [UIStoryboard storyboardWithName:@"MemberCenter" bundle:nil];
}


+ (UIStoryboard *)systemSetStoryboard
{
    return [UIStoryboard storyboardWithName:@"SystemSet" bundle:nil];
}

+ (UIStoryboard *)sendReportStoryboard
{
    return [UIStoryboard storyboardWithName:@"SendReport" bundle:nil];
}

@end
