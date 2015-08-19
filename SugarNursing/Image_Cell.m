//
//  Image_Cell.m
//  SugarNursing
//
//  Created by Ian on 15/5/28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "Image_Cell.h"

@implementation Image_Cell
- (IBAction)deleteButtonTouchEvent:(id)sender
{
    [self.delegate imageCellDidTapDeleteButton:self];
}
- (IBAction)imageButtonTouchEvent:(id)sender
{
    [self.delegate imageCellDidTapImageButton:self];
}

@end
