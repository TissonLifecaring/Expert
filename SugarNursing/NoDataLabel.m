//
//  NoDataLabel.m
//  SugarNursing
//
//  Created by Ian on 15-1-26.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "NoDataLabel.h"

@implementation NoDataLabel


- (id)initWithFrame:(CGRect)frame
{
    
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.tag = 4000;
    self.backgroundColor = [UIColor clearColor];
    self.textAlignment = NSTextAlignmentCenter;
    self.text = NSLocalizedString(@"No Data", nil);
    self.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    self.textColor = [UIColor colorWithRed:2./255. green:136./255 blue:1 alpha:1];

    return self;
}

@end
