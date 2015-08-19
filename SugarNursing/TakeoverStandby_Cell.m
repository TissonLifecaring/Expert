//
//  TakeoverStandby_Cell.m
//  SugarNursing
//
//  Created by Ian on 14-12-10.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "TakeoverStandby_Cell.h"
#import "DeviceHelper.h"

@interface TakeoverStandby_Cell()
{
    
    void(^acceptBlock)(TakeoverStandby_Cell *cell);
    void(^refuseBlock)(TakeoverStandby_Cell *cell);
}

@end

@implementation TakeoverStandby_Cell

- (void)awakeFromNib
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.contentLabel.bounds);
}

- (void)configureCellWithContent:(NSAttributedString *)contentString acceptBlock:(void(^)(TakeoverStandby_Cell *cell))block1 refuseBlock:(void(^)(TakeoverStandby_Cell *cell))block2
{
    
    self.contentLabel.attributedText = contentString;
    self.contentLabel.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    
    acceptBlock = block1;
    refuseBlock = block2;
}

- (IBAction)acceptTakeoverButtonEvent:(id)sender
{
    acceptBlock(self);
}

- (IBAction)refuseTakeoverButtonEvent:(id)sender
{
    refuseBlock(self);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
