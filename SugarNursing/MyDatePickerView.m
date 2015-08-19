//
//  MyDatePickerView.m
//  test
//
//  Created by Ian on 15/5/6.
//  Copyright (c) 2015年 Ian. All rights reserved.
//

#import "MyDatePickerView.h"


@interface MyDatePickerView ()

@property (strong, nonatomic) UIVisualEffectView *datePickerView;

@property (strong, nonatomic) UIView *barView;


@property (nonatomic, readwrite, strong) UIDatePicker *datePicker;


@end

@implementation MyDatePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
        UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
        
        self.datePickerView = [[UIVisualEffectView alloc] initWithEffect:blur];
        [self.datePickerView setFrame:self.frame];
        [self addSubview:self.datePickerView];
        
        vibrancyView.frame = self.datePickerView.frame;
        [self.datePickerView.contentView addSubview:vibrancyView];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self.datePickerView.contentView setBackgroundColor:[UIColor whiteColor]];
        vibrancyView.backgroundColor = [UIColor clearColor];
        
        
        
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 100, 320, 100)];
        self.datePicker.layer.cornerRadius = 4;
        self.barView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                self.datePicker.frame.origin.y + self.datePicker.frame.size.height/2 -17,
                                                                self.datePicker.frame.size.width,
                                                                34)];
        [self.barView setBackgroundColor:[UIColor colorWithRed:76/255.0 green:172/255.0 blue:239/255.0 alpha:0.5]];
        
        
        [[vibrancyView contentView] addSubview:self.barView];
        [[vibrancyView contentView] addSubview:self.datePicker];
    }
    
    return self;
}

- (void)setupSubViews
{
    
}

@end
