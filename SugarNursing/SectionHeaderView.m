//
//  SectionHeaderView.m
//  SugarNursing
//
//  Created by Dan on 14-11-27.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "SectionHeaderView.h"

@implementation SectionHeaderView

- (void)awakeFromNib
{
    self.arrowBtn.selected = NO;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
    [self addGestureRecognizer:tapGesture];
}

- (IBAction)toggleOpen:(id)sender
{
    [self toggleOpenWithUserAction:YES];
}


- (void)toggleOpenWithUserAction:(BOOL)userAction
{
//    
    // toggle the disclosure button state
    self.arrowBtn.selected = !self.arrowBtn.selected;
    
    // if this was a user action, send the delegate the appropriate message
    if (userAction)
    {
        if (self.arrowBtn.selected)
        {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)])
            {
                [self.delegate sectionHeaderView:self sectionOpened:self.section];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)])
            {
                [self.delegate sectionHeaderView:self sectionClosed:self.section];
            }
        }
    }
}



@end
