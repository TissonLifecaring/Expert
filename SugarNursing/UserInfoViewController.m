//
//  UserInfoViewController.m
//  SugarNursing
//
//  Created by Ian on 14-11-17.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UIViewController+Notifications.h"
#import <MBProgressHUD.h>
#import "CustomLabel.h"
#import "Department.h"
#import "NSManagedObject+Savers.h"
#import "UtilsMacro.h"
#import "MyTextView.h"
#import "NSDictionary+Configure.h"
#import "ThumbnailImageView.h"
#import "NSString+ParseData.h"
#import "NotificationName.h"
#import "RootViewController.h"


static CGFloat kDefaultCellParameterLeftMagin = 130;
static CGFloat kDefaultCellParameterRightMagin = 40;

static CGFloat kTitleLabelRightMagin = 10;
static CGFloat kTerritoryCellTextViewMagin = 10;


static CGFloat kDefaultCellUserImageLengthOfSize = 40;    //用户图片宽高

static CGFloat kCellHeight = 50;
static CGFloat kRowCount = 10;

static CGFloat kAnimationDurantion = 1;

static CGFloat kTerritoryMinHeight = 70;

static NSString *identifier_gender = @"GenderCell";
static NSString *identifier_actualName = @"ActualNameCell";
static NSString *identifier_date = @"DateOfBirthCell";
static NSString *identifier_hospital = @"HospitalCell";
static NSString *identifier_rank = @"RankCell";
static NSString *identifier_id = @"IDCell";
static NSString *identifier_department = @"DepartmentsCell";
static NSString *identifier_userImage = @"UserImageCell";
static NSString *identifier_center = @"ServiceCenterCell";
static NSString *identifier_territory = @"TerritoryCell";


typedef NS_ENUM(NSInteger, GCUserInfoState)
{
    GCUserInfoStateNormal = 0,
    GCUserInfoStateApprove = 1
};

typedef enum {
    TableViewCellBaseItemTagTitleLabel = 20001,
    TableViewCellBaseItemTagUserView,
    TableViewCellBaseItemTagSecondView
}TableViewCellBaseItemTag;


typedef NS_ENUM(NSInteger, TableViewCellRow){
    TableViewCellRowUserImage = 0,
    TableViewCellRowActualName = 1,
    TableViewCellRowGender = 2,
    TableViewCellRowDateOfBirth = 3,
    TableViewCellRowRank = 4,
    TableViewCellRowDepartments = 5,
    TableViewCellRowHospital = 6,
    TableViewCellRowID = 7,
    TableViewCellRowServiceCenter = 8,
    TableViewCellRowTerritory = 9
};


@interface UserInfoViewController ()
<
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
MBProgressHUDDelegate
>
{
    MBProgressHUD *hud;
    
    
    NSArray *_departCom0Array;
    NSArray *_departCom1Array;
    Department *_selectDepart;
    
    
    CGSize territoryTextViewSize;
    
    NSMutableDictionary *_parameters;
}

@property (assign, nonatomic) GCUserInfoState userInfoState;

@property (nonatomic, strong) ThumbnailImageView *userHeadImageView;
@property (nonatomic, strong) UITextField *userNameTextField;
@property (nonatomic, strong) UITextField *userHospitalTextField;
@property (nonatomic, strong) CustomLabel *userSexLabel;
@property (nonatomic, strong) CustomLabel *userBirthdayLabel;
@property (nonatomic, strong) CustomLabel *userLevelLabel;
@property (nonatomic, strong) CustomLabel *userDepartmentLabel;
@property (nonatomic, strong) CustomLabel *userIdLabel;
@property (nonatomic, strong) CustomLabel *userCenterLabel;
@property (nonatomic, strong) MyTextView *userSkilledTextView;

@property (nonatomic, assign) BOOL editing;

@property (nonatomic, strong) UIView *activeView;
@property (nonatomic, strong) UIActionSheet *sheet;
@property (nonatomic, strong) TemporaryInfo *info;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIPopoverController *popoverController;



@property (strong, nonatomic) NSString *thumbnailURLString;
@property (strong, nonatomic) UIImage *thumbnailImage;
@end

@implementation UserInfoViewController
@synthesize mainTableView,popoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubview];
    
    [self updatePresentUserInfoData];
    
    [self.mainTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    //防止刚进入页面时autolayout的计算错误 ,把tabBarController.tabBar也计算在内
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}



- (void)initSubview
{
    self.userSexLabel = [[CustomLabel alloc] init];
    self.userIdLabel = [[CustomLabel alloc] init];
    self.userDepartmentLabel = [[CustomLabel alloc] init];
    self.userCenterLabel = [[CustomLabel alloc] init];
    self.userBirthdayLabel = [[CustomLabel alloc] init];
    self.userLevelLabel = [[CustomLabel alloc] init];
    self.userNameTextField = [[UITextField alloc] init];
    self.userHospitalTextField = [[UITextField alloc] init];
    self.userSkilledTextView = [[MyTextView alloc] init];
    self.userHeadImageView = [[ThumbnailImageView alloc] init];
}


