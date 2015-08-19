//
//  MyPatientsViewController.m
//  SugarNursing
//
//  Created by Ian on 14-11-21.
//  Copyright (c) 2014年 ;. All rights reserved.
//

#import "MyPatientsViewController.h"
#import <REMenu.h>
#import "GCRequest.h"
#import "NSString+UserCommon.h"
#import <UIAlertView+AFNetworking.h>
#import "UtilsMacro.h"
#import <MBProgressHUD.h>
#import <SSPullToRefresh.h>
#import <UIImageView+WebCache.h>
#import "SinglePatient_ViewController.h"
#import "NoDataLabel.h"





static NSString *loadSize = @"20";

@interface MyPatientsViewController ()
<
NSFetchedResultsControllerDelegate,
SSPullToRefreshViewDelegate,
MBProgressHUDDelegate,
UISearchBarDelegate,
REMenuDelegate
>
{
    MBProgressHUD *hud;
    NSMutableArray *_dataArray;       //从数据库获取的数据
    NSMutableArray *_sourceArray;     //用于排序后展示
    NSArray *titleArray;
    
    BOOL _isSearching;
}

@property (strong, nonatomic) SSPullToRefreshView *refreshView;

@property (strong, readwrite, nonatomic) REMenu *menu;
@property (strong, nonatomic) NSPredicate *selectPredicate;
@property (strong, nonatomic) NSString *sortKey;
@property (strong, nonatomic) NSString *relationFlag;
@property (strong, nonatomic) NSString *orderArg;
@property (assign, nonatomic) NSInteger page;

@property (assign, nonatomic) BOOL orderAsc;

@property (assign, nonatomic) BOOL isAll;
@property (assign, nonatomic) BOOL loading;

//@property (strong, nonatomic) UIButton *sectionTitleButton;
@property (strong, nonatomic) NSFetchedResultsController *fetchController;



