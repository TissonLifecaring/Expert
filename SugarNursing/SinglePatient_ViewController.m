//
//  SinglePatient_ViewController.m
//  糖博士
//
//  Created by Ian on 14-11-12.
//  Copyright (c) 2014年 Ian. All rights reserved.
//

#import "SinglePatient_ViewController.h"
#import <RMDateSelectionViewController.h>
#import "DiseaseInfo_Cell.h"
#import <UIImageView+AFNetworking.h>
#import "UtilsMacro.h"
#import "MediRecord.h"
#import "RecoveryLogViewController.h"
#import "ControlEffectViewController.h"
#import <SSPullToRefresh.h>
#import "NoDataLabel.h"
#import "UIStoryboard+Storyboards.h"
#import "ThumbnailImageView.h"
#import "DetectDataCell.h"
#import "SectionHeaderView.h"
#import "SystemVersion.h"
#import "NSString+UserCommon.h"
#import "NSString+dateFormatting.h"
#import "Medicine.h"
#import "NSDictionary+Formatting.h"
#import "MedicalRecordViewController.h"
#import "EffectCell.h"
#import "EffectValueCell.h"
#import "EvaluateCell.h"
#import "DeviceHelper.h"
#import "ControlEffect.h"
#import "EffectList.h"
#import "SendReportViewController.h"
#import "SPKitExample.h"
#import "SPUtil.h"
#import "AppDelegate+UserLogInOut.h"
#import <SDWebImageDownloader.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


typedef NS_ENUM(NSInteger, PushDownViewState)
{
    PushDownViewStateClose = 95537,
    PushDownViewStateOpen
};

typedef NS_ENUM(NSInteger, GCSearchMode)
{
    GCSearchModeByDay = 0,
    GCSearchModeByThreeDay,
    GCSearchModeByWeek,
    GCSearchModeByTwoWeek,
    GCSearchModeByMonth,
    GCSearchModeByTwoMonth,
    GCSearchModeByThreeMonth
};

typedef NS_ENUM(NSInteger, GCType) {
    GCTypeTable = 0,
    GCTypeLine
};

typedef NS_ENUM(NSInteger, GCLineType) {
    GCLineTypeGlucose = 0,
    GCLineTypeHemo
};


typedef NS_ENUM(NSInteger, GCTableType) {
    GCTableTypeEffect = 1001,
    GCTableTypeDetect = 1002
};

typedef NS_ENUM(NSInteger, GCPickerType) {
    GCPickerTypeControlEffect = 0,
    GCPickerTypeGraphPeriod
};


static CGFloat kTableViewMagin = 15;



@interface SinglePatient_ViewController ()
<
NSFetchedResultsControllerDelegate,
RMDateSelectionViewControllerDelegate,
SSPullToRefreshViewDelegate,
SectionHeaderViewDelegate,
MBProgressHUDDelegate
>

{
    MBProgressHUD *hud;
    BOOL timeAscending;
    NSMutableArray *_loadArray;
}




//self.view
@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) IBOutlet UILabel *infoType;
@property (strong, nonatomic) IBOutlet UILabel *infoTime;
@property (strong, nonatomic) IBOutlet UITextView *infoText;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoUnitLabel;

@property (weak, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientGenderLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientAgeLabel;
@property (weak, nonatomic) IBOutlet ThumbnailImageView *patientImageView;
@property (weak, nonatomic) IBOutlet UIButton *patientEffectLabel;
@property (weak, nonatomic) IBOutlet UIButton *chooseDateButton;
@property (weak, nonatomic) IBOutlet UIButton *changeViewButton;

@property (strong, nonatomic) UIPopoverController *popoverController;

@property (nonatomic) AppDelegate *appDelegate;

// Track
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chartViewTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;

@property (strong, nonatomic) NSFetchedResultsController *GfetchController;
@property (strong, nonatomic) NSFetchedResultsController *HfetchController;
@property (strong, nonatomic) NSFetchedResultsController *dietFetchController;
@property (strong, nonatomic) NSFetchedResultsController *drugFetchController;

@property (strong, nonatomic) NSMutableArray *glucoseArray;
@property (strong, nonatomic) NSArray *trackPeriodArray;
@property (strong, nonatomic) NSArray *trackPeriodShortenArray;

@property (assign, nonatomic) CGFloat minValueG;
@property (assign, nonatomic) CGFloat maxValueG;
@property (assign, nonatomic) CGFloat minValueH;
@property (assign, nonatomic) CGFloat maxValueH;

@property (strong, nonatomic) NSDate *selectedDate;

@property (assign) GCLineType lineType;
@property (assign) GCSearchMode searchMode;
@property (assign) GCType viewType;
@property (assign) GCPickerType pickerType;

//Controller Effect
@property (strong, nonatomic) IBOutlet UIView *EffectView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *effectViewTopConstraint;

@property (strong, nonatomic) NSFetchedResultsController *fetchControllerEffect;
@property (strong, nonatomic) SSPullToRefreshView *refreshView;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIView *wrapperView;

@property (strong, nonatomic) IBOutlet UIView *sectionHeaderView;
@property (strong, nonatomic) IBOutlet UILabel *sectionHeaderDetailLabel;


@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSDictionary *countDayDic;;
@property (strong, nonatomic) NSArray *countDayArr;
@property (strong, nonatomic) NSString *countDay;



//SubController
@property (strong, nonatomic) RecoveryLogViewController *subControllerRecoveryLog;
@property (strong, nonatomic) MedicalRecordViewController *subControllerMedicalReocord;
@property (strong, nonatomic) UIView *recoveryLogView;
@property (strong, nonatomic) UIView *medicalRecordView;
@property (strong, nonatomic) NSLayoutConstraint *recoveryViewTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *medicalViewTopConstraint;
@end

@implementation SinglePatient_ViewController
@synthesize popoverController;


//预置数据
- (void)awakeFromNib
{
    
    
    self.countDay = @"7";
    self.dataArray = [NSMutableArray array];
    self.countDayDic = @{@"7":NSLocalizedString(@"Nearest 7 days", nil),
                         @"14":NSLocalizedString(@"Nearest 14 days", nil),
                         @"30":NSLocalizedString(@"Nearest 30 days", nil),
                         @"60":NSLocalizedString(@"Nearest 60 days", nil),
                         };
    
    
    self.countDayArr = @[@"7",@"14",@"30",@"60"];
    
    self.trackPeriodArray = @[NSLocalizedString(@"Select By Three Days", nil),
                              NSLocalizedString(@"Select By Week", nil),
                              NSLocalizedString(@"Select By Two Weeks", nil),
                              NSLocalizedString(@"Select By Month", nil),
                              NSLocalizedString(@"Select By Two Months", nil),
                              NSLocalizedString(@"Select By Three Months", nil)];
    
    self.trackPeriodShortenArray = @[NSLocalizedString(@"Three Days", nil),
                                     NSLocalizedString(@"A Week", nil),
                                     NSLocalizedString(@"Two Weeks", nil),
                                     NSLocalizedString(@"A Month", nil),
                                     NSLocalizedString(@"Two Months", nil),
                                     NSLocalizedString(@"Three Months", nil)];

    
    
    _loadArray = [@[[NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO]] mutableCopy];
    
    self.lineType = GCLineTypeGlucose;
    self.viewType = GCTypeLine;
    self.searchMode = GCSearchModeByMonth;
    self.glucoseArray = [NSMutableArray arrayWithCapacity:20];
    self.selectedDate = [NSDate date];
}

- (void)setAppDelegate:(AppDelegate *)appDelegate
{
    appDelegate = [UIApplication sharedApplication].delegate;
}


- (AppDelegate *)appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.delegate = self;
    
    [self initSubviews];
    
    if (self.isMyPatient)
    {
        [self configureSubviewWithDataSourceType:0];
        [self setupNavigationRightItem];
    }
    
    
    
    
    //设置图表
    [self configureGraph];
    [self configureFetchedController];
    [self reloadTrackView];
    
    
    //控糖成效
    [self configureEffrctFetchController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self requestPersonalInfo];
    
    //防止刚进入页面时autolayout的计算错误 ,把tabBarController.tabBar也计算在内
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}