- (void)setupNavigationBarRightItemWithType:(NSInteger)type
{
    if (type == 0)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else if (type == 1)
    {
        self.navigationItem.rightBarButtonItem = nil;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil)
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(editButtonEvent:)];
        self.navigationItem.rightBarButtonItem = item;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(selectUploadRequestCellEvent)];
        self.navigationItem.rightBarButtonItem = item;
    }
}

- (void)keyBoardWillShow:(NSNotification *)notification
{
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.mainTableView.contentInset = contentInsets;
    self.mainTableView.scrollIndicatorInsets = contentInsets;
    
    
    
    CGRect textFieldRect = [self.mainTableView convertRect:self.activeView.bounds fromView:self.activeView];
    [self.mainTableView scrollRectToVisible:textFieldRect animated:YES];
}

- (void)keyBoardWillHide:(NSNotification *)notification
{
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    self.mainTableView.contentInset = inset;
    self.mainTableView.scrollIndicatorInsets = inset;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.mainTableView reloadData];
}


#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud2
{
    hud2 = nil;
}


#pragma mark - UITextField & UITextView    Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeView = textField;
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.activeView = textView;
    return YES;
}


#pragma mark - UIPickerView DataSource & Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if (component == 0)
    {
        return _departCom0Array.count;
    }
    else
    {
        return _departCom1Array.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (component == 0)
    {
        
        Department *department = _departCom0Array[row];
        
        [self.departmentsPicker selectRow:0 inComponent:1 animated:YES];
        return department.departmentName;
    }
    else
    {
        Department *department;
        
        if (row < _departCom1Array.count)
        {
            department = _departCom1Array[row];
        }
        
        return department.departmentName;
    }
}




- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (component == 0)
    {
        
        if (row >= _departCom0Array.count)
        {
            return;
        }
        
        
        Department *department = _departCom0Array[row];
        NSString *parentId = department.departmentId;
        
        _departCom1Array = [Department findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentId = %@",parentId]
                                                  inContext:[CoreDataStack sharedCoreDataStack].context];
        
        [pickerView selectRow:0 inComponent:1 animated:NO];
        [self.departmentsPicker reloadComponent:1];
    }
    else
    {
        
        if (row >= _departCom1Array.count)
        {
            return;
        }
        
    }
}


