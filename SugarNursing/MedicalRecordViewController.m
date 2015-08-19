//
//  MedicalRecordViewController.m
//  SugarNursing
//
//  Created by Ian on 15/5/13.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "MedicalRecordViewController.h"
#import "SectionHeaderView.h"
#import "DiseaseInfo_Cell.h"
#import "NoDataLabel.h"
#import "SendReportViewController.h"
#import "UIStoryboard+Storyboards.h"
#import <MWPhotoBrowser.h>
#import <SDWebImageManager.h>

static NSString *SectionHeaderViewIdentifier = @"SectionHeaderViewIdentifier";
static NSString *infoCellIdentifier = @"DiseaseInfo_Cell";

static CGFloat kTableViewMagin = 15;

static CGFloat kInfoCellEstimatedHeight = 500.0;

static CGFloat kHeadCellHeight = 35;


@interface MedicalRecordViewController ()
<
NSFetchedResultsControllerDelegate,
SectionHeaderViewDelegate,
SSPullToRefreshViewDelegate,
DiseaseInfoDelegate,
MWPhotoBrowserDelegate
>
{
    MBProgressHUD *hud;
    NSIndexPath *_selectCellIndexPath;
}

@property (strong, nonatomic) NSMutableArray *selectedArray;



@property (strong, nonatomic) NSFetchedResultsController *fetchController;
@property (strong, nonatomic) NSMutableArray *photos;


@end

@implementation MedicalRecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubViews];
    
    [self configureMedicalFetchedController];
    [self.myTableView reloadData];
    [self configureTableViewFooterView];
}

- (void)initSubViews
{
    
    self.selectedArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.myTableView
                                                              delegate:self];
    
    
    
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"SectionHeaderView" bundle:nil];
    [self.myTableView registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
    
}

- (void)goSendAdvice
{
    
    SendReportViewController *vc = [[UIStoryboard myPatientStoryboard] instantiateViewControllerWithIdentifier:@"SendAdvice"];
    vc.linkManId = self.linkManId;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        [self showViewController:vc sender:nil];
    }
    else
    {
        [self.navigationController pushViewController:vc animated:YES];
    }
}



#pragma mark - Fetch Controller
- (void)configureMedicalFetchedController
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"linkManId = %@",self.linkManId];
    self.fetchController = [MediRecord fetchAllGroupedBy:nil
                                                       sortedBy:@"diagTime"
                                                      ascending:NO
                                                  withPredicate:predicate
                                                       delegate:self
                                                      incontext:[CoreDataStack sharedCoreDataStack].context];
    
    
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
        [self.myTableView reloadData];
        [self configureTableViewFooterView];
}



#pragma mark - RefreshView Delegate
- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self requestMedirecord];
}

- (void)pullToRefreshViewDidFinishLoading:(SSPullToRefreshView *)view
{
    
}



#pragma mark - UITableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchController.fetchedObjects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        if ([self.selectedArray containsObject:indexPath])
        {
            return 1;
        }
        
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeadCellHeight;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return indexPath.row == 0 ? kHeadCellHeight : kInfoCellEstimatedHeight;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForInfoCellWithIndexPath:indexPath];
}


- (CGFloat)heightForInfoCellWithIndexPath:(NSIndexPath *)indexPath
{
    
    static DiseaseInfo_Cell *cell = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        cell = [self.myTableView dequeueReusableCellWithIdentifier:infoCellIdentifier];
        
        cell.contentView.bounds = CGRectMake(0.0f, 0.0f, [self tableViewWidth],
                                             kInfoCellEstimatedHeight);
        cell.bounds = CGRectMake(0.0f, 0.0f, [self tableViewWidth],
                                 kInfoCellEstimatedHeight);
        
    });
    
    cell.collectionView.delegate = nil;
    [cell configureCellWithMediRecord:[self.fetchController.fetchedObjects objectAtIndex:indexPath.section]];
    
    return [self calculateInfoCellHeightWithCell:cell];
}

- (CGFloat)calculateInfoCellHeightWithCell:(DiseaseInfo_Cell *)cell
{
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.myTableView.bounds), CGRectGetHeight(cell.bounds));
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
        SectionHeaderView *headerView = [self.myTableView dequeueReusableHeaderFooterViewWithIdentifier:SectionHeaderViewIdentifier];
        
        [self configureHeaderView:headerView inSection:section];
        
        return  headerView;
}


- (void)configureHeaderView:(SectionHeaderView *)headerView inSection:(NSInteger)section
{
    [headerView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kHeadCellHeight)];
    
    MediRecord *mediRecord = [self.fetchController.fetchedObjects objectAtIndex:section];
    NSString *title = mediRecord.mediName;
    NSString *detailTitle = mediRecord.diagTime;
    detailTitle = [NSString dateFormattingByBeforeFormat:GC_FORMATTER_SECOND toFormat:@"yyyy-MM-dd" string:detailTitle];
    [headerView.titleLabel setText:title];
    [headerView.dateLabel setText:detailTitle];
    
    headerView.arrowBtn.selected = NO;
    headerView.section = section;
    headerView.delegate = self;
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    if ([self.selectedArray containsObject:indexPath])
    {
        headerView.arrowBtn.selected = YES;
    }
    else
    {
        headerView.arrowBtn.selected = NO;
    }
}



- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiseaseInfo_Cell *cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier];
    cell.theDelegate = self;
    [cell configureCellWithMediRecord:self.fetchController.fetchedObjects[indexPath.section]];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}
- (CGFloat)tableViewWidth
{
    return CGRectGetWidth(self.view.bounds) - 2*kTableViewMagin;
}

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

#pragma mark - DiseaseInfoCell Delegate
- (void)diseaseInfoCell:(DiseaseInfo_Cell *)cell didTapImageViewAtIndex:(NSInteger)index
{
    
    NSIndexPath *cellIndexPath = [self.myTableView indexPathForCell:cell];
    _selectCellIndexPath = cellIndexPath;
    
    MediRecord *record = [self.fetchController.fetchedObjects objectAtIndex:cellIndexPath.section];
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:10];
    MWPhoto *photo;
    for (MediAttach *attach in record.mediAttach)
    {
        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:attach.attachPath]];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
        photo = [MWPhoto photoWithImage:image];
//        photo.caption = attach.attachName;
        [photos addObject:photo];
    }
    self.photos = photos;
    
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.displayActionButton = NO;
    photoBrowser.displayNavArrows = NO;
    photoBrowser.displaySelectionButtons = NO;
    photoBrowser.alwaysShowControls = YES;
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableGrid = NO;
    photoBrowser.startOnGrid = NO;
    photoBrowser.enableSwipeToDismiss = YES;
    [photoBrowser setCurrentPhotoIndex:index];
    
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        // conditionly check for any version >= iOS 8
        [self showViewController:photoBrowser sender:nil];
        
    } else
    {
        // iOS 7 or below
        [self.navigationController pushViewController:photoBrowser animated:YES];
    }
}

#pragma mark - MWPhotoBrowser Delegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    MediRecord *record = self.fetchController.fetchedObjects[_selectCellIndexPath.section];
    return record.mediAttach.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    
    MediRecord *record = self.fetchController.fetchedObjects[_selectCellIndexPath.section];
    if (index < record.mediAttach.count)
    {
        return [self.photos objectAtIndex:index];
    }
    return nil;
}


#pragma mark - SectionHeaderViewDelegate

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    
    if (![self.selectedArray containsObject:indexPath])
    {
        [self.selectedArray addObject:indexPath];
        
        [self.myTableView beginUpdates];
        [self.myTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.myTableView endUpdates];
    }
}

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    [self.selectedArray removeObject:indexPath];
    
    [self.myTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}




#pragma mark - NetWorking


- (void)requestMedirecord
{
    
    
    NSDictionary *parameters = @{@"method":@"getMediRecordList",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"linkManId":self.linkManId,
                                 @"mediHistId":@""};
    
    [GCRequest getMediRecordListWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        if (!error)
        {
            
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"linkManId = %@",self.linkManId];
                [MediRecord deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context
                                        predicate:predicate];
                
                
                NSArray *records = responseData[@"mediRecordList"];
                [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSDictionary *record = (NSDictionary *)obj;
                    
                    MediRecord *mediRecord = [MediRecord createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    [mediRecord updateCoreDataForData:record withKeyPath:nil];
                    mediRecord.linkManId = self.linkManId;
                    
                    
                    [self requestMediRecordAttachWithHestId:[NSString stringWithFormat:@"%@",record[@"mediHistId"]]];
                }];
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
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
        
        [self.refreshView finishLoadingAnimated:YES completion:nil];
        
    }];
}

- (void)requestMediRecordAttachWithHestId:(NSString *)mediHistId
{
    
    NSDictionary *parameters = @{@"method":@"getMediRecordAttach",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"mediHistId":mediHistId};
    
    [GCRequest getMediRecordAttachWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        
        if (!error)
        {
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                
                NSInteger mediAttachSize = [responseData[@"mediAttachSize"] integerValue];
                
                
                if (mediAttachSize >0)
                {
                    NSArray *attachArray = responseData[@"mediAttach"];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mediHistId = %@",mediHistId];
                    
                    MediRecord *record = [MediRecord findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context][0];
                    
                    NSMutableOrderedSet *orderSet = [[NSMutableOrderedSet alloc] init];
                    for (NSDictionary *attachDic in attachArray)
                    {
                        
                        MediAttach *attach = [MediAttach createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        [attach updateCoreDataForData:attachDic withKeyPath:nil];
                        
                        [orderSet addObject:attach];
                    }
                    
                    record.mediAttach = orderSet;
                    
                    [[CoreDataStack sharedCoreDataStack] saveContext];
                    
                    
                    //                    NSArray *array  = self.fetchController.fetchedObjects;
                    //
                    //                    for (int i=0; i<array.count; i++)
                    //                    {
                    //                        MediRecord *mediRecord = array[i];
                    //
                    //                        if ([record isEqual:mediRecord])
                    //                        {
                    //                            NSIndexSet *set = [NSIndexSet indexSetWithIndex:i];
                    //                            [self.myTableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
                    //                        }
                    //                    }
                    
                    
                }
            }
            else
            {
                
            }
        }
        else
        {
            
        }
    }];
}


@end
