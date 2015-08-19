//
//  SendSuggestViewController.m
//  SugarNursing
//
//  Created by Ian on 14-11-27.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "ReportHistoryViewController.h"
#import "MsgRecord_Cell.h"
#import "AttributedLabel.h"
#import "UtilsMacro.h"
#import <MBProgressHUD.h>
#import <SSPullToRefresh.h>
#import "NoDataLabel.h"
#import "DeviceHelper.h"
#import <UIImageView+AFNetworking.h>
#import <MWPhotoBrowser.h>

static CGFloat cellEstimatedHeight = 200;

static NSString *loadSize = @"15";

static NSString *cellIndentifier = @"MsgRecord_Cell";


@interface ReportHistoryViewController ()
<
SSPullToRefreshViewDelegate,
NSFetchedResultsControllerDelegate,
MBProgressHUDDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
MWPhotoBrowserDelegate
>
{
    MBProgressHUD *hud;
    BOOL _ascending;
}

@property (strong, nonatomic) SSPullToRefreshView *refreshView;

@property (strong, nonatomic) NSMutableArray *serverArray;

@property (strong, nonatomic) NSFetchedResultsController *fetchedController;
@property (assign, nonatomic) BOOL isAll;
@property (assign, nonatomic) BOOL loading;

@property (strong, nonatomic) NSMutableArray *photos;

@end

@implementation ReportHistoryViewController



- (void)viewDidLoad
{   
    [super viewDidLoad];
    self.isAll = YES;
    _ascending = NO;
    
    self.navigationItem.title = NSLocalizedString(@"Report History", nil);
    
    [self configureFetchedController];
    
    [self configureTableViewFooterView];
    
    [self configureNavigationItem];
    
    self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    [self.refreshView startLoadingAndExpand:YES animated:YES];
}

- (void)configureFetchedController
{
    NSPredicate *predica = [NSPredicate predicateWithFormat:@"linkManId = %@",self.linkManId];
    self.fetchedController = [Advice fetchAllGroupedBy:nil
                                              sortedBy:@"adviceTime"
                                             ascending:_ascending
                                         withPredicate:predica
                                              delegate:self
                                             incontext:[CoreDataStack sharedCoreDataStack].context];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self configureFetchedController];
    [self configureTableViewFooterView];
    [self.tableView reloadData];
}

- (void)configureNavigationItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Ascend", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(sortedButtonEvent:)];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - NetWorking
- (void)requestDoctorSuggestsDataWithBeforeTime:(NSString *)beforeTime afterTime:(NSString *)afterTime refresh:(BOOL)refresh
{
    
    self.loading = YES;
    
    NSMutableDictionary *parameters = [@{@"method":@"getDoctorSuggestsWithAttach",
                                         @"sign":@"sign",
                                         @"sessionId":[NSString sessionID],
                                         @"linkManId":self.linkManId,
                                         @"exptId":[NSString exptId],
                                         @"start":refresh ? @"1":[NSString stringWithFormat:@"%ld",(long)self.fetchedController.fetchedObjects.count+1],
                                         @"size":loadSize,
                                         @"order":_ascending ? @"asc" : @"desc"
                                         } mutableCopy];
    
    if (beforeTime && beforeTime.length > 0)
    {   
        [parameters setValue:beforeTime forKey:@"beforeTime"];
    }
    else if (afterTime && afterTime.length > 0)
    {
        [parameters setValue:afterTime forKey:@"afterTime"];
    }
    
    
    [GCRequest getDoctorSuggestsWithAttachWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        self.loading = NO;
        
        if (!error)
        {
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                if (refresh)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"linkManId = %@",self.linkManId];
                    [Advice deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context predicate:predicate];
                }
                
                NSInteger size = [responseData[@"suggestListSize"] integerValue];
                if (size < [loadSize integerValue])
                {
                    self.isAll = YES;
                }
                else
                {
                    self.isAll = NO;
                }
                
                
                NSArray *objects = responseData[@"suggestList"];
                
                [Advice updateAdviceListArray:objects identifierKey:@"adviceId"];
                
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                
                NSInteger total = [responseData[@"total"] integerValue];
                if (total <= self.fetchedController.fetchedObjects.count)
                {
                    self.isAll = YES;
                }
                
                UIBarButtonItem *item = self.navigationItem.rightBarButtonItem;
                if (item)
                {
                    
                    if (_ascending)
                    {
                        [item setTitle:NSLocalizedString(@"Ascend", nil)];
                    }
                    else
                    {
                        [item setTitle:NSLocalizedString(@"Descend", nil)];
                    }
                }
                
                if (hud)
                {
                    [hud hide:YES];
                }
                
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
            hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
        
        
        if (self.refreshView)
        {
            [self.refreshView finishLoading];
        }
    }];
    
    
}


#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    hud2 = nil;
}


#pragma mark - dataOperation
- (void)refreshData
{
    [self requestDoctorSuggestsDataWithBeforeTime:nil afterTime:nil refresh:YES];
}

#pragma mark - RefreshView Delegate
- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self refreshData];
}

#pragma mark - UITalbeView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgRecord_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier
                                                           forIndexPath:indexPath];
    [cell configureCellWithModel:self.fetchedController.fetchedObjects[indexPath.row]
                        delegate:self];
    cell.myCollectView.tag = indexPath.row;
    [cell.myCollectView reloadData];
    return cell;
}

#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellEstimatedHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{
    static MsgRecord_Cell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    });
    [sizingCell configureCellWithModel:self.fetchedController.fetchedObjects[indexPath.row]
                              delegate:self];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(MsgRecord_Cell *)sizingCell
{
    sizingCell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), cellEstimatedHeight);
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds))
    {
        if (!self.isAll && !self.loading)
        {
            Advice *advice = [self.fetchedController.fetchedObjects lastObject];
            [self requestDoctorSuggestsDataWithBeforeTime:advice.adviceTime afterTime:nil refresh:NO];
        }
    }
}



- (void)configureTableViewFooterView
{
    if (self.fetchedController.fetchedObjects.count > 0)
    {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else
    {
        NoDataLabel *label = [[NoDataLabel alloc] initWithFrame:self.tableView.bounds];
        self.tableView.tableFooterView = label;
    }
}


#pragma mark - UICollectView Delegate & DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    Advice *advice = self.fetchedController.fetchedObjects[collectionView.tag];
    return advice.adviceAttach.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MsgAttach_Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:66666];
    
    Advice *advice = self.fetchedController.fetchedObjects[collectionView.tag];
    AdviceAttach *attach = advice.adviceAttach[indexPath.row];
    [imageView setImageWithURL:[NSURL URLWithString:attach.attachPath]
              placeholderImage:[UIImage imageNamed:@"selectImage"]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.photos = [[NSMutableArray alloc] init];
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:10];
    Advice *advice = self.fetchedController.fetchedObjects[collectionView.tag];
    
    MWPhoto *photo;
    for (int i=0 ; i < advice.adviceAttach.count; i++)
    {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:66666];
        UIImage *image = imageView.image;
        
        photo = [MWPhoto photoWithImage:image];
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
    [photoBrowser setCurrentPhotoIndex:indexPath.row];
    
    
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
    return self.photos.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    
    
    return nil;
}


#pragma mark - 
- (void)sortedButtonEvent:(UIBarButtonItem *)item
{
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    if ([item.title isEqualToString:NSLocalizedString(@"Ascend", nil)])
    {
        _ascending = NO;
    }
    else
    {
        _ascending = YES;
    }
    
    [self requestDoctorSuggestsDataWithBeforeTime:nil afterTime:nil refresh:YES];
}


@end