#pragma mark - UITableView Delegate & DataSource
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    if (self.activeView && [self.activeView isFirstResponder] && scrollView == self.mainTableView)
    {
        [self.activeView resignFirstResponder];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kRowCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == TableViewCellRowTerritory)
    {
        
        
        CGSize textSize;
        textSize = [self sizeWithString:self.info.skilled
                                   font:[UIFont systemFontOfSize:[DeviceHelper normalFontSize]]
                                maxSize:CGSizeMake(CGRectGetWidth(self.view.bounds) - kTitleLabelRightMagin - kDefaultCellParameterLeftMagin/2 - (self.userSkilledTextView.textContainerInset.top + self.userSkilledTextView.textContainerInset.bottom),
                                                   0)];
        
        
        if (textSize.height < kTerritoryMinHeight)
        {
            textSize.height = kTerritoryMinHeight;
        }
        
        CGFloat terrytoryHeight = kCellHeight + textSize.height + kTerritoryCellTextViewMagin;
        
        return terrytoryHeight + 20;
        
    }
    else
    {
        
        return kCellHeight;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (self.userInfoState == GCUserInfoStateApprove)
        {
            return 35;
        }
    }
    
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (section == 0)
    {
        
        if (self.userInfoState == GCUserInfoStateApprove)
        {
            
            CustomLabel *label = [[CustomLabel alloc] init];
            [label setText:NSLocalizedString(@"Your information is under review", nil)];
            [label setTextColor:[UIColor redColor]];
            return label;
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.activeView && [self.activeView isFirstResponder])
    {
        [self.activeView resignFirstResponder];
        return;
    }
    
    if (indexPath.section == 0)
    {
        
        if (self.editing)
        {
            switch (indexPath.row)
            {
                case TableViewCellRowGender:        [self selectGenderCellEvent];    break;
                case TableViewCellRowDateOfBirth:   [self selectDateOfBirthCellEvent];   break;
                case TableViewCellRowDepartments:   [self selectDepartmentsCellEvent];   break;
                case TableViewCellRowUserImage:     [self selectUserImageCellEvent];     break;
                case TableViewCellRowActualName:    [self.userNameTextField becomeFirstResponder];   break;
                case TableViewCellRowHospital:      [self.userHospitalTextField becomeFirstResponder]; break;
                case TableViewCellRowTerritory:     [self.userSkilledTextView becomeFirstResponder]; break;
                default:
                    break;
            }
        }
    }
    else
    {
        
        [self selectUploadRequestCellEvent];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    switch (indexPath.row)
    {
        case TableViewCellRowUserImage:   cell = [self setupUserImageCell];
            break;
        case TableViewCellRowActualName:
            cell = [self configureTextFieldCellWithText:self.info.exptName indexPath:indexPath];
            break;
        case TableViewCellRowHospital:
            cell = [self configureTextFieldCellWithText:self.info.hospital indexPath:indexPath];
            break;
        case TableViewCellRowGender:
            cell = [self configureLabelCellWithLabelText:self.info.sex indexPath:indexPath];
            break;
        case TableViewCellRowDateOfBirth:
            cell = [self configureLabelCellWithLabelText:self.info.birthday indexPath:indexPath];
            break;
        case TableViewCellRowRank:
            cell = [self configureLabelCellWithLabelText:self.info.expertLevel indexPath:indexPath];
            break;
        case TableViewCellRowID:
            cell = [self configureLabelCellWithLabelText:self.info.exptId indexPath:indexPath];
            break;
        case TableViewCellRowTerritory:
            cell = [self setupTerritoryCellWithLabelText:self.info.skilled];
            break;
            
        case TableViewCellRowDepartments: {
            NSString *departName = [Department getDepartmentNameByID:self.info.departmentId];
            cell = [self configureLabelCellWithLabelText:departName indexPath:indexPath];
        }
            break;
            
        case TableViewCellRowServiceCenter:{
            NSString *centerName = [ServCenter getCenterNameByID:self.info.centerId];
            cell=[self configureLabelCellWithLabelText:centerName indexPath:indexPath];
        }
            break;
            
        default:
            break;
    }
    
    
    return cell;
}

#pragma mark - 自定义Cell创建


#pragma mark 头像cell
- (UITableViewCell *)setupUserImageCell
{
        UITableViewCell *cell = [self.mainTableView dequeueReusableCellWithIdentifier:identifier_userImage];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier_userImage];
       
        if (self.info.headimageUrl && self.info.headimageUrl.length>0)
        {
            [self.userHeadImageView setImageWithURL:[NSURL URLWithString:self.info.headimageUrl] placeholderImage:nil];
        }
        else
        {
            [self.userHeadImageView setImage:[UIImage imageNamed:@"thumbDefault"]];
        }
        
        [self.userHeadImageView setTag:TableViewCellBaseItemTagUserView];
        
        
        [cell addSubview:self.userHeadImageView];
        
        [self.userHeadImageView setFrame:
         CGRectMake(CGRectGetWidth(self.view.bounds) - kDefaultCellParameterRightMagin - kDefaultCellUserImageLengthOfSize,
                    (kCellHeight - kDefaultCellUserImageLengthOfSize)/2,
                    kDefaultCellUserImageLengthOfSize,
                    kDefaultCellUserImageLengthOfSize)];
        
        self.userHeadImageView.layer.borderWidth = 3.0f;
        self.userHeadImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.userHeadImageView.layer.cornerRadius = self.userHeadImageView.frame.size.width/2;
        self.userHeadImageView.clipsToBounds = YES;
        
        [self setTitleItemWithCell:cell indexPath:[NSIndexPath indexPathForRow:TableViewCellRowUserImage inSection:0]];
    }
    
    
    
    
    return cell;
}


#pragma mark 普通label Cell
- (UITableViewCell *)configureLabelCellWithLabelText:(NSString *)labelText indexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    UILabel *label;
    
    switch (indexPath.row)
    {
        case TableViewCellRowGender:
            identifier = identifier_gender;
            label = self.userSexLabel;
            break;
        case TableViewCellRowDateOfBirth:
            identifier = identifier_date;
            label = self.userBirthdayLabel;
            break;
        case TableViewCellRowRank:
            identifier = identifier_rank;
            label = self.userLevelLabel;
            break;
        case TableViewCellRowDepartments:
            identifier = identifier_department;
            label = self.userDepartmentLabel;
            break;
        case TableViewCellRowID:
            identifier = identifier_id;
            label = self.userIdLabel;
            break;
        case TableViewCellRowServiceCenter:
            identifier = identifier_center;
            label = self.userCenterLabel;
            break;
        default:
            break;
    }
    
    
    UITableViewCell *cell = [self.mainTableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [label setFont:[UIFont systemFontOfSize:[DeviceHelper normalFontSize]]];
        [label setText:labelText];
        [label setTag:TableViewCellBaseItemTagUserView];
        label.textAlignment = NSTextAlignmentLeft;
        [label setTextColor:[UIColor lightGrayColor]];
        [cell addSubview:label];
        
        [label setFrame:CGRectMake(kDefaultCellParameterLeftMagin*1.5,
                                   kCellHeight/4,
                                   CGRectGetWidth(self.view.bounds)-kDefaultCellParameterLeftMagin*1.5,
                                   kCellHeight/2)];
        
        
        
        //添加标题
        [self setTitleItemWithCell:cell indexPath:indexPath];
    }
    
    if (self.editing)
    {
        if (indexPath.row != TableViewCellRowID && indexPath.row != TableViewCellRowServiceCenter && indexPath.row != TableViewCellRowRank)
        {
            [label setTextColor:[UIColor orangeColor]];
        }
        else
        {
            [label setTextColor:[UIColor lightGrayColor]];
        }
    }
    else
    {
        [label setTextColor:[UIColor lightGrayColor]];
    }
    
    return cell;
}

