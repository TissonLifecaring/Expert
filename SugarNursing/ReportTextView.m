//
//  ReportTextView.m
//  SugarNursing
//
//  Created by Ian on 15/6/2.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "ReportTextView.h"
#import "DeviceHelper.h"


static CGFloat kCollectionViewHeight = 100;
static CGFloat kCollectionViewWidth = 300;
static CGFloat kPadding_CollectView_To_TextView = 30;

@implementation ReportTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        self.scrollEnabled = NO;
        
        
        CGRect rect = CGRectMake(0,
                                 200,
                                 kCollectionViewWidth,
                                 kCollectionViewHeight);
        
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 15.0;
        flowLayout.itemSize = CGSizeMake(90.0f, 90.0f);
        self.myCollectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:flowLayout];
        [self addSubview:self.myCollectionView];
        self.myCollectionView.backgroundColor = [UIColor clearColor];
        
        [self setFont:[UIFont systemFontOfSize:[DeviceHelper normalFontSize]]];
        
    }
    
    return self;
}

- (void)setNeedsUpdateConstraints
{
    [super setNeedsUpdateConstraints];
    
    [self.myCollectionView setNeedsUpdateConstraints];
}

- (void)layoutIfNeeded
{
    [super layoutIfNeeded];
    
    [self.myCollectionView layoutIfNeeded];
}

- (void)updateReportViewLayout
{
    CGFloat textHeight = [self sizeThatFits:CGSizeMake(self.bounds.size.width, 10000)].height;
    textHeight += kPadding_CollectView_To_TextView;
    
    if (kCollectionViewHeight + textHeight > self.bounds.size.height)
    {
        CGRect frame = self.frame;
        frame.size.height = kCollectionViewHeight + textHeight;
        [self setFrame:frame];
    }
    else
    {
        
    }
    
    CGRect rect = self.myCollectionView.frame;
    rect.origin.x = CGRectGetWidth(self.bounds)/2 - kCollectionViewWidth/2;
    rect.origin.y = textHeight;
    [UIView animateWithDuration:0.7 animations:^{
        [self.myCollectionView setFrame:rect];
    }];
    
    
    [self setContentSize:CGSizeMake(self.frame.size.width, kCollectionViewHeight + textHeight)];
}

- (void)updateFrame
{
    
    CGFloat textHeight = [self sizeThatFits:CGSizeMake(self.bounds.size.width, 10000)].height;
    textHeight += kPadding_CollectView_To_TextView;
    
    if (kCollectionViewHeight + textHeight > self.bounds.size.height)
    {
        CGRect frame = self.frame;
        frame.size.height = kCollectionViewHeight + textHeight;
        [self setFrame:frame];
    }
    else
    {
        
    }
}


- (void)setDelegate:(id<UITextViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>)delegate
{
    [super setDelegate:delegate];
    [self.myCollectionView setDelegate:delegate];
    [self.myCollectionView setDataSource:delegate];
}

@end
