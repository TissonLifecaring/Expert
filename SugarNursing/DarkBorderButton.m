//
//  DarkBorderButton.m
//  SugarNursing
//
//  Created by Ian on 15-1-29.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "DarkBorderButton.h"

@implementation DarkBorderButton


- (void)drawRect:(CGRect)rect {
    
    [[self layer] setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:0.5f] CGColor]];
    [[self layer] setBorderWidth:1.0];
}


@end