#pragma mark 普通TextField Cell
- (UITableViewCell *)configureTextFieldCellWithText:(NSString *)text indexPath:(NSIndexPath *)indexPath
{
    
    NSString *identifier;
    UITextField *textField;
    
    if (indexPath.row == TableViewCellRowActualName)
    {
        identifier = identifier_actualName;
        textField = self.userNameTextField;
    }
    else if (indexPath.row == TableViewCellRowHospital)
    {
        identifier = identifier_hospital;
        textField = self.userHospitalTextField;
    }
    
    UITableViewCell *cell = [self.mainTableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        
        textField.delegate = self;
        textField.userInteractionEnabled = NO;
        textField.font = [UIFont systemFontOfSize:[DeviceHelper normalFontSize]];
        [textField setTextColor:[UIColor lightGrayColor]];
        [textField setText:text];
        
        
        [textField setFrame:CGRectMake(kDefaultCellParameterLeftMagin*1.5,
                                                    kCellHeight/4,
                                                    CGRectGetWidth(self.view.bounds)/2,
                                                    kCellHeight/2)];
        
        
        [textField setTag:TableViewCellBaseItemTagUserView];
        [cell addSubview:textField];
        
        
        //添加标题
        [self setTitleItemWithCell:cell indexPath:indexPath];
    }
    
    if (self.editing)
    {
        textField.textColor = [UIColor orangeColor];
    }
    else
    {
        textField.textColor = [UIColor lightGrayColor];
    }
    
    return cell;
}



#pragma mark  擅长领域cell
- (UITableViewCell *)setupTerritoryCellWithLabelText:(NSString *)labelText
{
    UITableViewCell *cell = [self.mainTableView dequeueReusableCellWithIdentifier:identifier_territory];
    
    if (!cell)
    {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier_territory];
        
        self.userSkilledTextView = [[MyTextView alloc] init];
        self.userSkilledTextView.textColor = [UIColor lightGrayColor];
        self.userSkilledTextView.userInteractionEnabled = NO;
        self.userSkilledTextView.showsVerticalScrollIndicator = NO;
        self.userSkilledTextView.delegate = self;
        [self.userSkilledTextView setTag:TableViewCellBaseItemTagUserView];
        [self.userSkilledTextView setText:labelText];
        //        NSInteger fonSize = [[[NSUserDefaults standardUserDefaults] objectForKey:@"USER_FONSIZE"] integerValue];
        [self.userSkilledTextView setFont:[UIFont systemFontOfSize:[DeviceHelper normalFontSize]]];
        [cell addSubview:self.userSkilledTextView];
        
        self.activeView = self.userSkilledTextView;
        
        CGFloat maxWidth = CGRectGetWidth(self.view.bounds) - kTitleLabelRightMagin - kDefaultCellParameterLeftMagin/2 - (self.userSkilledTextView.textContainerInset.left + self.userSkilledTextView.textContainerInset.right);
        CGSize textSize;
        textSize = [self sizeWithString:labelText
                                   font:[UIFont systemFontOfSize:[DeviceHelper normalFontSize]]
                                maxSize:CGSizeMake(maxWidth, 0)];
        
        textSize.height += self.userSkilledTextView.textContainerInset.top + self.userSkilledTextView.textContainerInset.bottom;
        
        if (textSize.height < kTerritoryMinHeight)
        {
            textSize.height = kTerritoryMinHeight;
            textSize.width  = maxWidth;
        }
        
        NSLog(@"%f,%f,%f,%f",self.userSkilledTextView.textContainerInset.top,
              self.userSkilledTextView.textContainerInset.left,
              self.userSkilledTextView.textContainerInset.bottom,
              self.userSkilledTextView.textContainerInset.right);
        [self.userSkilledTextView setFrame:CGRectMake(kDefaultCellParameterLeftMagin/2,
                                                      kCellHeight,
                                                      textSize.width,
                                                      textSize.height)];
        NSLog(@"%f",self.userSkilledTextView.contentSize.height);
        //添加标题
        [self setTitleItemWithCell:cell indexPath:[NSIndexPath indexPathForRow:TableViewCellRowTerritory inSection:0]];
    }
    
    
//    if (self.editing)
//    {
//        
//        self.userSkilledTextView.textColor = [UIColor orangeColor];
        self.userSkilledTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.userSkilledTextView.layer.borderWidth = 1.0;
//    }
//    else
//    {
//        self.userSkilledTextView.textColor = [UIColor lightGrayColor];
//        self.userSkilledTextView.layer.borderWidth = 0;
//    }

    
    return cell;
}


#pragma mark 设置标题label
- (void)setTitleItemWithCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    
    CustomLabel *titleLabel = [[CustomLabel alloc] init];
    [titleLabel setFrame:CGRectMake(0,
                                    0,
                                    kDefaultCellParameterLeftMagin - kTitleLabelRightMagin,
                                    kCellHeight)];
    [titleLabel setText:[self titleWithIndexPath:indexPath]];
    [titleLabel setTextAlignment:NSTextAlignmentRight];
    [cell addSubview:titleLabel];
}


