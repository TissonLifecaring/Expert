//
//  CustomLabel.m
//  SugarNursing
//
//  Created by Dan on 14-12-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "CustomLabel.h"
#import "DeviceHelper.h"

@implementation CustomLabel

- (void)customSetup
{
    self.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    [self customSetup];
    return self;
}

- (void)awakeFromNib
{
    [self customSetup];
}

@end