- (void)initSubviews
{
    self.unitLabel.text = @"mmol/L";
    self.chooseDateButton.layer.cornerRadius = 5.0;
    [self.chooseDateButton setTitle:NSLocalizedString(@"A Month", nil)
                           forState:UIControlStateNormal];
    
    
    
    self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.myTableView
                                                              delegate:self];
    
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTimePicker)];
    [self.sectionHeaderView addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizer:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizer:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDown];
    
    
    
    [self addSubController];
    
    [self.myTabBar setSelectedItem:self.myTabBar.items[0]];
    [self tabBar:self.myTabBar didSelectItem:self.myTabBar.items[0]];
    [self.myTabBar.items[0] setSelectedImage:[UIImage imageNamed:@"DetectH_ON"]];
    [self.myTabBar.items[1] setSelectedImage:[UIImage imageNamed:@"ControlEffect_ON"]];
    [self.myTabBar.items[2] setSelectedImage:[UIImage imageNamed:@"RecoveryLog_ON"]];
    [self.myTabBar.items[3] setSelectedImage:[UIImage imageNamed:@"MedicalHistory_ON"]];
}

- (void)setupNavigationRightItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send Report", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(goSendAdvice)];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - Button Actions
- (void)goSendAdvice
{
    
    UINavigationController *nav = [[UIStoryboard sendReportStoryboard] instantiateInitialViewController];
    SendReportViewController *sendReportVC = nav.viewControllers[0];
    sendReportVC.linkManId = self.linkManId;
    
    [self presentViewController:nav animated:YES completion:nil];
    
}

- (IBAction)goSendMessage:(id)sender
{
    
    if ([[self.appDelegate.ywIMKit.IMCore getLoginService] isCurrentLogined])
    {
        [self openIMWithPersonId:self.patient.otherMappintInfo.otherAccount];
    }
    else
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [AppDelegate loginIMWithSuccessBlock:^{
            [hud hide:YES];
            [self openIMWithPersonId:self.patient.otherMappintInfo.otherAccount];
        } failedBlock:^{
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"Server is busy", nil);
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }];
        
    }
    
}

- (void)openIMWithPersonId:(NSString *)personId
{
    
    YWPerson *person = [[YWPerson alloc] initWithPersonId:personId appKey:IM_USER_KEY];
    
    [[SPKitExample sharedInstance] exampleOpenConversationViewControllerWithPerson:person
                                                          fromNavigationController:self.navigationController];
}


#pragma mark - 添加子控制器(RecoveryLog, MedicalHistory)
- (void)addSubController
{
    
    self.subControllerRecoveryLog = [[UIStoryboard myPatientStoryboard] instantiateViewControllerWithIdentifier:@"RecoveryLogVC"];
    self.subControllerRecoveryLog.linkManId = self.linkManId;
    
    self.subControllerMedicalReocord = [[UIStoryboard myPatientStoryboard] instantiateViewControllerWithIdentifier:@"MedicalRecordVC"];
    self.subControllerMedicalReocord.linkManId = self.linkManId;
    
    
    [self addChildViewController:self.subControllerMedicalReocord];
    [self addChildViewController:self.subControllerRecoveryLog];
    
    self.medicalRecordView = self.subControllerMedicalReocord.view;
    self.recoveryLogView = self.subControllerRecoveryLog.view;
    self.medicalRecordView.translatesAutoresizingMaskIntoConstraints = NO;
    self.medicalRecordView.hidden = YES;
    self.recoveryLogView.translatesAutoresizingMaskIntoConstraints = NO;
    self.recoveryLogView.hidden = YES;
    
//    [self.view addSubview:self.medicalRecordView];
    [self.view insertSubview:self.medicalRecordView atIndex:0];
    [self.view addSubview:self.recoveryLogView];
    

    [self addLayoutConstraintForSubController];
}

#pragma mark 手动添加约束
- (void)addLayoutConstraintForSubController
{
    UITabBar *tabBar = self.myTabBar;
    UIView *medicalView = self.medicalRecordView;
    UIView *recoveryView = self.recoveryLogView;
    
    NSDictionary *bindingDic = NSDictionaryOfVariableBindings(tabBar,medicalView,recoveryView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[medicalView]-(0)-|" options:0 metrics:nil views:bindingDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[recoveryView]-(0)-|" options:0 metrics:nil views:bindingDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[medicalView]-(0)-[tabBar]" options:0 metrics:nil views:bindingDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[recoveryView]-(0)-[tabBar]|" options:0 metrics:nil views:bindingDic]];
    
    self.recoveryViewTopConstraint = [NSLayoutConstraint constraintWithItem:recoveryView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:90];
    [self.view addConstraint:self.recoveryViewTopConstraint];
    
    self.medicalViewTopConstraint = [NSLayoutConstraint constraintWithItem:medicalView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.view addConstraint:self.medicalViewTopConstraint];
    
}



- (void)swipeGestureRecognizer:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp)
    {
        if (self.chartViewTopConstraint.constant != 0 || self.effectViewTopConstraint.constant != 0)
        {
            self.chartViewTopConstraint.constant = 0;
            self.effectViewTopConstraint.constant = 0;
            self.recoveryViewTopConstraint.constant = 0;
            [self.view setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.8 animations:^{
                [self.view layoutIfNeeded];
            }];
        }
    }
    else if (swipe.direction == UISwipeGestureRecognizerDirectionDown)
    {
        
        if (self.chartViewTopConstraint.constant == 0)
        {
            self.chartViewTopConstraint.constant = 90;
            self.effectViewTopConstraint.constant = 90;
            self.recoveryViewTopConstraint.constant = 90;
            [self.view setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.8 animations:^{
                [self.view layoutIfNeeded];
            }];
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.myTableView reloadData];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        
        if (toInterfaceOrientation == UIDeviceOrientationPortrait)
        {
            self.chartViewTopConstraint.constant = 90;
            self.effectViewTopConstraint.constant = 90;
            self.recoveryViewTopConstraint.constant = 90;
        }
        else
        {
            self.chartViewTopConstraint.constant = 0;
            self.effectViewTopConstraint.constant = 0;
            self.recoveryViewTopConstraint.constant = 0;
        }
    }
}

#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    [hud2 removeFromSuperview];
    hud = nil;
}


- (void)configureSubviewWithDataSourceType:(NSInteger)type
{
    [self.patientImageView setImage:[UIImage imageNamed:@"thumbDefault"]];
    
    if (type == 0)
    {
        NSString *headUrl = self.patient.headImageUrl;
        if (headUrl && headUrl.length>0)
        {
            [self.patientImageView setImageWithURL:[NSURL URLWithString:self.patient.headImageUrl] placeholderImage:nil];
        }
        
        NSDate *date = [NSDate dateByString:self.patient.birthday dateFormat:GC_FORMATTER_SECOND];
        self.patientAgeLabel.text = [NSString stringWithFormat:@"%@%@",[NSString ageWithDateOfBirth:date],NSLocalizedString(@"old", nil)];
        
        self.patientGenderLabel.text = self.patient.sex;
        self.patientNameLabel.text = self.patient.userName;
    }
    else
    {
        NSString *headUrl = self.patientInfo.headImageUrl;
        if (headUrl && headUrl.length>0)
        {
            [self.patientImageView setImageWithURL:[NSURL URLWithString:self.patientInfo.headImageUrl] placeholderImage:nil];
        }
        
        NSDate *date = [NSDate dateByString:self.patientInfo.birthday dateFormat:GC_FORMATTER_SECOND];
        self.patientAgeLabel.text = [NSString stringWithFormat:@"%@%@",[NSString ageWithDateOfBirth:date],NSLocalizedString(@"old", nil)];
        
        self.patientGenderLabel.text = self.patientInfo.sex;
        self.patientNameLabel.text = self.patientInfo.userName;
    }
}


#pragma mark - Fetched Controller

- (void)configureGluoseArray;
{
    if (self.glucoseArray)
    {
        [self.glucoseArray removeAllObjects];
    }
    
    
    [self.glucoseArray addObjectsFromArray:self.GfetchController.fetchedObjects];
    [self.glucoseArray addObjectsFromArray:self.dietFetchController.fetchedObjects];
    [self.glucoseArray addObjectsFromArray:self.drugFetchController.fetchedObjects];
    
    NSSortDescriptor *timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:timeAscending];
    [self.glucoseArray sortUsingDescriptors:@[timeSort]];
//    NSLog(@"glucoseArray = %@",self.glucoseArray);
}


- (void)configureEffrctFetchController
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"linkManId = %@",self.linkManId];
    self.fetchControllerEffect = [ControlEffect fetchAllGroupedBy:nil sortedBy:@"linkManId" ascending:YES withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
}





- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    if (controller == self.fetchControllerEffect)
    {
        [self.myTableView reloadData];
    }
    else    
    {
        
    }
}