#pragma mark - Cell点击事件


#pragma mark 用户头像
- (void)selectUserImageCellEvent
{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        
        self.sheet = [[UIActionSheet alloc] initWithTitle:@"选择图片"
                                                 delegate:self
                                        cancelButtonTitle:nil
                                   destructiveButtonTitle:@"取消"
                                        otherButtonTitles:@"拍照",@"从相册选取",nil];
        self.sheet.tag = 101;
    }
    else
    {
        self.sheet = [[UIActionSheet alloc] initWithTitle:@"选择图片"
                                                 delegate:self
                                        cancelButtonTitle:nil
                                   destructiveButtonTitle:@"取消"
                                        otherButtonTitles:@"从相册选取",nil];
        self.sheet.tag = 102;
    }
    
    self.sheet.delegate = self;
    
    [self.sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if (self.sheet.tag == 101)
    {
        
        switch (buttonIndex)
        {
            case 1:
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 2:
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            default:
                self.imagePickerController = nil;
                break;
        }
    }
    else
    {
        if (buttonIndex == 1)
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else
        {
            self.imagePickerController = nil;
        }
    }
    
    if (buttonIndex>0)
    {
        self.imagePickerController = picker;
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (self.imagePickerController)
    {
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        }
        else
        {
            
            if (self.popoverController)
            {
                [self.popoverController dismissPopoverAnimated:NO];
                self.popoverController = nil;
            }
            
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePickerController];
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        }
    }

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        self.thumbnailImage = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    
    
    
    [self uploadThumbnailToServer];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark 性别
- (void)selectGenderCellEvent
{
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud setMode:MBProgressHUDModeCustomView];
    [hud setCustomView:self.genderPicker];
    
    [hud show:YES];
}

- (IBAction)selectGender:(UIButton *)sender
{
    
    [self.userSexLabel setText:sender.currentTitle];
    
    [hud hide:YES];
}

#pragma mark 出生日期
- (void)selectDateOfBirthCellEvent
{
    
    if ([DeviceHelper phone])
    {
        
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud setMode:MBProgressHUDModeCustomView];
        hud.customView = self.datePickerView;
        hud.margin = 0;
        [hud show:YES];
    }
    else
    {
        if (self.popoverController)
        {
            [self.popoverController dismissPopoverAnimated:NO];
            self.popoverController = nil;
        }
        
        UIViewController* popoverContent = [[UIViewController alloc] init];
        popoverContent.view = self.datePickerView;
        
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.popoverController.popoverContentSize = self.datePickerView.bounds.size;
        [self.popoverController presentPopoverFromRect:CGRectMake(CGRectGetWidth(self.view.bounds)/4, 3.5*kCellHeight + 20, 0, 0) inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionUp
                                              animated:YES];
    }
}

- (IBAction)datePickerViewButtonEvnet:(UIButton *)sender
{
    if (sender.tag == 0)
    {
        
    }
    else
    {
        
        NSDate *date = [self.datePicker date];
        
        NSTimeInterval interval = [date timeIntervalSinceNow];

        if (interval >= 0)
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil)
                                                            message:NSLocalizedString(@"Can't be late for today", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            NSString *dateString = [dateFormatter stringFromDate:date];
            
            [self.userBirthdayLabel setText:dateString];
            
        }
    }
    
    
    if ([DeviceHelper phone])
    {
        [hud hide:YES];
    }
    else
    {
        
        if (self.popoverController)
        {
            [self.popoverController dismissPopoverAnimated:NO];
            self.popoverController = nil;
        }
    }

}


#pragma mark 科室事件
- (void)selectDepartmentsCellEvent
{
    
    NSDictionary *parameters = @{@"method":@"getDepartmentInfoList",
                                 @"departmentId":@"1",
                                 @"type":@"3"};
    
    NSArray *departObjects = [Department findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    
    
    if (departObjects.count <= 0)
    {
        
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        hud.labelText = NSLocalizedString(@"Loading Department Parameters", nil);
        [self.navigationController.view addSubview:hud];
        [hud show:YES];
        

        [GCRequest getDepartmentInfoListWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
            if (!error)
            {
                NSString *ret_code = responseData[@"ret_code"];
                if ([ret_code isEqualToString:@"0"])
                {
                    
                    [hud hide:YES];
                    
                    
                    [departObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Department *entity = (Department *)obj;
                        [entity deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                    }];
                    
                    
                    for (NSDictionary *departDic in responseData[@"departmentList"])
                    {
                        
                        Department *department = [Department createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
                        
                        [department updateCoreDataForData:departDic withKeyPath:nil];
                        
                    }
                    
                    [[CoreDataStack sharedCoreDataStack] saveContext];
                    
                    [self configureDepartmentPickerDataSource];
                    
                    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                    [self.navigationController.view addSubview:hud];
                    
                    hud.mode = MBProgressHUDModeCustomView;
                    hud.customView = self.departmentPickerView;
                    hud.margin = 0;
                    [hud show:YES];
                }
                else
                {
                    
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                    [hud hide:YES afterDelay:1.2];
                }
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedErrorMesssagesFromError:error];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];

            }
            
        }];
        
    }
    else
    {
        [self configureDepartmentPickerDataSource];
        
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = self.departmentPickerView;
        hud.margin = 0;
        [hud show:YES];
        
    }
}

