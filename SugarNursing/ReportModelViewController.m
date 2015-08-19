//
//  ReportModelViewController.m
//  SugarNursing
//
//  Created by Ian on 15/5/29.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "ReportModelViewController.h"
#import "ReportList_Cell.h"
#import "ReportDetailViewController.h"
#import <MBProgressHUD.h>
#import "UtilsMacro.h"

static NSString *identifier = @"ReportList_Cell";
static CGFloat esitimateCellHeight = 130;

@interface ReportModelViewController ()
<
ReportListDelegate,
ReportDetailDelegate
>
{
    BOOL _isEditing;
    MBProgressHUD *_hud;
}


@property (strong, nonatomic) NSMutableArray *sourceArray;

@property (strong, nonatomic) IBOutlet UIView *backupView;

@property (strong, nonatomic) IBOutlet UIButton *backupRecoverButton;

@property (strong, nonatomic) IBOutlet UILabel *backupRecoverTimeLabel;


@end

@implementation ReportModelViewController

- (void)awakeFromNib
{
    [self getReportModelInDocument];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
    self.navigationItem.title = NSLocalizedString(@"Report Model", nil);
    
    [self configureBarItems];
}

- (void)configureBarItems
{
    if (!_isEditing)
    {
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(addButtonEvent)];
        UIBarButtonItem *backupItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Backup", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(backupButtonEvent)];
        self.navigationItem.rightBarButtonItems = @[backupItem,addItem];
    }
    else
    {
        UIBarButtonItem *completeItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Complete", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(completeButtonEvent)];
        self.navigationItem.rightBarButtonItems = @[completeItem];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ReportDetailViewController *vc = segue.destinationViewController;
    vc.delegate = self;
    
    if ([segue.identifier isEqualToString:@"goAdd"])
    {
        vc.navigationItem.title = NSLocalizedString(@"Add Report", nil);
        vc.reportType = GCReportTypeAdd;
    }
    else if ([segue.identifier isEqualToString:@"goDetail"])
    {
        vc.navigationItem.title = NSLocalizedString(@"Report Detail", nil);
        vc.reportType = GCReportTypeDetail;
        vc.reportTitle = [self.sourceArray objectAtIndex:[self.myTableView indexPathForSelectedRow].row][@"title"];
        vc.reportContent = [self.sourceArray objectAtIndex:[self.myTableView indexPathForSelectedRow].row][@"content"];
        vc.reportIndexRow = [self.myTableView indexPathForSelectedRow].row;
    }
}

#pragma mark - UITableView Delegate & DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReportList_Cell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.delegate = self;
    [cell configureCellWithParameter:self.sourceArray[indexPath.row] indexPath:indexPath];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sourceArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return esitimateCellHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static ReportList_Cell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    });
    [sizingCell configureCellWithParameter:self.sourceArray[indexPath.row] indexPath:indexPath];
    return [self calculateCellHeight:sizingCell];
}

- (CGFloat)calculateCellHeight:(ReportList_Cell *)sizingCell
{
    [sizingCell setBounds:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), esitimateCellHeight)];
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSInteger fromRow = sourceIndexPath.row;
    NSInteger toRow = destinationIndexPath.row;
    
    id object = [self.sourceArray objectAtIndex:sourceIndexPath.row];
    
    [self.sourceArray removeObjectAtIndex:fromRow];
    [self.sourceArray insertObject:object atIndex:toRow];
    
    [self updateReportModelArraySeq];
    
    [self saveReportModelEditingToDocument];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.sourceArray removeObjectAtIndex:indexPath.row];
        [self.myTableView beginUpdates];
        [self.myTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.myTableView endUpdates];
        [self updateReportModelArraySeq];
        [self saveReportModelEditingToDocument];
    }
}


#pragma mark - ReportList Cell Delegate
- (void)reportListCellHadBeenLongPress:(ReportList_Cell *)cell
{
    _isEditing = YES;
    [self configureBarItems];
    
    [self.myTableView setEditing:YES animated:YES];
}


#pragma mark - Button Event
- (void)addButtonEvent
{
    if (self.sourceArray.count<40)
    {
        [self performSegueWithIdentifier:@"goAdd" sender:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil) message:NSLocalizedString(@"Report Model Is Not Greater Than 40", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil];
        [alert show];
    }
}

- (void)backupButtonEvent
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *lastBackupTime = [user objectForKey:@"LastBackupTime"];
    if (!lastBackupTime || lastBackupTime.length<=0)
    {
        
        self.backupRecoverTimeLabel.hidden = YES;
        self.backupRecoverButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else
    {
        self.backupRecoverTimeLabel.hidden = NO;
        self.backupRecoverTimeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"New Backup Time", nil),lastBackupTime];
        self.backupRecoverButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0);
    }
    
    _hud = [[MBProgressHUD alloc] init];
    [self.navigationController.view addSubview:_hud];
    _hud.mode = MBProgressHUDModeCustomView;
    _hud.customView = self.backupView;
    _hud.margin = 0;
    [_hud show:YES];
}