- (void)configureFetchedController
{
    
    NSPredicate *Gpredicate;
    NSPredicate *Hpredicate;
    NSPredicate *dietPredicate;
    NSPredicate *drugPredicate;
    
    
    NSDate *formerDate;
    NSDate *laterDate;
    
    if (self.searchMode == GCSearchModeByDay)
    {
        
        timeAscending = YES;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd000000"];
        NSDate *aDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:self.selectedDate]];
        //            formerDate = [self timeZoneDate:aDate];
        formerDate = aDate;
        
        laterDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:formerDate];
        
        Gpredicate = [NSPredicate predicateWithFormat:@"logType = %@ && linkManId = %@ && time > %@ && time < %@ && detectLog.glucose != %@ && detectLog.glucose != %@" ,@"detect",self.linkManId,formerDate,laterDate,@"",@"",nil];
        
        Hpredicate = [NSPredicate predicateWithFormat:@"logType = %@ && linkManId = %@ && time > %@ && time < %@ && detectLog.hemoglobinef != %@ && detectLog.hemoglobinef != %@" ,@"detect",self.linkManId,formerDate,laterDate,@"",@"",nil];
        
        drugPredicate = [NSPredicate predicateWithFormat:@"logType = %@ && linkManId = %@ && time > %@ && time < %@ && drugLog.glucose != %@",@"changeDrug",self.linkManId,formerDate,laterDate,@"",nil];
        dietPredicate = [NSPredicate predicateWithFormat:@"logType = %@ && linkManId = %@ && time > %@ && time < %@ && dietLog.glucose != %@",@"dietPoint",self.linkManId,formerDate,laterDate,@"",nil];
    }
    else
    {
        
        NSInteger days = 0;
        
        switch (self.searchMode)
        {
            case GCSearchModeByThreeDay:    days = 3;
                break;
            case GCSearchModeByWeek:        days = 7;
                break;
            case GCSearchModeByTwoWeek:     days = 14;
                break;
            case GCSearchModeByMonth:       days = 30;
                break;
            case GCSearchModeByTwoMonth:    days = 60;
                break;
            case GCSearchModeByThreeMonth:  days = 90;
                break;
            default:
                break;
        }
        
        
        
        timeAscending = NO;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd000000"];
        NSDate *aDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:self.selectedDate]];
        //            laterDate = [self timeZoneDate:aDate];
        laterDate = aDate;
        
        laterDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:laterDate];
        
        
        NSTimeInterval timeInterVal = -1 *days * 24 * 60 * 60;
        formerDate = [NSDate dateWithTimeInterval:timeInterVal sinceDate:laterDate];
        
        
        Gpredicate = [NSPredicate predicateWithFormat:@"logType = %@ && linkManId = %@ && time > %@ && time < %@ && detectLog.glucose != %@ && detectLog.glucose != %@" ,@"detect",self.linkManId,formerDate,laterDate,@"",@"",nil];
        
        Hpredicate = [NSPredicate predicateWithFormat:@"logType = %@ && linkManId = %@ && time > %@ && time < %@ && detectLog.hemoglobinef != %@ && detectLog.hemoglobinef != %@" ,@"detect",self.linkManId,formerDate,laterDate,@"",@"",nil];
        
        
        drugPredicate = [NSPredicate predicateWithFormat:@"logType = %@ && linkManId = %@ && time > %@ && time < %@ && drugLog.glucose != %@",@"changeDrug",self.linkManId,formerDate,laterDate,@"",nil];
        dietPredicate = [NSPredicate predicateWithFormat:@"logType = %@ && linkManId = %@ && time > %@ && time < %@ && dietLog.glucose != %@",@"dietPoint",self.linkManId,formerDate,laterDate,@"",nil];
    }
    
    self.GfetchController = [RecordLog fetchAllGroupedBy:nil sortedBy:@"time" ascending:timeAscending withPredicate:Gpredicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    
    
    
    self.HfetchController = [RecordLog fetchAllGroupedBy:nil sortedBy:@"time" ascending:timeAscending withPredicate:Hpredicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    
    
    self.dietFetchController = [RecordLog fetchAllGroupedBy:nil sortedBy:@"time" ascending:timeAscending withPredicate:dietPredicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    
    self.drugFetchController = [RecordLog fetchAllGroupedBy:nil sortedBy:@"time" ascending:timeAscending withPredicate:drugPredicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
    
    
    [self configureGluoseArray];
}


- (void)reloadTrackView
{
    [self calculateMaxAndMinValue];
    [self.trackerChart reloadGraph];
    [self.detectTableView reloadData];
    [self configureTableViewFooterView];
}


#pragma mark - NetWroking 
- (void)requestPersonalInfo
{
    
    NSDictionary *parameters = @{@"method":@"getPersonalInfo",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"linkManId":self.linkManId};
    
    [GCRequest getLinkmanInfoWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        if (!error)
        {
            NSString *ret_code = responseData[@"ret_code"];
            if ([ret_code isEqualToString:@"0"])
            {
                NSMutableDictionary *infoDic = [responseData[@"linkManInfo"] mutableCopy];
                NSString *linkmanId = infoDic[@"linkManId"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"linkManId = %@",linkmanId];
                
                NSArray *objects = [PatientInfo findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context];
                PatientInfo *info;
                if (objects.count <= 0)
                {
                    info = [PatientInfo createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                else
                {
                    info = objects[0];
                }
                
                [infoDic sexFormattingToUserForKey:@"sex"];
                [info updateCoreDataForData:infoDic withKeyPath:nil];
                
                self.patientInfo = info;
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                
                [self configureSubviewWithDataSourceType:1];
                
            }
            else
            {
                if (!hud)
                {
                    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                    [self.navigationController.view addSubview:hud];
                    [hud show:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];
                    [hud hide:YES afterDelay:HUD_TIME_DELAY];
                }
            }
        }
        else
        {
            if (!hud)
            {
                hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedErrorMesssagesFromError:error];
                [hud show:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }
    }];
}


- (void)requestDetectLine
{
    
    [self configureFetchedController];
    
    
    
    NSMutableDictionary *parameters = [@{@"method":@"queryDetectDetailLine2",
                                         @"sign":@"sign",
                                         @"sessionId":[NSString sessionID],
                                         @"linkManId":self.linkManId
                                         } mutableCopy];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    switch (self.searchMode)
    {
        case GCSearchModeByDay:
        {
            [dateFormatter setDateFormat:@"yyyyMMdd"];
            NSString *dateString = [dateFormatter stringFromDate:self.selectedDate];
            [parameters setValue:dateString forKey:@"queryDay"];
        }
            break;
        case GCSearchModeByThreeDay:
        {
            [parameters setValue:@"3" forKey:@"countDay"];
        }
            break;
        case GCSearchModeByWeek:
        {
            [parameters setValue:@"7" forKey:@"countDay"];
        }
            break;
        case GCSearchModeByTwoWeek:
        {
            [parameters setValue:@"14" forKey:@"countDay"];
        }
            break;
        case GCSearchModeByMonth:
        {
            [parameters setValue:@"30" forKey:@"countDay"];
        }
            break;
        case GCSearchModeByTwoMonth:
        {
            [parameters setValue:@"60" forKey:@"countDay"];
        }
            break;
        case GCSearchModeByThreeMonth:
        {
            [parameters setValue:@"90" forKey:@"countDay"];
        }
            break;
        default:
            break;
    }
    
    
    
    [GCRequest QueryDetectLineWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        if (!error)
        {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"])
            {
                
                // 清除缓存
                for (RecordLog *recordLog in self.GfetchController.fetchedObjects) {
                    [recordLog deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                for (RecordLog *recordLog in self.HfetchController.fetchedObjects) {
                    [recordLog deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                for (RecordLog *recordLog in self.dietFetchController.fetchedObjects) {
                    [recordLog deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                for (RecordLog *recordLog in self.drugFetchController.fetchedObjects) {
                    [recordLog deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                
                
                
                NSArray *detectLogArr = [responseData objectForKey:@"detectLogList"];
                
                for (NSDictionary *detectLogDic in detectLogArr)
                {
                    
                    NSMutableDictionary *detectLogDic_ = [detectLogDic mutableCopy];
                    RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    [detectLogDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"time"];
                    recordLog.linkManId = self.linkManId;
                    [recordLog updateCoreDataForData:detectLogDic_ withKeyPath:nil];
                    
                    
                    DetectLog *detect = [DetectLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *detectDic_ = [[detectLogDic objectForKey:@"detectLog"] mutableCopy];
                    [detectDic_ feelingFormattingToUserForKey:@"selfSense"];
                    [detectDic_ dataSourceFormattingToUserForKey:@"dataSource"];
                    [detectDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"detectTime"];
                    [detectDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                    [detect updateCoreDataForData:detectDic_ withKeyPath:nil];
                    
                    detect.linkManId = self.linkManId;
                    
                    recordLog.detectLog = detect;
                    
                }
                
                NSArray *dietLogArr = [responseData objectForKey:@"dietPointList"];
                for (NSDictionary *dietLogDic in dietLogArr)
                {
                    RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *dietLogDic_ = [dietLogDic mutableCopy];
                    [dietLogDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"time"];
                    [recordLog updateCoreDataForData:dietLogDic_ withKeyPath:nil];
                    
                    DietLog *dietLog = [DietLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *dietDic_ = [[dietLogDic objectForKey:@"dietPoint"] mutableCopy];
                    [dietDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"eatTime"];
                    [dietDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                    [dietDic_ dietPeriodFormattingToUserForKey:@"eatPeriod"];
                    [dietLog updateCoreDataForData:dietDic_ withKeyPath:nil];
                    
                    
                    NSMutableOrderedSet *dietList = [[NSMutableOrderedSet alloc] initWithCapacity:10];
                    for (NSDictionary *foodDic in [dietDic_ objectForKey:@"foodList"]) {
                        NSMutableDictionary *fooDic_ = [foodDic mutableCopy];
                        [fooDic_ foodUnitFormattingToUserForKey:@"unit"];
                        Diet *diet = [Diet createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [diet updateCoreDataForData:fooDic_ withKeyPath:nil];
                        [dietList addObject:diet];
                    }
                    
                    
                    recordLog.dietLog = dietLog;
                    recordLog.linkManId = self.linkManId;
                    dietLog.diet = dietList;
                }
                
                
                NSArray *drugLogArr = [responseData objectForKey:@"changeDrugPointList"];
                for (NSDictionary *drugLogDic in drugLogArr)
                {
                    RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *drugLogDic_ = [drugLogDic mutableCopy];
                    [drugLogDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"time"];
                    [recordLog updateCoreDataForData:drugLogDic_ withKeyPath:nil];
                    
                    DrugLog *drug = [DrugLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *drugDic_ = [[drugLogDic objectForKey:@"changeDrugPoint"] mutableCopy];
                    
                    [drugDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"medicineTime"];
                    [drugDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                    [drug updateCoreDataForData:drugDic_ withKeyPath:nil];
                    
                    NSMutableOrderedSet *newMedicineList = [[NSMutableOrderedSet alloc] initWithCapacity:10];
                    NSMutableOrderedSet *oldMedicineList = [[NSMutableOrderedSet alloc] initWithCapacity:10];
                    for (NSDictionary *newMedicineDic in [[drugLogDic objectForKey:@"changeDrugPoint"] objectForKey:@"newMedicineList"]) {
                        
                        NSMutableDictionary *newMedicineDic_ = [newMedicineDic mutableCopy];
                        [newMedicineDic_ drugUnitFormattingToUserForKey:@"unit"];
                        [newMedicineDic_ drugUsageFormattingToUserForKey:@"usage"];
                        
                        Medicine *medicine = [Medicine createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [medicine updateCoreDataForData:newMedicineDic_ withKeyPath:nil];
                        [newMedicineList addObject:medicine];
                    }
                    
                    
                    for (NSDictionary *oldMedicineDic in [[drugLogDic objectForKey:@"changeDrugPoint"] objectForKey:@"oldMedicineList"]) {
                        
                        NSMutableDictionary *oldMedicineDic_ = [oldMedicineDic mutableCopy];
                        [oldMedicineDic_ drugUnitFormattingToUserForKey:@"unit"];
                        [oldMedicineDic_ drugUsageFormattingToUserForKey:@"usage"];
                        
                        Medicine *medicine = [Medicine createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [medicine updateCoreDataForData:oldMedicineDic_ withKeyPath:nil];
                        [oldMedicineList addObject:medicine];
                    }
                    
                    
                    recordLog.linkManId = self.linkManId;
                    drug.nowMedicineList = newMedicineList;
                    drug.beforeMedicineList = oldMedicineList;
                    recordLog.drugLog = drug;
                }
                
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                [hud hide:YES];
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:ret_code withHUD:YES];;
                [hud show:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }
        else
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [hud show:YES];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
        
        
        if (self.refreshView) {
            [self.refreshView finishLoading];
        }
        
        [self configureFetchedController];
        [self reloadTrackView];
        
    }];
    
}


- (void)requestControlEffectData
{
    
    NSDictionary *parameters = @{@"method":@"queryConclusion",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"sessionToken":[NSString sessionToken],
                                 @"linkManId":self.linkManId,
                                 @"countDay":self.countDay};
    [GCRequest queryConclusionWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        
        if (!error) {
            NSString *ret_code = [responseData valueForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"])
            {
                
                
                for (ControlEffect *controlEffect in self.fetchControllerEffect.fetchedObjects)
                {
                    [controlEffect deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                
                ControlEffect *controlEffect = [ControlEffect createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                [controlEffect updateCoreDataForData:responseData withKeyPath:nil];
                controlEffect.linkManId = self.linkManId;
                
                NSMutableOrderedSet *lists = [[NSMutableOrderedSet alloc] initWithCapacity:10];
                
                EffectList *g3 = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                [g3 updateCoreDataForData:[responseData objectForKey:@"g3"] withKeyPath:nil];
                g3.name = NSLocalizedString(@"Fasting Blood-glucose", nil);
                EffectList *g2 = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                [g2 updateCoreDataForData:[responseData objectForKey:@"g2"] withKeyPath:nil];
                g2.name = NSLocalizedString(@"Postprandial Blood-glucose After 2 hours", nil);
                EffectList *g1 = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                [g1 updateCoreDataForData:[responseData objectForKey:@"g1"] withKeyPath:nil];
                g1.name = NSLocalizedString(@"Postprandial Blood-glucose After 1 hours", nil);
                EffectList *hemoglobin = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                [hemoglobin updateCoreDataForData:[responseData objectForKey:@"hemoglobin"] withKeyPath:nil];
                hemoglobin.name = NSLocalizedString(@"Glycated hemoglobin", nil);
                
                
                [lists addObject:g3];
                [lists addObject:g2];
                [lists addObject:g1];
                [lists addObject:hemoglobin];
                
                controlEffect.effectList = lists;
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
            }
            else
            {
                if ([ret_code isEqualToString:@"-79"])
                {
                    [self resetControlEffectData];
                }
                else
                {
                    if (!hud)
                    {
                        hud = [[MBProgressHUD alloc] initWithView:self.view];
                        [self.view addSubview:hud];
                        [hud show:YES];
                        hud.mode = MBProgressHUDModeText;
                        hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                        [hud hide:YES afterDelay:HUD_TIME_DELAY];
                    }
                }
            }
        }
        else
        {
            if (!hud)
            {
                hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                [hud show:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedErrorMesssagesFromError:error];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
        
            }
        }
        
        
        if (self.refreshView)
        {
            [self.refreshView finishLoading];
        }
    }];
}


#pragma mark - RefreshView Delegate
- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self requestControlEffectData];
}

- (void)pullToRefreshViewDidFinishLoading:(SSPullToRefreshView *)view
{
    
}


- (void)configureGraph
{
    self.trackerChart.labelFont = [UIFont systemFontOfSize:12.0];
    self.trackerChart.colorTop = [UIColor clearColor];
    self.trackerChart.colorBottom = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    self.trackerChart.colorXaxisLabel = [UIColor darkGrayColor];
    self.trackerChart.colorYaxisLabel = [UIColor darkGrayColor];
    self.trackerChart.colorLine = [UIColor colorWithRed:0/255.0 green:116/255.0 blue:217/255.0 alpha:1];
    self.trackerChart.colorPoint = [UIColor colorWithRed:46/255.0 green:204/255.0 blue:64/255.0 alpha:1];
    self.trackerChart.colorBackgroundPopUplabel = [UIColor clearColor];
    self.trackerChart.widthLine = 1.0;
    self.trackerChart.enableTouchReport = YES;
    self.trackerChart.enablePopUpReport = YES;
    self.trackerChart.enableBezierCurve = NO;
    self.trackerChart.enableYAxisLabel = YES;
    self.trackerChart.enableXAxisLabel = YES;
    self.trackerChart.autoScaleYAxis = YES;
    self.trackerChart.alwaysDisplayDots = YES;
    self.trackerChart.sizePoint = 20;
    //    self.trackerChart.alwaysDisplayPopUpLabels = YES;
    self.trackerChart.enableReferenceXAxisLines = YES;
    self.trackerChart.enableReferenceYAxisLines = YES;
    self.trackerChart.enableReferenceAxisFrame = YES;
    self.trackerChart.animationGraphStyle = BEMLineAnimationDraw;
}



- (void)configureTableFootView
{
    if (self.fetchControllerEffect.fetchedObjects.count > 0 )
    {
        self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else
    {
        NoDataLabel *label = [[NoDataLabel alloc] initWithFrame:self.myTableView.bounds];
        self.myTableView.tableFooterView = label;
    }
}


#pragma mark - trackerChart Data Source



- (NSDictionary *)lineGraph:(BEMSimpleLineGraphView *)graph valueAndDotTypeForPointAtIndex:(NSInteger)index
{
    RecordLog *recordLog;
    CGFloat pointValue = 0.0;
    GraphDotType dotType = GraphDotTypeDetect;
    
    switch (self.lineType)
    {
        case GCLineTypeGlucose:
        {
            recordLog = [self.glucoseArray objectAtIndex:index];
            if ([recordLog.logType isEqualToString:@"detect"])
            {
                pointValue = recordLog.detectLog.glucose.floatValue;
                dotType = GraphDotTypeDetect;
            }
            if ([recordLog.logType isEqualToString:@"changeDrug"])
            {
                pointValue = recordLog.drugLog.glucose.floatValue;
                dotType = GraphDotTypeDrug;
            }
            if ([recordLog.logType isEqualToString:@"dietPoint"])
            {
                pointValue = recordLog.dietLog.glucose.floatValue;
                dotType = GraphDotTypeDiet;
            }
            break;
        }
        case GCLineTypeHemo:
            recordLog = [self.HfetchController.fetchedObjects objectAtIndex:index];
            pointValue = recordLog.detectLog.hemoglobinef.floatValue;
            dotType = GraphDotTypeDetect;
            break;
    }
    
    NSDictionary *valueAndType = @{@"value":[NSNumber numberWithFloat:pointValue],
                                   @"type":[NSNumber numberWithInteger:dotType]};
    
    return valueAndType;
}

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph
{
    NSInteger count;
    switch (self.lineType)
    {
        case GCLineTypeGlucose:
            count = self.glucoseArray.count;
            break;
        case GCLineTypeHemo:
            count = self.HfetchController.fetchedObjects.count;
            break;
    }
    
    return count;
}



- (CGFloat)intervalForDayInLineGraph:(BEMSimpleLineGraphView *)graph
{
    return 30;
}



- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView *)graph
{
    switch (self.lineType)
    {
        case GCLineTypeGlucose:
            return self.maxValueG;
            break;
        case GCLineTypeHemo:
            return self.maxValueH;
            break;
        default:
            return 10.0;
    }
}

- (CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView *)graph
{
    switch (self.lineType)
    {
        case GCLineTypeGlucose:
            return self.minValueG;
            break;
        case GCLineTypeHemo:
            return self.minValueH;
            break;
        default:
            return 0.0;
    }
}

#pragma mark - trackerChart Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph
{
    return 0;
}

- (NSInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph
{
    CGFloat max = 0.0;
    CGFloat min = 0.0;
    
    
    switch (self.lineType)
    {
        case GCLineTypeGlucose:
        {
            max = self.maxValueG;
            min = self.minValueG;
        }
            break;
        case GCLineTypeHemo:
        {
            max = self.maxValueH;
            min = self.minValueH;
        }
            break;
    }
    
    NSInteger count;
    if (max == min)
    {
        count = 1;
    }
    else
    {
        count = max - min + 2;
    }
    return count;
}

- (NSDate *)currentDateInLineGraph:(BEMSimpleLineGraphView *)graph
{
    return self.selectedDate;
}


- (NSDate *)lineGraph:(BEMSimpleLineGraphView *)graph dateOnXAxisForIndex:(NSInteger)index
{
    
    RecordLog *recordLog;
    switch (self.lineType)
    {
        case GCLineTypeGlucose:
            if (self.GfetchController.fetchedObjects.count == 0)
            {
                return nil;
            }
            recordLog = [self.glucoseArray objectAtIndex:index];
            break;
        case GCLineTypeHemo:
            if (self.HfetchController.fetchedObjects.count == 0)
            {
                return nil;
            }
            recordLog = [self.HfetchController.fetchedObjects objectAtIndex:index];
            break;
    }
    
    return recordLog.time;
}

- (GraphSearchMode)searchModeInLineGraph:(BEMSimpleLineGraphView *)graph
{
    
    switch (self.searchMode)
    {
        case GCSearchModeByDay:
            return GraphSearchModeByDay;
        case GCSearchModeByThreeDay:
            return GraphSearchModeByThreeDay;
        case GCSearchModeByWeek:
            return GraphSearchModeByWeek;
        case GCSearchModeByTwoWeek:
            return GraphSearchModeByTwoWeek;
        case GCSearchModeByMonth:
            return GraphSearchModeByMonth;
        case GCSearchModeByTwoMonth:
            return GraphSearchModeByTwoMonth;
        case GCSearchModeByThreeMonth:
            return GraphSearchModeByThreeMonth;
    }
}


- (CGFloat)intervalForSecondInLineGraph:(BEMSimpleLineGraphView *)graph
{
    switch (self.searchMode)
    {
        case GCSearchModeByDay:
            return 1.0/60;
        default:
            return 0.001;
    }
}


- (BOOL)noDataLabelEnableForLineGraph:(BEMSimpleLineGraphView *)graph
{
    return YES;
}


- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTapPointAtIndex:(NSInteger)index
{
    [self showInfoViewWithIndex:index];
}


#pragma mark - UITableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == GCTableTypeEffect)
    {
        
        NSInteger sections = 1;
        if (self.fetchControllerEffect.sections.count > 0)
        {
            sections = self.fetchControllerEffect.sections.count;
        }
        
        return sections;
    }
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == GCTableTypeEffect)
    {
        
        if (self.fetchControllerEffect.fetchedObjects.count > 0)
        {
            ControlEffect *controlEffect = self.fetchControllerEffect.fetchedObjects[0];
            return controlEffect.effectList.count+1;
        }
        else
        {
            return 6;
        }

    }
    else
    {
        NSInteger rows;
        switch (self.lineType)
        {
            case GCLineTypeGlucose:
                rows = self.GfetchController.fetchedObjects.count;
                break;
            case GCLineTypeHemo:
                rows = self.HfetchController.fetchedObjects.count;
                break;
        }
        
        return rows;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == GCTableTypeEffect)
    {
        return 0;
    }
    else  return 0;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return indexPath.row == 0 ? kHeadCellHeight : kInfoCellEstimatedHeight;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == GCTableTypeEffect)
    {
        
        if (indexPath.row == 0)
        {
            static EvaluateCell *evaluateCell = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                evaluateCell = [self.myTableView dequeueReusableCellWithIdentifier:@"EvaluateCell"];
            });
            [self configureEvaluateCell:evaluateCell forIndexPath:indexPath];
            return [self calculateHeightForConfiguredSizingCell:evaluateCell];
        }
//        else if (indexPath.row == 1) {
//            return 0;
//        }
        else if (indexPath.row == 5)
        {
            return 60;
        }
        else
        {
            static EffectCell *effectCell = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                effectCell = [self.myTableView dequeueReusableCellWithIdentifier:@"EffectCell"];
            });
            [self configureEffectCell:effectCell forIndexPath:indexPath];
            return [self calculateHeightForConfiguredSizingCell:effectCell];
            
        }
    }
    else
    {
        return 44;
    }
}


- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    sizingCell.bounds = CGRectMake(0.0f, 0.0, CGRectGetWidth(self.myTableView.bounds), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    //    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGFloat height = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)showTimePicker
{
    self.pickerType = GCPickerTypeControlEffect;
    [self.pickerView reloadAllComponents];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.margin = 0;
    hud.customView = self.wrapperView;
    hud.mode = MBProgressHUDModeCustomView;
    [hud show:YES];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == GCTableTypeEffect)
    {
        if (indexPath.row == 0)
        {
            
            
            EvaluateCell *cell = [self.myTableView dequeueReusableCellWithIdentifier:@"EvaluateCell" forIndexPath:indexPath];
            [self configureEvaluateCell:cell forIndexPath:indexPath];
            return cell;
        }
//        else if (indexPath.row == 1)
//        {
//            
//            UITableViewCell *cell = [self.myTableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
//            cell.backgroundColor = UIColorFromRGB(0x2C8CC6);
//            
//            cell.textLabel.text = NSLocalizedString(@"Select Period",nil);
//            cell.textLabel.font = [UIFont systemFontOfSize:[DeviceHelper smallerFontSize]];
//            cell.textLabel.textColor = [UIColor whiteColor];
//            
//            cell.detailTextLabel.text = [self.countDayDic valueForKey:self.countDay];
//            cell.detailTextLabel.font = [UIFont systemFontOfSize:[DeviceHelper smallerFontSize]];
//            cell.detailTextLabel.textColor = [UIColor whiteColor];
//            return cell;
//        }
        else
        {
            EffectCell *cell = [self.myTableView dequeueReusableCellWithIdentifier:@"EffectCell" forIndexPath:indexPath];
            [self configureEffectCell:cell forIndexPath:indexPath];
            return cell;
        }
        
        return nil;

        
    }
    else
    {
        
        static NSString *CellIdentifier = @"DetectCell";
        DetectDataCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configureTableView:tableView withCell:cell atIndexPath:indexPath];
        return cell;
    }
}



- (void)configureTableView:(UITableView *)tableView withCell:(DetectDataCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    RecordLog *recordLog;
    
    switch (self.lineType)
    {
        case GCLineTypeGlucose:
            recordLog = [self.GfetchController.fetchedObjects objectAtIndex:indexPath.row];
            cell.detectValue.text = [NSString stringWithFormat:@"%.1f",[recordLog.detectLog.glucose floatValue]];
            break;
        case GCLineTypeHemo:
            recordLog = [self.HfetchController.fetchedObjects objectAtIndex:indexPath.row];
            cell.detectValue.text = [NSString stringWithFormat:@"%.1f",[recordLog.detectLog.hemoglobinef floatValue]];
            break;
    }
    
    cell.detectDate.text = [NSString stringWithDateFormatting:@"yyyy-MM-dd, EEEE" date:recordLog.time];
    cell.detectTime.text = [NSString stringWithDateFormatting:@"HH:mm" date:recordLog.time];
    
}


- (void)setupConstraintsWithCell:(UITableViewCell *)cell
{
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
}

- (void)configureEvaluateCell:(EvaluateCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    cell.scoreLabel.textColor = UIColorFromRGB(0x377EBC);
    cell.scoreLabel.font = [UIFont systemFontOfSize:[DeviceHelper biggestFontSize]];
    cell.evaluateTextLabel.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
    
    ControlEffect *controlEffect;
    if (self.fetchControllerEffect.fetchedObjects.count > 0) {
        controlEffect = [self.fetchControllerEffect objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    
    cell.scoreLabel.text = NSLocalizedString(@"Curative Effect Evaluation",nil);
    if (controlEffect.conclusionScore)
    {
        cell.scoreLabel.attributedText = [self configureLastLetter:[cell.scoreLabel.text stringByAppendingFormat:@" %@分",controlEffect.conclusionScore]];
    }
    else
    {
        cell.scoreLabel.attributedText = [self configureLastLetter:[cell.scoreLabel.text stringByAppendingFormat:@" %@",@"--"]];
    }
    
    if (controlEffect.conclusionDesc || controlEffect.conclusion)
    {
        cell.evaluateTextLabel.text = [NSString stringWithFormat:@"%@  %@",controlEffect.conclusion?controlEffect.conclusion:@"",controlEffect.conclusionDesc?controlEffect.conclusionDesc:@""];
    }
    else
    {
        cell.evaluateTextLabel.text = NSLocalizedString(@"Cannot get the Evaluation", nil);
    }
    
    
    [self setupConstraintsWithCell:cell];
    
}

- (void)configureEffectCell:(EffectCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    ControlEffect *controlEffect;
    EffectList *effectList;
    if (self.fetchControllerEffect.fetchedObjects.count > 0)
    {
        controlEffect = self.fetchControllerEffect.fetchedObjects[0];
        effectList = [controlEffect.effectList objectAtIndex:indexPath.row-1];
    }
    
    cell.testCount.text = NSLocalizedString(@"DetectionTime",nil);
    if (indexPath.row==4)
    {
        cell.testCount.text = NSLocalizedString(@"Input Time", nil);
    }
    cell.overproofCount.text = NSLocalizedString(@"Exceeding Time",nil);
    cell.maximumValue.text = NSLocalizedString(@"Maximum Value",nil);
    cell.minimumValue.text = NSLocalizedString(@"Minimum Value",nil);
    cell.averageValue.text = NSLocalizedString(@"Average Value",nil);
    
    
    cell.testCount.font = [UIFont systemFontOfSize:[DeviceHelper smallerFontSize]];
    cell.overproofCount.font = [UIFont systemFontOfSize:[DeviceHelper smallerFontSize]];
    cell.maximumValue.font = [UIFont systemFontOfSize:[DeviceHelper smallerFontSize]];
    cell.minimumValue.font = [UIFont systemFontOfSize:[DeviceHelper smallerFontSize]];
    cell.averageValue.font = [UIFont systemFontOfSize:[DeviceHelper smallerFontSize]];
    
    cell.evaluateType.text = effectList.name;
    cell.evaluateType.textColor = UIColorFromRGB(0x498FCD);
    
    
    cell.maximumValue.attributedText = [self configureLastLetter:[cell.maximumValue.text stringByAppendingFormat:@" %@",effectList.max?effectList.max:@"--"]];
    cell.minimumValue.attributedText = [self configureLastLetter:[cell.minimumValue.text stringByAppendingFormat:@" %@",effectList.min?effectList.min:@"--"]];
    cell.averageValue.attributedText = [self configureLastLetter:[cell.averageValue.text stringByAppendingFormat:@" %@",effectList.avg?effectList.avg:@"--"]];
    cell.testCount.attributedText = [self configureLastLetter:[cell.testCount.text stringByAppendingFormat:@" %@",effectList.detectCount?effectList.detectCount:@"--"]];
    cell.overproofCount.attributedText = [self configureLastLetter:[cell.overproofCount.text stringByAppendingFormat:@" %@",effectList.overtopCount?effectList.overtopCount:@"--"]];
    
    [self setupConstraintsWithCell:cell];
    
}


- (NSMutableAttributedString *)configureLastLetter:(NSString *)string
{
    
    NSRange range = [string rangeOfString:@" "];
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:string];
    [aString setAttributes:@{NSForegroundColorAttributeName: [UIColor orangeColor]} range:NSMakeRange(range.location+1, string.length-range.location-1) ];
    return aString;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (CGFloat)tableViewWidth
{
    return CGRectGetWidth(self.view.bounds) - 2*kTableViewMagin;
}


#pragma mark - pickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (self.pickerType)
    {
        case GCPickerTypeControlEffect:
            return self.countDayDic.count;
            break;
        case GCPickerTypeGraphPeriod:
            return self.trackPeriodArray.count;
            break;
        default:
            return 0;
    }
}

#pragma mark - pickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (self.pickerType)
    {
        case GCPickerTypeControlEffect:
            return [self.countDayDic valueForKey:[self.countDayArr objectAtIndex:row]];
            break;
        case GCPickerTypeGraphPeriod:
            return [self.trackPeriodArray objectAtIndex:row];
            break;
        default:
            break;
    }
}

- (IBAction)cancelAndConfirm:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 1001:
        {
            [hud hide:YES];
        }
            break;
        case 1002:
        {
            switch (self.pickerType)
            {
                case GCPickerTypeControlEffect:
                {
                    
                    self.countDay = [self.countDayArr objectAtIndex:[self.pickerView selectedRowInComponent:0]];
                    
                    self.sectionHeaderDetailLabel.text = [self.countDayDic valueForKey:self.countDay];
                    [self.refreshView startLoadingAndExpand:YES animated:YES];
                    
                    [hud hide:YES];
                }
                    break;
                case GCPickerTypeGraphPeriod:
                {
                    switch ([self.pickerView selectedRowInComponent:0])
                    {
                        case 0:
                        {
                            self.searchMode = GCSearchModeByThreeDay;
                        }
                            break;
                        case 1:
                        {
                            self.searchMode = GCSearchModeByWeek;
                        }
                            break;
                        case 2:
                        {
                            self.searchMode = GCSearchModeByTwoWeek;
                        }
                            break;
                        case 3:
                        {
                            self.searchMode = GCSearchModeByMonth;
                        }
                            break;
                        case 4:
                        {
                            self.searchMode = GCSearchModeByTwoMonth;
                        }
                            break;
                        case 5:
                        {
                            self.searchMode = GCSearchModeByThreeMonth;
                        }
                            break;
                        default:
                            break;
                    }
                    
                    
                    self.selectedDate = [NSDate date];
                    
                    NSString *title = self.trackPeriodShortenArray[[self.pickerView selectedRowInComponent:0]];
                    [self.chooseDateButton setTitle:title
                                           forState:UIControlStateNormal];
                    
                    [hud hide:NO];
                    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    [self requestDetectLine];
                    
                }
                    break;
                default:
                    break;
            }
        }
    }
}



#pragma mark - Others

- (void)calculateMaxAndMinValue
{
    CGFloat minValueG = 10.0;
    CGFloat maxValueG = 0.0;
    CGFloat minValueH = 10.0;
    CGFloat maxValueH = 0.0;
    
    for (RecordLog *recordLog in self.glucoseArray)
    {
        CGFloat gluValue= recordLog.detectLog.glucose.floatValue;
        if (gluValue && gluValue > 0)
        {
            if (gluValue > maxValueG)
            {
                maxValueG = gluValue;
            }
            if (gluValue < minValueG)
            {
                minValueG = gluValue;
            }
        }
    }
    
    
    for (RecordLog *recordLog in self.HfetchController.fetchedObjects)
    {
        CGFloat gluValue = recordLog.detectLog.hemoglobinef.floatValue;
        if (gluValue && gluValue >0)
        {
            
            if (gluValue > maxValueH)
            {
                maxValueH = gluValue;
            }
            if (gluValue < minValueH)
            {
                minValueH = gluValue;
            }
        }
    }
    
    if (maxValueG >(NSInteger)maxValueG) maxValueG++;
    if (maxValueH > (NSInteger)maxValueH) maxValueH++;
    
    self.minValueG = (NSInteger)minValueG;
    self.minValueH = (NSInteger)minValueH;
    self.maxValueG = (NSInteger)maxValueG;
    self.maxValueH = (NSInteger)maxValueH;
}

- (IBAction)confirmButtonEvent:(id)sender
{
    [hud hide:YES];
}



- (IBAction)changeViewButtonEvent:(UIButton *)sender
{
    
    if ([sender.currentImage isEqual:[UIImage imageNamed:@"table.png"]])
    {
        [sender setImage:[UIImage imageNamed:@"line.png"] forState:UIControlStateNormal];
        self.viewType = GCTypeLine;
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"table.png"] forState:UIControlStateNormal];
        self.viewType = GCTypeTable;
    }
    
    [self configureGraphAndTableView];
    [self configureFetchedController];
}

- (void)configureGraphAndTableView
{
    
    switch (self.viewType)
    {
        case GCTypeLine:
            self.trackerChart.hidden = NO;
            self.detectTableView.hidden = YES;
            break;
        case GCTypeTable:
            self.trackerChart.hidden = YES;
            self.detectTableView.hidden = NO;
            break;
    }
}

- (void)resetControlEffectData
{
    for (ControlEffect *controlEffect in self.fetchControllerEffect.fetchedObjects)
    {
        [controlEffect deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
    }
    
    ControlEffect *controlEffect = [ControlEffect createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
    controlEffect.linkManId = self.linkManId;
    
    NSMutableOrderedSet *lists = [[NSMutableOrderedSet alloc] initWithCapacity:10];
    
    EffectList *g3 = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
    g3.name = NSLocalizedString(@"Fasting Blood-glucose", nil);
    EffectList *g2 = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
    g2.name = NSLocalizedString(@"Postprandial Blood-glucose After 2 hours", nil);
    EffectList *g1 = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
    g1.name = NSLocalizedString(@"Postprandial Blood-glucose After 1 hours", nil);
    EffectList *hemoglobin = [EffectList createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
    hemoglobin.name = NSLocalizedString(@"Glycated hemoglobin", nil);
    
    
    [lists addObject:g3];
    [lists addObject:g2];
    [lists addObject:g1];
    [lists addObject:hemoglobin];
    
    controlEffect.effectList = lists;
    
    [[CoreDataStack sharedCoreDataStack] saveContext];
}

- (void)configureTableViewFooterView
{
    
    if ( (self.GfetchController.fetchedObjects.count > 0 && self.lineType == GCLineTypeGlucose) ||
         (self.HfetchController.fetchedObjects.count > 0 && self.lineType == GCLineTypeHemo) )
    {
        self.detectTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else
    {
        NoDataLabel *label = [[NoDataLabel alloc] initWithFrame:self.detectTableView.bounds];
        self.detectTableView.tableFooterView = label;
    }
}



- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if ([item isEqual:tabBar.items[0]])
    {
        [self configureFetchedController];
        self.chartView.hidden = NO;
        self.EffectView.hidden = YES;
        self.recoveryLogView.hidden = YES;
        self.medicalRecordView.hidden = YES;
        
        if (![_loadArray[0] boolValue])
        {
            [_loadArray setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:0];
            [self requestDetectLine];
        }
    }
    else if ([item isEqual:tabBar.items[1]])
    {
        self.chartView.hidden = YES;
        self.EffectView.hidden = NO;
        self.recoveryLogView.hidden = YES;
        self.medicalRecordView.hidden = YES;
        
        if (![_loadArray[1] boolValue])
        {
            [_loadArray setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:1];
            [self.refreshView startLoadingAndExpand:YES animated:YES];
        }
    }
    else if ([item isEqual:tabBar.items[2]])
    {
        
        self.chartView.hidden = YES;
        self.EffectView.hidden = YES;
        self.recoveryLogView.hidden = NO;
        self.medicalRecordView.hidden = YES;
        
        
        if (![_loadArray[2] boolValue])
        {
            [_loadArray setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:2];
            [self.subControllerRecoveryLog.refreshView startLoadingAndExpand:YES animated:YES];
        }
    }
    else if ([item isEqual:tabBar.items[3]])
    {
        self.chartView.hidden = YES;
        self.EffectView.hidden = YES;
        self.recoveryLogView.hidden = YES;
        self.medicalRecordView.hidden = NO;
        
        if (![_loadArray[3] boolValue])
        {
            [_loadArray setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:3];
            [self.subControllerMedicalReocord.refreshView startLoadingAndExpand:YES animated:YES];
        }
    }
    
}

- (IBAction)detailConfirmButton:(id)sender
{
    [hud hide:YES afterDelay:0.1];
}

- (IBAction)selectDateButtonEvent:(id)sender
{
    
    [RMDateSelectionViewController setLocalizedTitleForCancelButton:NSLocalizedString(@"Cancel", nil)];
    [RMDateSelectionViewController setLocalizedTitleForNowButton:NSLocalizedString(@"Select Time Span", nil)];
    [RMDateSelectionViewController setLocalizedTitleForSelectButton:NSLocalizedString(@"Select By Day", nil)];
//    [RMDateSelectionViewController setLocalizedTitleForDetailButton:NSLocalizedString(@"Select By Week", nil)];
    
    
    RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
    dateSelectionVC.delegate = self;
    dateSelectionVC.disableBlurEffects = YES;
    dateSelectionVC.disableBouncingWhenShowing = NO;
    dateSelectionVC.disableMotionEffects = NO;
    dateSelectionVC.blurEffectStyle = UIBlurEffectStyleExtraLight;
    dateSelectionVC.datePicker.datePickerMode = UIDatePickerModeDate;
    
    UIButton *button = (UIButton *)sender;
    NSString *title = button.currentTitle;
    if (self.searchMode == GCSearchModeByDay)
    {
        NSDate *date = [NSDate dateByString:title dateFormat:@"yyyy-MM-dd"];
        [dateSelectionVC.datePicker setDate:date];
    }
    
    if ([DeviceHelper phone])
    {
        [dateSelectionVC show];
    }
    else
    {
        [dateSelectionVC showFromViewController:self];
    }
}

- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate
{
    
    
    if ([aDate laterThanDate:[NSDate date]])
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil)
                                                        message:NSLocalizedString(@"Can't be later than today", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    [self.chooseDateButton setTitle:[NSString stringWithDateFormatting:@"yyyy-MM-dd" date:aDate]
                           forState:UIControlStateNormal];
    
    self.selectedDate = aDate;
    self.searchMode = GCSearchModeByDay;
    
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [self requestDetectLine];
}

- (void)dateSelectionViewControllerNowButtonPressed:(RMDateSelectionViewController *)vc
{
    [vc dismiss];
    
//    self.searchMode = GCSearchModeByMonth;
//    
//    self.selectedDate = [NSDate date];
//    [self.chooseDateButton setTitle:NSLocalizedString(@"Select By Month",nil) forState:UIControlStateNormal];
//    
//    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//    [self requestDetectLine];
    
    
    
    self.pickerType = GCPickerTypeGraphPeriod;
    [self.pickerView reloadAllComponents];
    
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.margin = 0;
    hud.customView = self.wrapperView;
    hud.mode = MBProgressHUDModeCustomView;
    [hud show:YES];
}

- (void)dateSelectionViewControllerDetailButtonPressed:(RMDateSelectionViewController *)vc
{
    
    [vc dismiss];
    
    self.searchMode = GCSearchModeByWeek;
    
    self.selectedDate = [NSDate date];
    [self.chooseDateButton setTitle:NSLocalizedString(@"Select By Week",nil) forState:UIControlStateNormal];
    
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [self requestDetectLine];
}


- (IBAction)chartViewSegmentValueChangeEvent:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    if (segment.selectedSegmentIndex == 0)
    {
        self.lineType = GCLineTypeGlucose;
        self.unitLabel.text = @"mmol/L";
    }
    else
    {
        self.lineType = GCLineTypeHemo;
        self.unitLabel.text = @"%";
    }
    
    [self configureFetchedController];
    [self reloadTrackView];
}

- (void)showInfoViewWithIndex:(NSInteger)index
{
    
    self.infoLabel.text = @"";
    self.infoText.text = @"";
    self.infoUnitLabel.hidden = YES;
    
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    RecordLog *recordLog;
    NSString *detailContent = @"";
    
    switch (self.lineType)
    {
        case GCLineTypeGlucose:
            recordLog = [self.glucoseArray objectAtIndex:index];
            break;
        case GCLineTypeHemo:
            recordLog = [self.HfetchController.fetchedObjects objectAtIndex:index];
            break;
    }
    
    if ([recordLog.logType isEqualToString:@"detect"])
    {
        self.infoTime.textAlignment = NSTextAlignmentCenter;
        self.infoUnitLabel.hidden = NO;
        
        self.infoType.text = NSLocalizedString(@"detect", nil);
        NSString *time = [NSString stringWithDateFormatting:@"yyyy-MM-dd HH:mm" date:recordLog.time];
        
        DetectLog *detect = recordLog.detectLog;
        self.infoTime.text = [NSString stringWithFormat:@"%@   %@",time,detect.dataSource];
        
        switch (self.lineType)
        {
            case GCLineTypeGlucose:
                detailContent = [NSString stringWithFormat:@"%.1f",detect.glucose.floatValue];
                self.infoUnitLabel.text = @"mmol/L";
                self.infoLabel.text = detailContent;
                break;
            case GCLineTypeHemo:
                detailContent = [NSString stringWithFormat:@"%.1f", detect.hemoglobinef.floatValue];
                self.infoUnitLabel.text = @"%";
                self.infoLabel.text = detailContent;
            default:
                break;
        }
        
    }
    if ([recordLog.logType isEqualToString:@"changeDrug"])
    {
        self.infoTime.textAlignment = NSTextAlignmentLeft;
        
        self.infoType.text = NSLocalizedString(@"drug", nil);
        self.infoTime.text = [NSString stringWithDateFormatting:@"yyyy-MM-dd HH:mm" date:recordLog.time];
        
        DrugLog *drug = recordLog.drugLog;
        NSMutableArray *nowMedicineArr = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *beforeMedicineArr = [NSMutableArray arrayWithCapacity:10];
        
        for (Medicine *medicine in drug.nowMedicineList)
        {
            NSString *aMedicine = [NSString stringWithFormat:@"%@  %@  %@%@",medicine.drug,medicine.usage,medicine.dose,medicine.unit];
            [nowMedicineArr addObject:aMedicine];
        }
        NSString *nowMedicines =[nowMedicineArr componentsJoinedByString:@"\n"];
        NSString *nowMedicineString = [NSString stringWithFormat:@"%@：\n%@\n",NSLocalizedString(@"now drug",nil),nowMedicines];
        
        for (Medicine *medicine in drug.beforeMedicineList)
        {
            NSString *aMedicine = [NSString stringWithFormat:@"%@  %@  %@%@",medicine.drug,medicine.usage,medicine.dose,medicine.unit];
            [beforeMedicineArr addObject:aMedicine];
        }
        NSString *beforeMedicines = [beforeMedicineArr componentsJoinedByString:@"\n"];
        NSString *beforeMedicineString = [NSString stringWithFormat:@"%@：\n%@",NSLocalizedString(@"before drug",nil),beforeMedicines];
        detailContent = [NSString stringWithFormat:@"%@\n%@",nowMedicineString,beforeMedicineString];
        
        
        if (nowMedicines && nowMedicines.length>0)
        {
            
            UIColor *color = [UIColor colorWithRed:18/255.0 green:103/255.0 blue:193/255.0 alpha:1];
            NSAttributedString *attString;
            NSRange nowMedicaineRange = [detailContent rangeOfString:nowMedicines];
            attString = [self configureAttributedString:detailContent range:NSMakeRange(0, detailContent.length) font:[UIFont systemFontOfSize:18] color:[UIColor blackColor]];
            attString = [self configureAttributedString:attString range:nowMedicaineRange font:[UIFont systemFontOfSize:18] color:color];
            
            if (beforeMedicines && beforeMedicines.length>0)
            {
                NSRange beforeMedicaineRange = [detailContent rangeOfString:beforeMedicines];
                attString = [self configureAttributedString:attString range:beforeMedicaineRange font:[UIFont systemFontOfSize:18] color:color];
            }
            
            [self.infoText setAttributedText:attString];
        }
        
    }
    
    if ([recordLog.logType isEqualToString:@"dietPoint"])
    {
        self.infoTime.textAlignment = NSTextAlignmentLeft;
        
        
        DietLog *dietLog = recordLog.dietLog;
        self.infoType.text = NSLocalizedString(@"diet", nil);
        NSString *time =[NSString stringWithDateFormatting:@"yyyy-MM-dd HH:mm" date:recordLog.time];
        self.infoTime.text = [NSString stringWithFormat:@"%@   %@",time,dietLog.eatPeriod];
        
        NSMutableArray *foodArr = [NSMutableArray arrayWithCapacity:10];
        for (Diet *diet in dietLog.diet)
        {
            NSString *aFood = [NSString stringWithFormat:@"%@  %@  %@%@  %.f%@",diet.sort,diet.food,diet.weight,diet.unit,diet.calorie.floatValue,NSLocalizedString(@"calorie", nil)];
            [foodArr addObject:aFood];
        }
        NSString *dietString =[foodArr componentsJoinedByString:@"\n"];
        detailContent = dietString;
        
        NSString *calorie = [NSString stringWithFormat:@"%.f",dietLog.calorie.floatValue];
        if (dietLog.calorie.floatValue != 0)
        {
            detailContent = [detailContent stringByAppendingFormat:@"\n%@%@%@",NSLocalizedString(@"in all intake", nil),calorie,NSLocalizedString(@"calorie", nil)];
        }
        
        if (dietString && dietString.length>0)
        {
            
            UIColor *color = [UIColor colorWithRed:18/255.0 green:103/255.0 blue:193/255.0 alpha:1];
            NSAttributedString *attString;
            NSRange dietStringRange = [detailContent rangeOfString:dietString];
            attString = [self configureAttributedString:detailContent range:NSMakeRange(0, detailContent.length) font:[UIFont systemFontOfSize:18] color:[UIColor blackColor]];
            attString = [self configureAttributedString:attString range:dietStringRange font:[UIFont systemFontOfSize:18] color:color];
            
            NSRange range = [detailContent rangeOfString:NSLocalizedString(@"in all intake", nil)];
            attString = [self configureAttributedString:attString range:NSMakeRange(range.location+range.length, calorie.length) font:[UIFont systemFontOfSize:18] color:color];
            
            [self.infoText setAttributedText:attString];
        }
        
    }
    
    hud.delegate = self;
    hud.customView = self.infoView;
    hud.margin = 0;
    hud.mode = MBProgressHUDModeCustomView;
    [hud show:YES];
    
    return NSLog(@"Tap on the key point at index: %ld",(long)index);
}

- (NSMutableAttributedString *)configureAttributedString:(id)string range:(NSRange)range font:(UIFont *)font color:(UIColor *)color
{
    
    if ([string isKindOfClass:[NSAttributedString class]])
    {
        NSAttributedString *attString = (NSAttributedString *)string;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attString];
        [attributedString setAttributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:font} range:range];
        return attributedString;
    }
    else if ([string isKindOfClass:[NSString class]])
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:(NSString *)string];
        [attributedString setAttributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:font} range:range];
        return attributedString;
    }
    else
    {
        return nil;
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"goRecoveryLog"])
    {
        RecoveryLogViewController *vc = (RecoveryLogViewController *)[segue destinationViewController];
        vc.linkManId = self.linkManId;
        vc.isMyPatient = self.isMyPatient;
    }
    else if ([segue.identifier isEqualToString:@"goMedicalRecord"])
    {
        MedicalRecordViewController *vc = (MedicalRecordViewController *)[segue destinationViewController];
        vc.linkManId = self.linkManId;
        vc.isMyPatient = self.isMyPatient;
    }
}

- (IBAction)back:(UIStoryboardSegue *)segue
{
    
}


@end