- (void)configureDepartmentPickerDataSource
{
    _departCom0Array = [NSArray arrayWithArray:[Department findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentId = %@",@"1"]
                                                                      inContext:[CoreDataStack sharedCoreDataStack].context]];
    Department *depart = _departCom0Array[0];
    _departCom1Array = [NSArray arrayWithArray:[Department findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentId = %@",depart.departmentId]
                                                                      inContext:[CoreDataStack sharedCoreDataStack].context]];
}


- (IBAction)confirmButtonEvent:(id)sender
{
    
    Department *department = _departCom0Array[[self.departmentsPicker selectedRowInComponent:0]];
    NSString *parentId = department.departmentId;
    
    NSArray *objects = [Department findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentId = %@",parentId]
                                              inContext:[CoreDataStack sharedCoreDataStack].context];
    department = objects[[self.departmentsPicker selectedRowInComponent:1]];
    
    
    
    NSString *title = department.departmentName;
    
    
    if (title && title.length > 0)
    {
        UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:TableViewCellRowDepartments
                                                                                             inSection:0]];
        UILabel *label = (UILabel *)[cell viewWithTag:TableViewCellBaseItemTagUserView];
        [label setText:title];
    }
    
    [self.departmentPickerView removeFromSuperview];
    [hud hide:YES];
}


- (IBAction)cancelButtonEvent:(id)sender
{
    
    [self.departmentPickerView removeFromSuperview];
    [hud hide:YES];
}


#pragma mark - 编辑按钮事件
- (IBAction)editButtonEvent:(id)sender
{
    
    if (self.userInfoState == GCUserInfoStateNormal)
    {
        
        self.editing = YES;
        [self setupNavigationBarRightItemWithType:2];
    }
    
}



- (void)setEditing:(BOOL)editing
{
    
    if (_editing != editing)
    {
        _editing = editing;
        
        if (_editing)
        {
            
            [self editingStateAnimation];
            
            [self registerForKeyboardNotification:@selector(keyBoardWillShow:) :@selector(keyBoardWillHide:)];
            
            self.userNameTextField.userInteractionEnabled = YES;
            
            self.userHospitalTextField.userInteractionEnabled = YES;
            
            self.userSkilledTextView.userInteractionEnabled = YES;
        }
        else
        {
            self.userNameTextField.textColor = [UIColor lightGrayColor];
            self.userSexLabel.textColor = [UIColor lightGrayColor];
            self.userBirthdayLabel.textColor = [UIColor lightGrayColor];
            self.userLevelLabel.textColor = [UIColor lightGrayColor];
            self.userDepartmentLabel.textColor = [UIColor lightGrayColor];
            self.userHospitalTextField.textColor = [UIColor lightGrayColor];
            self.userIdLabel.textColor = [UIColor lightGrayColor];
            self.userCenterLabel.textColor = [UIColor lightGrayColor];
            self.userSkilledTextView.textColor = [UIColor lightGrayColor];
            
            [self removeKeyboardNotification];
            self.userNameTextField.userInteractionEnabled = NO;
            self.userHospitalTextField.userInteractionEnabled = NO;
            self.userSkilledTextView.userInteractionEnabled = NO;
        }
    }
}



#pragma mark - 编辑状态动画
- (void)editingStateAnimation
{
    
    for (int i=0; i < kRowCount; i++)
    {
        
        switch (i)
        {
            case TableViewCellRowGender:      [self beginAnimationForLabelCellWithRow:i];      break;
            case TableViewCellRowDateOfBirth: [self beginAnimationForLabelCellWithRow:i];      break;
            case TableViewCellRowDepartments: [self beginAnimationForLabelCellWithRow:i];      break;
            case TableViewCellRowRank:        [self beginAnimationForLabelCellWithRow:i];      break;
            case TableViewCellRowID:          [self beginAnimationForLabelCellWithRow:i];      break;
            case TableViewCellRowServiceCenter: [self beginAnimationForLabelCellWithRow:i];    break;
            case TableViewCellRowTerritory:   [self territoryCellAnimationBegin];              break;
            case TableViewCellRowActualName:  [self beginAnimationForTextFieldCellWithRow:i];  break;
            case TableViewCellRowHospital:    [self beginAnimationForTextFieldCellWithRow:i];  break;
            default:    break;
        }
    }
}