- (void)completeButtonEvent
{
    _isEditing = NO;
    [self configureBarItems];
    
    [self.myTableView setEditing:NO animated:YES];
}


#pragma mark - Backup View
- (IBAction)uploadReportModelToCloud:(id)sender
{
    [_hud hide:NO];
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:self.sourceArray options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *templateJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    NSDictionary *parameters = @{@"method":@"adviceTemplateAdd",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"exptId":[NSString exptId],
                                 @"templateJson":templateJson};
    [GCRequest adviceTemplateAddWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
       
        if (!error)
        {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"])
            {
                
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSString *dateString = [NSString stringWithDateFormatting:@"YYYY-MM-dd" date:[NSDate date]];
                [user setObject:dateString forKey:@"LastBackupTime"];
                
                
                _hud.mode = MBProgressHUDModeText;
                _hud.labelText = NSLocalizedString(@"Upload succeed", nil);
                [_hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
            else
            {
                _hud.mode = MBProgressHUDModeText;
                _hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [_hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }
        else
        {
            _hud.mode = MBProgressHUDModeText;
            _hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [_hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
    }];
    
    
}

- (IBAction)recoverReportModelFromCloud:(id)sender
{
    
    [_hud hide:NO];
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
    
    NSDictionary *parameters = @{@"method":@"getAdviceTemplate",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"exptId":[NSString exptId]};
    [GCRequest getAdviceTemplateWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        
        if (!error)
        {
            NSString *ret_code = [responseData objectForKey:@"ret_code"];
            if ([ret_code isEqualToString:@"0"])
            {
                
                NSArray *adviceTemplate = responseData[@"adviceTemplate"];
                self.sourceArray = nil;
                self.sourceArray = [NSMutableArray arrayWithArray:adviceTemplate];
                [self saveReportModelEditingToDocument];
                [self.myTableView reloadData];
                
                _hud.mode = MBProgressHUDModeText;
                _hud.labelText = NSLocalizedString(@"Backup Success", nil);
                [_hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
            else
            {
                _hud.mode = MBProgressHUDModeText;
                _hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [_hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }
        else
        {
            _hud.mode = MBProgressHUDModeText;
            _hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [_hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
    }];
    
}

- (IBAction)backupViewCancelButtonEvent:(id)sender
{
    [_hud hide:YES];
}


#pragma mark - Report Detail Delegate
- (void)reportDidChangeTitle:(NSString *)title content:(NSString *)content indexRow:(NSInteger)row
{
    NSDictionary *dic = @{@"title":title,@"content":content,@"seq":[NSNumber numberWithInteger:row]};
    [self.sourceArray setObject:dic atIndexedSubscript:row];
    
    [self saveReportModelEditingToDocument];
    [self.myTableView reloadData];
}

- (void)reportAddModelWithTitle:(NSString *)title content:(NSString *)content
{
    NSDictionary *dic = @{@"title":title,@"content":content,@"seq":[NSNumber numberWithInteger:0]};
    [self.sourceArray insertObject:dic atIndex:0];
    
    [self saveReportModelEditingToDocument];
    [self.myTableView reloadData];
}

#pragma mark - Save
- (void)updateReportModelArraySeq
{
    for (int i=0; i<self.sourceArray.count; i++)
    {
        NSMutableDictionary *mutableDic = [self.sourceArray[i] mutableCopy];
        [mutableDic setObject:[NSNumber numberWithInteger:i] forKey:@"seq"];
        [self.sourceArray setObject:mutableDic atIndexedSubscript:i];
    }
}


- (void)saveReportModelEditingToDocument
{
    if ([self.sourceArray writeToFile:[self reportModelPath] atomically:YES]) NSLog(@"YES");
    else  NSLog(@"NO");
}


#pragma mark - file Manage
- (void)getReportModelInDocument
{
    NSString *path = [self reportModelPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path])
    {
        
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"ReportModel" ofType:@"plist"];
        NSMutableArray *array = [[NSMutableArray arrayWithContentsOfFile:sourcePath] mutableCopy];
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        BOOL created = [fileManager createFileAtPath:path contents:nil attributes:nil];
        if (created)
        {
            DDLogDebug(@"创建目录成功");
        }
        else
        {
            DDLogDebug(@"创建目录失败");
        }
        [array writeToFile:path atomically:YES];
        
        self.sourceArray = [[NSMutableArray arrayWithArray:array] mutableCopy];
    }
    else
    {
//        NSData *data = [NSData dataWithContentsOfFile:path];
//        self.sourceArray = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
        self.sourceArray = [[NSMutableArray arrayWithContentsOfFile:path] mutableCopy];
    }
    
    [self.sourceArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"seq" ascending:YES]]];
}




- (NSString *)reportModelPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"ReportModel.plist"];
}
@end
