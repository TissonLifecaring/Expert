//
//  ReportDetailViewController.h
//  SugarNursing
//
//  Created by Ian on 15/6/1.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTextView.h"

typedef NS_ENUM(NSInteger, GCReportType)
{
    GCReportTypeAdd = 1,
    GCReportTypeDetail
};

@protocol ReportDetailDelegate <NSObject>

- (void)reportDidChangeTitle:(NSString *)title content:(NSString *)content indexRow:(NSInteger)row;
- (void)reportAddModelWithTitle:(NSString *)title content:(NSString *)content;
@end

@interface ReportDetailViewController : UIViewController

@property (assign, nonatomic) GCReportType reportType;
@property (strong, nonatomic) NSString *reportTitle;
@property (strong, nonatomic) NSString *reportContent;
@property (assign, nonatomic) NSInteger reportIndexRow;

@property (weak, nonatomic) id<ReportDetailDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;

@property (strong, nonatomic) IBOutlet MyTextView *titleTextView;
@property (strong, nonatomic) IBOutlet MyTextView *contentTextView;


@end