//
- (void)beginAnimationForLabelCellWithRow:(NSInteger)row
{
    
    UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    UIView *userView = [cell viewWithTag:TableViewCellBaseItemTagUserView];
    
    //用户的资料view改变状态
    if ([userView isKindOfClass:[UILabel class]])
    {
        
        UILabel *label = (UILabel *)userView;
        
        [UIView animateWithDuration:kAnimationDurantion/2 animations:^{
            
            //label隐藏
            label.alpha = 0;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:kAnimationDurantion/2 animations:^{
                if (row != TableViewCellRowRank && row != TableViewCellRowID && row != TableViewCellRowServiceCenter)
                {
                    [label setTextColor:[[UIColor colorWithRed:255.0/255.0 green:128.0/255.0 blue:0.0/255.0 alpha:1] colorWithAlphaComponent:1.0]];
                }
                
                //label显现
                label.alpha = 1;
            }];
        }];
    }
}

- (void)beginAnimationForTextFieldCellWithRow:(NSInteger )row
{
    UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    UIView *userView = [cell viewWithTag:TableViewCellBaseItemTagUserView];
    
    if ([userView isKindOfClass:[UITextField class]])
    {
        UITextField *textField = (UITextField *)userView;
        
        [UIView animateWithDuration:kAnimationDurantion/2 animations:^{
            textField.alpha = 0;
        } completion:^(BOOL finished) {
            
            [textField setTextColor:[UIColor orangeColor]];
            
            [UIView animateWithDuration:kAnimationDurantion/2 animations:^{
                textField.alpha = 1;
            }];
        }];
    }
}

- (void)territoryCellAnimationBegin
{
    
    
    [UIView animateWithDuration:kAnimationDurantion/2 animations:^{
        self.userSkilledTextView.alpha = 0;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:kAnimationDurantion/2 animations:^{
            self.userSkilledTextView.textColor = [UIColor orangeColor];
            self.userSkilledTextView.alpha = 1;
        }];
    }];
}

#pragma mark - 获取标题
- (NSString *)titleWithIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row)
    {
            
        case TableViewCellRowUserImage:
            return NSLocalizedString(@"Head portrait", nil);
            break;
        case TableViewCellRowActualName:
            return NSLocalizedString(@"Real name", nil);
            break;
        case TableViewCellRowGender:
            return NSLocalizedString(@"Sex", nil);
            break;
        case TableViewCellRowDateOfBirth:
            return NSLocalizedString(@"Date of birth", nil);
            break;
        case TableViewCellRowHospital:
            return NSLocalizedString(@"Hospital", nil);
            break;
        case TableViewCellRowRank:
            return NSLocalizedString(@"Level", nil);
            break;
        case TableViewCellRowDepartments:
            return NSLocalizedString(@"Department", nil);
            break;
        case TableViewCellRowID:
            return NSLocalizedString(@"ID", nil);
            break;
        case TableViewCellRowServiceCenter:
            return NSLocalizedString(@"Service Center", nil);
            break;
        case 9:
            return NSLocalizedString(@"Skill territory", nil);
            break;
        default:
            return @"";
            break;
    }
}


#pragma mark  -  根据string计算label大小
- (CGSize)sizeWithString:(NSString*)string font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attribute = @{NSFontAttributeName: font};
    
    CGSize textSize = [string boundingRectWithSize:maxSize
                                           options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        attributes:attribute
                                           context:nil].size;
    return textSize;
}



#pragma mark - 提交审批
- (void)selectUploadRequestCellEvent
{
    
    [self updateDataToServer];
    
    
    [self.mainTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                      animated:YES];
}


#pragma mark - Other
- (void)setUserInfoState:(GCUserInfoState)userInfoState
{
    
    _userInfoState = userInfoState;
    
    if (userInfoState == GCUserInfoStateApprove)
    {
        [self setupNavigationBarRightItemWithType:0];
    }
    else if (userInfoState == GCUserInfoStateNormal)
    {
        [self setupNavigationBarRightItemWithType:1];
    }
}

