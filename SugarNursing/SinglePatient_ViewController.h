//
//  SinglePatient_ViewController.h
//  糖博士
//
//  Created by Ian on 14-11-12.
//  Copyright (c) 2014年 Ian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BEMSimpleLineGraphView.h>
#import <MBProgressHUD.h>
@class Patient;
@class PatientInfo;

@interface SinglePatient_ViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
UITabBarDelegate,
MBProgressHUDDelegate,
BEMSimpleLineGraphDataSource,
BEMSimpleLineGraphDelegate
>


@property (assign, nonatomic) BOOL isMyPatient;

@property (weak, nonatomic) PatientInfo *patientInfo;
@property (strong, nonatomic) NSString *linkManId;
@property (strong, nonatomic) Patient *patient;


@property (weak, nonatomic) IBOutlet UITabBar *myTabBar;


//图表
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *trackerChart;
@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UITableView *detectTableView;


//用于控糖成效的tableView
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end