@property (strong, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *searchBarHeightConstraint;
@property (strong, nonatomic) NSString *searchString;


@end

@implementation MyPatientsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initData];
    
    [self layoutView];
    
    
    [self configureFetchControllerWithAscending:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = [self.mainTableView indexPathForSelectedRow];
    if (indexPath)
    {
        [self.mainTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([LoadedLog needReloadedByKey:@"patient"])
    {
        if (self.refreshView)
        {
            [self.refreshView startLoadingAndExpand:YES animated:YES];
        }
    }
}


- (void)initData
{
    
    self.orderArg = @"boundTime";
    self.orderAsc = NO;
    self.relationFlag = @"00";
    self.selectPredicate = nil;
    self.sortKey = @"servBeginTime";
    self.page = 1;
    
    
    titleArray = [NSArray arrayWithObjects:NSLocalizedString(@"Report Time Descend", nil),
                  NSLocalizedString(@"Report Time Ascend", nil),
                  NSLocalizedString(@"The binding time descending", nil),
                  NSLocalizedString(@"The binding time ascending", nil),
                  NSLocalizedString(@"Age from old to young", nil),
                  NSLocalizedString(@"Age from young to old", nil),
                  NSLocalizedString(@"Only takeover", nil),
                  NSLocalizedString(@"Only Hosting", nil),
                  nil];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.mainTableView reloadData];
    [self configureTableViewFooterView];
}

- (void)configureFetchControllerWithAscending:(BOOL)ascending
{
    self.fetchController = [Patient fetchAllGroupedBy:nil
                                             sortedBy:self.sortKey
                                            ascending:ascending
                                        withPredicate:self.selectPredicate
                                             delegate:self
                                            incontext:[CoreDataStack sharedCoreDataStack].context];
    _dataArray = nil;
    _dataArray = [self.fetchController.fetchedObjects mutableCopy];
}


- (void)requestPatientListDataWithRefresh:(BOOL)refresh
{
    self.loading = YES;
    
    
    NSMutableDictionary *parameters = [@{@"method":@"queryPatientList",
                                         @"sessionToken":[NSString sessionToken],
                                         @"sessionId":[NSString sessionID],
                                         @"exptId":[NSString exptId],
                                         @"relationFlag":self.relationFlag,
                                         @"orderArg":self.orderArg,
                                         @"order":self.orderAsc ? @"asc" : @"desc",
                                         @"start":refresh ? @"1" : [NSString stringWithFormat:@"%ld",self.page],
                                         @"size":loadSize,
                                         @"sign":@"sign"} mutableCopy];
    
    if (self.searchString && self.searchString.length >0)
    {
        [parameters setObject:self.searchString forKey:@"searchString"];
    }
    
    [GCRequest queryPatientListWithParameters:parameters block:^(NSDictionary *responseData, NSError *error)
    {
        
        self.loading = NO;
        
        if (!error)
        {
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                self.page++;
                
                NSInteger start = [responseData[@"start"] integerValue];
                NSInteger size = [responseData[@"patientsSize"] integerValue];
                NSInteger total = [responseData[@"total"] integerValue];
                if (size + start > total)
                {
                    self.isAll = YES;
                }
                else
                {
                    self.isAll = NO;
                }
                
                
                NSArray *patients = responseData[@"patients"];
                if (refresh)
                {
                    [Patient deleteAllEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                }
                
                [self savePatientToCoreData:patients];
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                [self configureFetchControllerWithAscending:self.orderAsc];
                [self.mainTableView reloadData];
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
            hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
            [hud show:YES];
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

- (void)layoutView
{
    
    
    self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.mainTableView
                                                              delegate:self];
    
    
    [self configureBarItems];
}

- (void)configureBarItems
{
    if (_isSearching)
    {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelSearchItemEvent)];
        self.navigationItem.rightBarButtonItems = @[cancelItem];
    }
    else
    {
        
        UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Search", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(searchItemEvent)];
        UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sort", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(sortItemEvent)];
        self.navigationItem.rightBarButtonItems = @[sortItem,searchItem];
    }
}

- (void)savePatientToCoreData:(NSArray *)patients;
{
    
    for (NSDictionary *patient in patients)
    {
        NSMutableDictionary *patientDic = [patient mutableCopy];
        [patientDic patientStateFormattingToUserForKey:@"patientStat"];
        [patientDic dateFormattingByFormat:@"yyyyMMdd" toFormat:@"yyyy-MM-dd" key:@"servStartTime"];
        [patientDic sexFormattingToUserForKey:@"sex"];
        
        NSString *linkManId = patient[@"linkManId"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"linkManId = %@",linkManId];
        NSArray *objects = [Patient findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context];
        
        //openIM账号
        NSDictionary *otherIMDic = patient[@"otherMapping"][0];
        
        
        if (!objects || objects.count<=0)
        {
            Patient *patient = [Patient createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
            [patient updateCoreDataForData:patientDic withKeyPath:nil];
            
            
            OtherMappingInfo *mappingInfo = [OtherMappingInfo createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
            [mappingInfo updateCoreDataForData:otherIMDic withKeyPath:nil];
            patient.otherMappintInfo = mappingInfo;
        }
        else
        {
            Patient *patient = objects[0];
            [patient updateCoreDataForData:patientDic withKeyPath:nil];
            [patient.otherMappintInfo updateCoreDataForData:otherIMDic withKeyPath:nil];
        }
        
    }
}

#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    hud2 = nil;
}



#pragma mark - RefreshView Delegate
- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self refreshData];
}


- (void)refreshData
{
    [self requestPatientListDataWithRefresh:_isSearching ? NO : YES];
}

- (void)pullToRefreshViewDidFinishLoading:(SSPullToRefreshView *)view
{
    
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds))
    {
        if (!self.isAll && !self.loading)
        {
            [self requestPatientListDataWithRefresh:NO];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_isSearching)
    {
        if ([self.mySearchBar isFirstResponder])
        {
            [self.mySearchBar resignFirstResponder];
        }
    }
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"MyPatientsCell";
    MyPatientsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell indexPath:indexPath];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"goSinglePatient" sender:nil];
}