- (void)updatePresentUserInfoData
{
    
    NSArray *objects = [TemporaryInfo findAllInContext:[CoreDataStack sharedCoreDataStack].context];
    if (objects && objects.count >0)  //有用户审核详情则放出并更新
    {
        
        self.info = objects[0];
        [self updateUserInfoState];
        
        if ([LoadedLog needReloadedByKey:@"temporaryInfo"])
        {
            [self updateUserInfoApproveDataToCoreData];
        }
    }
    else   //无本地审核详情则暂时使用本地用户详情数据数据并请求审核数据.
    {
        
        NSDictionary *infoDic = [NSDictionary configureByModel:[UserInfomation shareInfo]];
        self.info = [TemporaryInfo createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
        [self.info updateCoreDataForData:infoDic withKeyPath:nil];
        
        [self updateUserInfoState];
        [self updateUserInfoApproveDataToCoreData];
    }
}

- (void)updateUserInfoState
{
    if ([self.info.stat isEqualToString:@"S0W"])
    {
        self.userInfoState = GCUserInfoStateApprove;
    }
    else
    {
        self.userInfoState = GCUserInfoStateNormal;
    }
}

#pragma mark - update & upload
- (void)updateUserInfoApproveDataToCoreData
{
    
    NSDictionary *parameters = @{@"method":@"getLastPersonalInfo",
                                 @"sessionId":[NSString sessionID],
                                 @"sessionToken":[NSString sessionToken],
                                 @"sign":@"sign",
                                 @"exptId":[NSString exptId]};
    
    [GCRequest getLastPersonalInfoWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        
        if (!error)
        {
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                
                responseData = [responseData[@"expert"] mutableCopy];
                [responseData sexFormattingToUserForKey:@"sex"];
                [responseData expertLevelFormattingToUserForKey:@"expertLevel"];
                [responseData dateFormattingToUserForKey:@"birthday"];
                
                [self.info updateCoreDataForData:responseData withKeyPath:nil];
                [self updateUserInfoState];
                
                //审核中的详情则覆盖本地审核详情, 未审核中的详情则覆盖审核详情和用户详情
                if (self.userInfoState == GCUserInfoStateApprove)
                {
                    self.userInfoState = GCUserInfoStateApprove;
                }
                else
                {
                    self.userInfoState = GCUserInfoStateNormal;
                    
                    NSDictionary *infoDic = [NSDictionary configureByModel:self.info];
                    UserInfomation *userInfo = [UserInfomation findAllInContext:[CoreDataStack sharedCoreDataStack].context][0];
                    [userInfo updateCoreDataForData:infoDic withKeyPath:nil];
                }
                
                
                [[CoreDataStack sharedCoreDataStack] saveContext];
                
                //记录成功刷新时间
                [LoadedLog shareLoadedLog].temporaryInfo = [NSString stringWithDateFormatting:GC_FORMATTER_SECOND date:[NSDate date]];
                
                [self.mainTableView reloadData];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOT_RELOADMEMBERLIST object:nil];
            }
            else
            {
                hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [hud show:YES];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
        }
        else
        {
            hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [hud show:YES];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
        
        [[CoreDataStack sharedCoreDataStack] saveContext];

    }];
}

- (void)updateDataToCoreData
{
    
    self.info.headimageUrl = !self.thumbnailURLString ? self.info.headimageUrl : self.thumbnailURLString;
    self.info.exptName = self.userNameTextField.text;
    self.info.birthday = self.userBirthdayLabel.text;
    self.info.sex = self.userSexLabel.text;
    self.info.hospital = self.userHospitalTextField.text;
    self.info.skilled = self.userSkilledTextView.text;
    self.info.departmentId = [Department getDepartmentIdByName:self.userDepartmentLabel.text];
    self.info.exptId = self.userIdLabel.text;
    self.info.expertLevel = self.userLevelLabel.text;
    self.info.centerId = [ServCenter getCenterIdByName:self.userCenterLabel.text];
    self.info.stat = @"S0W";
    
    [[CoreDataStack sharedCoreDataStack] saveContext];
}

- (void)uploadThumbnailToServer
{
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.labelText = NSLocalizedString(@"Thumbnail uploading", nil);
    [hud show:YES];
    
    NSData *imageData = UIImageJPEGRepresentation(self.thumbnailImage, 0.5);
    NSDictionary *parameters = @{@"method": @"uploadFile",
                                 @"fileType": @"2"};
    
    [GCRequest userUploadFileWithParameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"thumbnail.jpg" mimeType:@"image/jpeg"];
        
        
    } withBlock:^(NSDictionary *responseData, NSError *error){
        
        if (!error) {
            if ([[responseData valueForKey:@"ret_code"] isEqualToString:@"0"])
            {
                
                // 保存用户图片URL
                self.thumbnailURLString = [NSString parseDictionary:responseData forKeyPath:@"fileUrl"];
                
                [self.userHeadImageView setImageWithURL:[NSURL URLWithString:self.thumbnailURLString]
                                       placeholderImage:nil];
                
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"Upload Successful,save to change", nil);
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                [hud hide:YES afterDelay:1.2];
            }
        }
        else
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = [NSString localizedErrorMesssagesFromError:error];
            [hud hide:YES afterDelay:HUD_TIME_DELAY];
        }
    }];
}

- (void)updateDataToServer
{
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.labelText = NSLocalizedString(@"Saving Data", nil);
    [hud show:YES];
    
    
        
    NSDictionary *parameters = @{@"method":@"expertInfoEdit",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"exptId":[NSString exptId],
                                 @"birthday":self.userBirthdayLabel.text,
                                 @"departmentId":[Department getDepartmentIdByName:self.userDepartmentLabel.text],
                                 @"headimageUrl":!self.thumbnailURLString ? self.info.headimageUrl : self.thumbnailURLString,
                                 @"exptName":self.userNameTextField.text,
                                 @"sex":self.userSexLabel.text,
                                 @"skilled":self.userSkilledTextView.text,
                                 @"hospital":self.userHospitalTextField.text
                                 };
    

    [GCRequest expertInfoEditWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        
        if (!error)
        {
            
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                
                [self updateDataToCoreData];
                
                self.userInfoState = GCUserInfoStateApprove;
                self.editing = NO;
                
                [self.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:NO];
                [self.mainTableView reloadData];
                
                
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"Data Updated", nil);
                [hud hide:YES afterDelay:HUD_TIME_DELAY];
            }
            else
            {
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
    }];
}



@end
