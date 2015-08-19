//
//  RecoveryLogViewController.m
//  SugarNursing
//
//  Created by Ian on 14-11-26.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "RecoveryLogViewController.h"
#import <MBProgressHUD.h>
#import "RecoveryLog_Cell.h"
#import "SendReportViewController.h"
#import "UtilsMacro.h"
#import <RMDateSelectionViewController.h>
#import "UIStoryboard+Storyboards.h"
#import "NoDataLabel.h"

static CGFloat kEstimateCellHeight = 100.0;

static NSString *identifier = @"RecoveryLog_Cell";


@interface RecoveryLogViewController ()<SSPullToRefreshViewDelegate,NSFetchedResultsControllerDelegate,RMDateSelectionViewControllerDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIView *filtrateView;
@property (strong, nonatomic) IBOutlet UIButton *filtrateButton;
@property (weak, nonatomic) IBOutlet UIButton *selectDateButton;

@property (strong, nonatomic) NSDate *selectDate;
@property (strong, nonatomic) NSMutableArray *logTypeArray;

@property (strong, nonatomic) NSFetchedResultsController *fetchController;
@end

@implementation RecoveryLogViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self layoutSubViews];
}

- (void)awakeFromNib
{
    self.selectDate = [NSDate date];
    self.logTypeArray = [@[@"detect",@"exercise",@"drug",@"diet"] mutableCopy];
}

- (void)layoutSubViews
{

    [self.selectDateButton setTitle:[NSString stringWithDateFormatting:@"yyyy-MM-dd" date:[NSDate date]]
                           forState:UIControlStateNormal];
    self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.myTableView
                                                              delegate:self];
}


- (void)goSendAdvice
{
    
    UINavigationController *nav = [[UIStoryboard sendReportStoryboard] instantiateInitialViewController];
    SendReportViewController *vc = nav.viewControllers[0];
    vc.linkManId = self.linkManId;
    
    [self skipToViewController:vc];
}


- (void)configureFetchedResultsController
{
    NSDate *formerDate;
    NSDate *laterDate;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd000000"];
    NSDate *aDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:self.selectDate]];
    //            formerDate = [self timeZoneDate:aDate];
    formerDate = aDate;
    
    laterDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:formerDate];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"linkManId = %@ && time > %@ && time < %@ && logType in %@",self.linkManId,formerDate,laterDate,self.logTypeArray];
    self.fetchController = [RecordLog fetchAllGroupedBy:nil sortedBy:@"time" ascending:NO withPredicate:predicate delegate:self incontext:[CoreDataStack sharedCoreDataStack].context];
}

#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    [hud2 removeFromSuperview];
    hud2 = nil;
}