- (void)configureCell:(MyPatientsCell *)cell indexPath:(NSIndexPath *)indexPath
{
    Patient *patient = [_dataArray objectAtIndex:indexPath.row];
    
    if (patient.headImageUrl && patient.headImageUrl.length > 0)
    {
        [cell.patientImageView sd_setImageWithURL:[NSURL URLWithString:patient.headImageUrl]
                              placeholderImage:[UIImage imageNamed:@"thumbDefault"]];
    }
    else
    {
        [cell.patientImageView setImage:[UIImage imageNamed:@"thumbDefault"]];
    }
    
    [cell.nameLabel setText:patient.userName];
    [cell.genderLabel setText:patient.sex];
    [cell.stateLabel setText:patient.patientStat];
    
    
    
    
    NSDate *date = [NSDate dateByString:patient.birthday dateFormat:@"yyyyMMddHHmmss"];
    cell.ageLabel.text = [NSString stringWithFormat:@"%@%@",[NSString ageWithDateOfBirth:date],NSLocalizedString(@"old2", nil)];
    
    
    NSDate *reportDate = [NSDate dateByString:patient.nextReportTime dateFormat:@"yyyyMMddHHmmss"];
    NSString *remainDay = [NSString numberOfDaysBetweenFirstDay:[NSDate date] endDay:reportDate];
    
    
    
    NSString *dateLabelString = @"";
    if ([DeviceHelper deviceLanguage] == GCLanguageEnglish)
    {
        dateLabelString = [NSString stringWithFormat:@"%@ days from next report",remainDay];
    }
    else
    {
        dateLabelString = [NSString stringWithFormat:@"%@%@%@",
                           NSLocalizedString(@"from next report", nil),
                           remainDay,
                           NSLocalizedString(@"day", nil)];
    }
    
    NSRange range = [dateLabelString rangeOfString:remainDay];
    NSAttributedString *attString = [self configureAttributedString:dateLabelString range:range];
    [cell.bindingDateLabel setAttributedText:attString];
}


#pragma mark - Sort Method
- (void)remenuItemDidSelectRow:(NSInteger)row
{
    
    [self sortListWithSelectRow:row];
    
    [self.menu close];
}




- (void)sortListWithSelectRow:(NSInteger)row
{
    switch (row)
    {
        case 0:
        {
            self.orderArg = @"reportTime";
            self.orderAsc = NO;
            self.relationFlag = @"00";
            self.selectPredicate = nil;
            self.sortKey = @"nextReportTime";
        }
            break;
        case 1:
        {
            self.orderArg = @"reportTime";
            self.orderAsc = YES;
            self.relationFlag = @"00";
            self.selectPredicate = nil;
            self.sortKey = @"nextReportTime";
        }
            break;
        case 2:
        {
            self.orderArg = @"boundTime";
            self.orderAsc = NO;
            self.relationFlag = @"00";
            self.selectPredicate = nil;
            self.sortKey = @"servBeginTime";
        }
            break;
        case 3:
        {
            self.orderArg = @"boundTime";
            self.orderAsc = YES;
            self.relationFlag = @"00";
            self.selectPredicate = nil;
            self.sortKey = @"servBeginTime";
        }
            break;
        case 4:
        {
            self.orderArg = @"age";
            self.orderAsc = YES;
            self.relationFlag = @"00";
            self.selectPredicate = nil;
            self.sortKey = @"birthday";
        }
            break;
        case 5:
        {
            self.orderArg = @"age";
            self.orderAsc = NO;
            self.relationFlag = @"00";
            self.selectPredicate = nil;
            self.sortKey = @"birthday";
        }
            break;
        case 6:
        {
            self.selectPredicate = [NSPredicate predicateWithFormat:@"patientStat = %@",NSLocalizedString(@"takeover", nil)];
            self.orderArg = @"boundTime";
            self.orderAsc = YES;
            self.relationFlag = @"02";
            self.sortKey = @"servBeginTime";
        }
            break;
        case 7:
        {
            self.selectPredicate = [NSPredicate predicateWithFormat:@"patientStat = %@",NSLocalizedString(@"trusteeship", nil)];
            self.orderArg = @"boundTime";
            self.orderAsc = YES;
            self.relationFlag = @"01";
            self.sortKey = @"servBeginTime";
        }
            break;
        default:
            break;
    }
    
    self.isAll = YES;
    self.page = 1;
    [self.refreshView startLoadingAndExpand:YES animated:YES];
}



