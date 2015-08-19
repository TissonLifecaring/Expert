//
//  SendReportViewController.h
//  SugarNursing
//
//  Created by Ian on 15/5/28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTextView.h"
#import "ReportTextView.h"

@interface SendReportViewController : UIViewController
<
UITextViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate
>

@property (strong, nonatomic) NSString *linkManId;

@property (strong, nonatomic) NSDictionary *reportModel;

@property (strong, nonatomic) ReportTextView *myTextView;
@end
