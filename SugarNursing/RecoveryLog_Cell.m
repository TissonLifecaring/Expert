//
//  RecoveryLog_Cell.m
//  SugarNursing
//
//  Created by Ian on 14-12-23.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "RecoveryLog_Cell.h"

@implementation RecoveryLog_Cell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.contentLabel.frame);
}



@end