#pragma mark - UISearchBar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.searchString = searchBar.text;
    [searchBar resignFirstResponder];
    
    self.selectPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"mobilePhone CONTAINS[d] '%@' || userName CONTAINS[d] '%@'",self.searchString,self.searchString]];
    
    self.page = 1;
    self.orderArg = @"boundTime";
    self.orderAsc = NO;
    self.sortKey = @"servBeginTime";
    
    
    [self configureFetchControllerWithAscending:NO];
    [self.mainTableView reloadData];
    [self configureTableViewFooterView];
    
    [self.refreshView startLoadingAndExpand:YES animated:YES];
}


#pragma mark - Item Event
- (void)searchItemEvent
{
    if (self.menu)
    {
        [self.menu close];
    }
    
    if (!_isSearching)
    {
        _isSearching = YES;
        
        self.searchBarHeightConstraint.constant = 44;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.7 animations:^{
            [self.view layoutIfNeeded];
        }completion:^(BOOL finished) {
            [self configureBarItems];
        }];
        
        [_dataArray removeAllObjects];
        [self.mainTableView reloadData];
        [self configureTableViewFooterView];
        
        
//        UISearchBar *searchBar = [[UISearchBar alloc] init];
//        self.navigationItem.titleView = searchBar;
    }
}

- (void)cancelSearchItemEvent
{
    if ([self.mySearchBar isFirstResponder])
    {
        [self.mySearchBar resignFirstResponder];
    }
    
    if (_isSearching)
    {
        _isSearching = NO;
        
        
        self.searchBarHeightConstraint.constant = 0;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.7 animations:^{
            [self.view layoutIfNeeded];
        }completion:^(BOOL finished) {
            [self configureBarItems];
        }];
        
        self.searchString = @"";
        self.orderArg = @"boundTime";
        self.orderAsc = NO;
        self.relationFlag = @"00";
        self.selectPredicate = nil;
        self.sortKey = @"servBeginTime";
        [self configureFetchControllerWithAscending:self.orderAsc];
        [self.mainTableView reloadData];
        [self configureTableViewFooterView];
    }
}

- (void)sortItemEvent
{
    if (!self.menu && !_isSearching)
    {
        NSMutableArray *itemArray = [NSMutableArray array];
        
        for (int i=0 ; i<titleArray.count; i++)
        {
            REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:[titleArray objectAtIndex:i]
                                                            subtitle:nil
                                                               image:nil
                                                    highlightedImage:nil
                                                              action:^(REMenuItem *item) {
                                                                  [self remenuItemDidSelectRow:i];
                                                              }];
            
            
            [itemArray addObject:homeItem];
        }
        
        self.menu = [[REMenu alloc] initWithItems:itemArray];
        self.menu.delegate = self;
        
        [self.menu showFromNavigationController:self.navigationController];
    }
}

- (void)remenuDidClose:(REMenu *)remenu
{
    self.menu.delegate = nil;
    self.menu = nil;
}



#pragma mark - Others

- (NSMutableAttributedString *)configureAttributedString:(id)string range:(NSRange)range
{
    if ([string isKindOfClass:[NSAttributedString class]])
    {
        NSAttributedString *attString = (NSAttributedString *)string;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attString];
        [attributedString setAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]} range:range];
        return attributedString;
    }
    else if ([string isKindOfClass:[NSString class]])
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:(NSString *)string];
        [attributedString setAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]} range:range];
        return attributedString;
    }
    else
    {
        return nil;
    }
}


- (void)configureTableViewFooterView
{
    if (_dataArray.count > 0)
    {
        self.mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else
    {
        NoDataLabel *label = [[NoDataLabel alloc] initWithFrame:self.mainTableView.bounds];
        self.mainTableView.tableFooterView = label;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //跳转隐藏tabBar
    UIViewController *vc = [segue destinationViewController];
    vc.hidesBottomBarWhenPushed = YES;
    vc.tabBarController.tabBar.hidden = YES;
    
    if ([segue.identifier isEqualToString:@"goSinglePatient"])
    {
        
        SinglePatient_ViewController *single = [segue destinationViewController];
        
        Patient *patient = [_dataArray objectAtIndex:[self.mainTableView indexPathForSelectedRow].row];
        single.linkManId = patient.linkManId;
        single.isMyPatient = YES;
        single.patient = patient;
    }
}


- (IBAction)back:(UIStoryboardSegue *)sender
{
    
}


@end