#pragma mark - NetWorking
- (void)requestRecoveryLogData
{
    [self configureFetchedResultsController];
    
    NSDictionary *parameters = @{@"method":@"queryCureLogTimeLine",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"linkManId":self.linkManId,
                                 @"queryDay":[NSString stringWithDateFormatting:@"yyyyMMdd" date:self.selectDate]
                                 };
    
    
    [GCRequest queryCureLogTimeLineWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        if (!error)
        {
            
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                
                for (RecordLog*record in self.fetchController.fetchedObjects)
                {
                    [record deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                
                
                
                NSArray *cureLogList = responseData[@"cureLogList"];
                for (NSDictionary *cureLog in cureLogList)
                {
                    
                    RecordLog *recordLog = [RecordLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    NSMutableDictionary *cureLogDic_ = [cureLog mutableCopy];
                    [cureLogDic_ dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"time"];
                    [recordLog updateCoreDataForData:cureLogDic_ withKeyPath:nil];
                    recordLog.linkManId = self.linkManId;
                    
                    NSString *logType = cureLog[@"logType"];
                    
                    if ([logType isEqualToString:@"detect"])
                    {
                        
                        NSMutableDictionary *detectDic = [cureLog[@"detectLog"] mutableCopy];
                        [detectDic feelingFormattingToUserForKey:@"selfSense"];
                        [detectDic dataSourceFormattingToUserForKey:@"dataSource"];
                        [detectDic dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"detectTime"];
                        [detectDic dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                        DetectLog *detectLog = [DetectLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [detectLog updateCoreDataForData:detectDic withKeyPath:nil];
                        
                        
                        recordLog.detectLog = detectLog;
                    }
                    else if ([logType isEqualToString:@"exercise"])
                    {
                        
                        NSMutableDictionary *exerciseDic = [cureLog[@"exerciseLog"] mutableCopy];
                        [exerciseDic sportPeriodFormattingToUserForKey:@"sportPeriod"];
                        [exerciseDic dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"sportTime"];
                        [exerciseDic dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                        
                        ExerciseLog *exerciseLog = [ExerciseLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [exerciseLog updateCoreDataForData:exerciseDic withKeyPath:nil];
//                        exerciseLog.sportId = exerciseDic[@"sportId"];
//                        exerciseLog.duration = exerciseDic[@"duration"];
//                        exerciseLog.calorie = exerciseDic[@"calorie"];
                        
                        recordLog.exerciseLog = exerciseLog;
                    }
                    else if ([logType isEqualToString:@"drug"])
                    {
                        
                        NSMutableDictionary *drugDic = [cureLog[@"drugLog"] mutableCopy];
                        [drugDic dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"medicineTime"];
                        [drugDic dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                        
                        DrugLog *drugLog = [DrugLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [drugLog updateCoreDataForData:drugDic withKeyPath:nil];
                        
                        
                        NSMutableOrderedSet *drugSet = [[NSMutableOrderedSet alloc] init];
                        NSArray *medicineList = drugDic[@"medicineList"];
                        for (NSDictionary *dic in medicineList)
                        {
                            NSMutableDictionary *medicine = [dic mutableCopy];
                            [medicine drugUnitFormattingToUserForKey:@"unit"];
                            [medicine drugUsageFormattingToUserForKey:@"usage"];
                            
                            Drug *drug = [Drug createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                            [drug updateCoreDataForData:medicine withKeyPath:nil];
                            [drugSet addObject:drug];
                        }
                        
                        drugLog.drug = drugSet;
                        recordLog.drugLog = drugLog;
                    }
                    else if ([logType isEqualToString:@"diet"])
                    {
                        NSMutableDictionary *dietDic = [cureLog[@"dietLog"] mutableCopy];
                        [dietDic dietPeriodFormattingToUserForKey:@"eatPeriod"];
                        [dietDic dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"eatTime"];
                        [dietDic dateFormattingFromServer:@"yyyyMMddHHmmss" ForKey:@"updateTime"];
                        
                        DietLog *dietLog = [DietLog createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [dietLog updateCoreDataForData:dietDic withKeyPath:nil];
//                        dietLog.eatId = dietDic[@"eatId"];
//                        dietLog.calorie = dietDic[@"calorie"];
                        
                        NSMutableOrderedSet *dietSet = [[NSMutableOrderedSet alloc] init];
                        NSArray *foodList = dietDic[@"foodList"];
                        for (NSDictionary *dic in foodList)
                        {
                            NSMutableDictionary *food = [dic mutableCopy];
                            [food foodUnitFormattingToUserForKey:@"unit"];
                            
                            Diet *diet = [Diet createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                            [diet updateCoreDataForData:food withKeyPath:nil];
                            [dietSet addObject:diet];
                        }
                        
                        dietLog.diet = dietSet;
                        recordLog.dietLog = dietLog;
                    }
                    
                    
                }
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                [self configureFetchedResultsController];
                [self.myTableView reloadData];
                [self configureTableViewFooterView];
                
            }
            else
            {
                hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                [hud show:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }
        else
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
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
    [self requestRecoveryLogData];
}

- (void)pullToRefreshViewDidFinishLoading:(SSPullToRefreshView *)view
{
    
}


#pragma mark - UITableView Delegagte & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchController.fetchedObjects.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kEstimateCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForRecoveryLogCellWithIndexPath:indexPath];
}

- (CGFloat)heightForRecoveryLogCellWithIndexPath:(NSIndexPath *)indexPath
{
    static RecoveryLog_Cell *calCell = nil;
    static dispatch_once_t one;
    dispatch_once(&one, ^{
        calCell = [self.myTableView dequeueReusableCellWithIdentifier:identifier];
        
        calCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), kEstimateCellHeight);
        calCell.contentView.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), kEstimateCellHeight);
        
        [calCell.contentView setNeedsLayout];
        [calCell.contentView layoutIfNeeded];
    });
    
    [self configureRecoveryLogCell:calCell indexPath:indexPath];
    
    
    return [self calculateCellHeightWithCell:calCell];
}

- (CGFloat)calculateCellHeightWithCell:(RecoveryLog_Cell *)calCell
{
    
    [calCell setNeedsLayout];
    [calCell layoutIfNeeded];
    
    CGSize size = [calCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RecoveryLog_Cell *cell = (RecoveryLog_Cell *)[self.myTableView dequeueReusableCellWithIdentifier:identifier];
    [self configureRecoveryLogCell:cell indexPath:indexPath];
    
    return cell;
}


- (void)configureRecoveryLogCell:(RecoveryLog_Cell *)cell indexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    RecordLog *recordLog = [self.fetchController.fetchedObjects objectAtIndex:indexPath.row];
    
    NSString *time = [NSString stringWithDateFormatting:@"HH:mm" date:recordLog.time];
    [cell.dateLabel setText:time];
    
    NSString *logType = recordLog.logType;
    if ([logType isEqualToString:@"detect"])
    {
        
        DetectLog *detectLog = recordLog.detectLog;
        NSString *title = NSLocalizedString(@"detect", nil);
        NSString *content = @"";
        NSString *content2 = @"";
        if (detectLog.glucose && detectLog.glucose.length>0)
        {
            content = [NSString stringWithFormat:@"%@ %@%@ %@",
                       @"Glu",
                       detectLog.glucose,
                       @"mmol/L",
                       detectLog.dataSource];
        }
        
        if (detectLog.hemoglobinef && detectLog.hemoglobinef.length>0)
        {
            
            content2 = [NSString stringWithFormat:@"\n%@ %@%@ %@",
                        @"HbA1c",
                        detectLog.hemoglobinef,
                        @"%",
                        detectLog.dataSource];
        }
        
        content = [content stringByAppendingString:content2];
        
        [cell.titleLabel setText:title];
        [cell.contentLabel setText:content];
    }
    else if ([logType isEqualToString:@"exercise"])
    {
        
        ExerciseLog *exerciseLog = recordLog.exerciseLog;
        NSString *title = NSLocalizedString(@"exercise", nil);
        NSString *content = [NSString stringWithFormat:
                             @"%@ %@ %@%@ %@%@%@",
                             exerciseLog.sportPeriod,
                             exerciseLog.sportName,
                             exerciseLog.duration,
                             NSLocalizedString(@"minute", nil),
                             NSLocalizedString(@"expend", nil),
                             exerciseLog.calorie,
                             NSLocalizedString(@"calorie", nil)];
        [cell.titleLabel setText:title];
        [cell.contentLabel setText:content];
    }
    else if ([logType isEqualToString:@"drug"])
    {
        
        DrugLog *drugLog = recordLog.drugLog;
        NSString *title = NSLocalizedString(@"drug", nil);
        
        NSOrderedSet *medicineList = drugLog.drug;
        NSMutableArray *jointArray = [[NSMutableArray alloc] init];
        for (Drug *drug in medicineList)
        {
            NSString *content = [NSString stringWithFormat:
                                 @"%@ %@ %@ %@%@",
                                 drug.sort,
                                 drug.drug,
                                 drug.usage,
                                 drug.dose,
                                 drug.unit];
            [jointArray addObject:content];
        }
        
        NSString *jointString = [jointArray componentsJoinedByString:@"\n"];
        
        [cell.titleLabel setText:title];
        [cell.contentLabel setText:jointString];
    }
    else if ([logType isEqualToString:@"diet"])
    {
        
        DietLog *dietLog = recordLog.dietLog;
        
        NSString *title = NSLocalizedString(@"diet", nil);
        
        NSOrderedSet *foodList = dietLog.diet;
        NSMutableArray *jointArray = [[NSMutableArray alloc] init];
       
        NSString *firstString;
        if (dietLog.calorie && dietLog.calorie.length>0)
        {
            
            firstString = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"in all intake", nil),dietLog.calorie,NSLocalizedString(@"calorie", nil)];
        }
        else firstString = @"";
        
        [jointArray addObject:firstString];
        for (Diet *diet in foodList)
        {
            
            NSString *content = [NSString stringWithFormat:
                                 @"%@ %@ %@%@ %@%@",
                                 diet.sort,
                                 diet.food,
                                 diet.weight,
                                 diet.unit,
                                 diet.calorie,
                                 NSLocalizedString(@"calorie", nil)];
            [jointArray addObject:content];
        }
        
        NSString *jointString = [jointArray componentsJoinedByString:@"\n"];
        
        [cell.titleLabel setText:title];
        [cell.contentLabel setText:jointString];
    }
    
}

#pragma mark - Other

- (void)configureTableViewFooterView
{
    if (self.fetchController.fetchedObjects.count > 0)
    {
        self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else
    {
        NoDataLabel *label = [[NoDataLabel alloc] initWithFrame:self.myTableView.bounds];
        self.myTableView.tableFooterView = label;
    }
}



- (IBAction)selectDateButtonEvent:(id)sender
{
    [RMDateSelectionViewController setLocalizedTitleForNowButton:NSLocalizedString(@"now", nil)];
    [RMDateSelectionViewController setLocalizedTitleForCancelButton:NSLocalizedString(@"Cancel", nil)];
    [RMDateSelectionViewController setLocalizedTitleForSelectButton:NSLocalizedString(@"Confirm", nil)];
    [RMDateSelectionViewController setLocalizedTitleForDetailButton:@""];
    
    RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
    dateSelectionVC.delegate = self;
    dateSelectionVC.disableBlurEffects = YES;
    dateSelectionVC.disableBouncingWhenShowing = NO;
    dateSelectionVC.disableMotionEffects = NO;
    dateSelectionVC.blurEffectStyle = UIBlurEffectStyleExtraLight;
    dateSelectionVC.datePicker.datePickerMode = UIDatePickerModeDate;
    

    
    UIButton *button = (UIButton *)sender;
    NSString *title = button.currentTitle;
    if (![title isEqualToString:NSLocalizedString(@"By Date", nil)])
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

    [self.selectDateButton setTitle:[NSString stringWithDateFormatting:@"yyyy-MM-dd" date:aDate]
                           forState:UIControlStateNormal];
    self.selectDate = aDate;
    
    [self configureFetchedResultsController];
    [self.myTableView reloadData];
    [self configureTableViewFooterView];
    
    if (self.refreshView)
    {
        [self.refreshView startLoadingAndExpand:YES animated:YES];
    }
}


- (IBAction)filtrateButtonEvent:(id)sender
{
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = self.filtrateView;
    [self.navigationController.view addSubview:hud];
    
    [hud show:YES];
}



- (IBAction)selectFiltrateListButton:(UIButton *)sender
{
    
    UIButton *selectBtn = (UIButton *)sender;
    NSString *type ;
    switch (selectBtn.tag) {
        case 1:
        {
            type = @"detect";
            break;
        }
        case 2:
        {
            type = @"drug";
            break;
        }
        case 3:
        {
            type = @"diet";
            break;
        }
        case 4:
        {
            type = @"exercise";
            break;
        }
        default:
            break;
    }
    if ([selectBtn.currentImage isEqual:[UIImage imageNamed:@"CheckBoxN"]])
    {
        [selectBtn setImage:[UIImage imageNamed:@"CheckBoxY"] forState:UIControlStateNormal];
        
        if (![self.logTypeArray containsObject:type])
        {
            [self.logTypeArray addObject:type];
        }
        
    }
    else
    {
        [selectBtn setImage:[UIImage imageNamed:@"CheckBoxN"] forState:UIControlStateNormal];
        
        if ([self.logTypeArray containsObject:type])
        {
            [self.logTypeArray removeObject:type];
        }
    }
    
}

- (IBAction)selectFiltrateListBottomButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 1)    //取消
    {
        
    }
    else    //确定
    {
        [self configureFetchedResultsController];
        [self.myTableView reloadData];
    }
    
    [hud hide:YES afterDelay:0.2];;
}


- (IBAction)back:(UIStoryboardSegue *)sender
{
    
}

@end
