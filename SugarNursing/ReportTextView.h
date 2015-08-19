//
//  ReportTextView.h
//  SugarNursing
//
//  Created by Ian on 15/6/2.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "MyTextView.h"

@interface ReportTextView : MyTextView

@property (strong, nonatomic) UICollectionView *myCollectionView;


- (void)updateReportViewLayout;


- (void)setDelegate:(id<UITextViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>)delegate;

@end
