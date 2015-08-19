    //
//  SendReportViewController.m
//  SugarNursing
//
//  Created by Ian on 15/5/28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "SendReportViewController.h"
#import "Image_Cell.h"
#import "UzysAssetsPickerController.h"
#import "UIViewController+Notifications.h"
#import <MWPhotoBrowser.h>
#import <MBProgressHUD.h>
#import "UtilsMacro.h"
#import "UIImage+Compress.h"
#import "ReportCache.h"
#import "ImageCache.h"
#import <libkern/OSAtomic.h>

static CGFloat kBottomButtonHeight = 40;



@interface SendReportViewController ()
<
ImageCellDelegate,
UzysAssetsPickerControllerDelegate,
UITextViewDelegate,
MWPhotoBrowserDelegate
>
{
    CGFloat _CurrentOffSet;
    MBProgressHUD *hud;
    
    NSInteger _uploadStage;
    NSString *_errorString;
    NSMutableDictionary *_attachDic;
    NSMutableDictionary *_alreadyUploaoDic;
    
    ALAssetsLibrary *library;
    
    BOOL isNeedSave;
}

@property (strong, nonatomic) UIScrollView *myScrollView;
@property (strong, nonatomic) NSMutableArray *photos;

@property (assign, nonatomic) CGFloat kbHeight;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonBottomLayoutConstraint;

@property (strong, nonatomic) NSMutableArray *selectAssets;
@property (strong, nonatomic) NSMutableArray *selectAssetsURL;
@property (strong, nonatomic) NSMutableArray *selectImageArray;

@end

@implementation SendReportViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    isNeedSave = YES;
    _attachDic = [NSMutableDictionary new];
    _alreadyUploaoDic = [NSMutableDictionary new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutSubViews];
    [self loadReportCache];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotification:@selector(keyboardWillShow:) :@selector(keyboardWillHide:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    
    if (self.reportModel && self.reportModel.count>0)
    {
        NSString *content;
        if (self.myTextView.text.length > 0)
        {
            content = [self.myTextView.text stringByAppendingString:self.reportModel[@"content"]];
        }
        else
        {
            content = self.reportModel[@"content"];
        }
        
        self.myTextView.text = content;
        
        
        self.reportModel = nil;
    }
    
    [self updateAllViewLayout];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (isNeedSave)
    {
        [self saveReportCache];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *vc = [segue destinationViewController];
    if ([vc respondsToSelector:@selector(setLinkManId:)])
    {
        [vc setValue:self.linkManId forKey:@"linkManId"];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateAllViewLayout];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}


#pragma mark - 初始化
- (void)layoutSubViews
{
    
    self.navigationItem.title = NSLocalizedString(@"Send Report", nil);
    
    
    CGRect frame = [self mainViewBound];
    frame.origin.y = [self topBarHeight];
    frame.size.height = [self myTextViewMaxHeight];
    self.myScrollView = [[UIScrollView alloc] initWithFrame:frame];
    self.myScrollView.delegate = self;
    
    frame.size.height++;
    [self.myScrollView setContentSize:frame.size];
    
    [self.view insertSubview:self.myScrollView atIndex:0];
    
    
    
    CGRect rect = [self mainViewBound];
    rect.size.height = [self myTextViewMaxHeight];
    self.myTextView = [[ReportTextView alloc] initWithFrame:rect];
    [self.myTextView setPlaceholder:NSLocalizedString(@"Send Advice To Your Patient", nil)];
    
    UINib *nib = [UINib nibWithNibName:@"ImageCell" bundle:nil];
    [self.myTextView.myCollectionView registerNib:nib forCellWithReuseIdentifier:@"ImageCell"];
    
    
    [self.myTextView setDelegate:self];
    [self.myTextView setPlaceholder:NSLocalizedString(@"Send Advice To Your Patient", nil)];
    [self.myScrollView addSubview:self.myTextView];
    
    [self configureNavigationItem];
}

- (void)configureNavigationItem
{
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonEvent:)];
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(sendAdviceButtonEvent:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    self.navigationItem.rightBarButtonItem = sendItem;
}


- (void)loadReportCache
{
    NSArray *objects = [ReportCache findAllWithPredicate:[NSPredicate predicateWithFormat:@"linkManId = %@",self.linkManId]
                                                 inContext:[CoreDataStack sharedCoreDataStack].context];
    if (objects.count > 0)
    {
        ReportCache *reportCache = objects[0];
        self.myTextView.text = reportCache.content;
        
        
        self.selectImageArray = [[NSMutableArray alloc] init];
        self.selectAssetsURL = [NSMutableArray new];
        
        for (ImageCache *imageCache in reportCache.imageCache)
        {
            NSURL *url = [NSURL URLWithString:imageCache.url];
            
            [self.selectAssetsURL addObject:url];
        }
        
        
        [self updateAssetWithUrls:self.selectAssetsURL];
    }
}

#pragma mark - 键盘动画

- (void)keyboardDidShow:(NSNotification *)notification
{
    if (SYSTEM_VERSION_LESS_THAN(@"8.0") &&
        ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ||
         [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
    {
        self.kbHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
    }
    else
        self.kbHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [self updateScrollViewContentSize];
    [self updateScrollViewOffSetWithAnimation:YES];
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat kbHeight = 0.0;

    if (SYSTEM_VERSION_LESS_THAN(@"8.0") &&
        ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ||
         [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
    {
        kbHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
    }
    else
        kbHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    
    self.bottomButtonBottomLayoutConstraint.constant = kbHeight;
    [self.view setNeedsUpdateConstraints];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    
    
    self.bottomButtonBottomLayoutConstraint.constant = 0;
    [self.view setNeedsUpdateConstraints];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}


#pragma mark - 根据光标位置更新scorllView OffSet
- (void)updateScrollViewOffSetWithAnimation:(BOOL)animation
{
    
    // 获取光标的位置区域
    
    CGRect cursorPosition = [self.myTextView caretRectForPosition:self.myTextView.selectedTextRange.start];
    
    // 光标相对顶层视图（scrollView）frame的坐标高度
    
    CGFloat height = cursorPosition.origin.y + self.myTextView.frame.origin.y;
    
    
    CGFloat currentPoint = cursorPosition.origin.y + cursorPosition.size.height;
    
    
    // 可见scrollView区域， 由于键盘有中英输入法，所以会导致可见区域的变化
    
    CGFloat cursorValueMax = [self mainViewBound].size.height - [self topBarHeight] - self.kbHeight;
    
    if (height > cursorValueMax - 50)
    {   // 当光标在可见区域底部50pix内，即距离键盘50pix内
        
        [self.myScrollView setContentOffset:CGPointMake(0, currentPoint + self.myTextView.frame.origin.y - cursorValueMax + 50)
                                   animated:animation];
    }
    else if (height < 20)
    {                     // 当光标在可见区域顶20pix内，即距离顶部20pix内
        
        [self.myScrollView scrollRectToVisible:CGRectMake(0,
                                                          cursorPosition.origin.y - 20,
                                                          CGRectGetWidth([self mainViewBound]),
                                                          60)
                                      animated:animation];
    }
}

#pragma mark - 刷新
- (void)updateScrollViewContentSize
{
    CGFloat contentHeight = self.myTextView.contentSize.height;
    
    CGSize scrollViewContentSize = self.myScrollView.contentSize;
    
    if (contentHeight > scrollViewContentSize.height)
    {
        
        CGRect frame = self.myTextView.frame;
        scrollViewContentSize.height = frame.origin.y + frame.size.height + 5;
        scrollViewContentSize.width = frame.size.width;
        
        self.myScrollView.contentSize = scrollViewContentSize;
    }
    else
    {
        CGSize size = self.myScrollView.frame.size;
        size.height++;
        [self.myScrollView setContentSize:size];
    }
}


- (void)updateAllViewLayout
{
    CGRect frame = [self mainViewBound];
    frame.origin.y = [self topBarHeight];
    frame.size.height = [self myTextViewMaxHeight];
    [self.myScrollView setFrame:frame];
    
    CGRect rect = [self mainViewBound];
    rect.size.height = [self myTextViewMaxHeight];
    [self.myTextView setFrame:rect];
    
    [self.myTextView updateReportViewLayout];
    [self updateScrollViewContentSize];
    [self updateScrollViewOffSetWithAnimation:YES];
}


#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView
{
    
    [self.myTextView updateReportViewLayout];
    [self updateScrollViewContentSize];
    [self updateScrollViewOffSetWithAnimation:NO];
}


#pragma mark - Item's Height
- (CGFloat)topBarHeight
{
    CGFloat statusHeight = 0.0;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown)
        {
            statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        }
        else
        {
            statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.width;
        }
    }
    else
        statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    return statusHeight + self.navigationController.navigationBar.frame.size.height;
}

- (CGFloat)myTextViewMaxHeight
{
    return [self contentViewHeight] - kBottomButtonHeight;
}

- (CGFloat)contentViewHeight
{
    NSLog(@"height = %f, topbar = %f",CGRectGetHeight(self.view.bounds),[self topBarHeight]);
    return CGRectGetHeight([self mainViewBound]) - [self topBarHeight];
}

- (CGRect)mainViewBound
{
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown)
        {
            return self.view.bounds;
        }
        else
        {
            CGRect rect = [[UIScreen mainScreen] bounds];
            CGFloat width = rect.size.width;
            CGFloat height = rect.size.height;
            rect.size.width = height;
            rect.size.height = width;
            return rect;
        }
    }
    else
    {
        return self.view.bounds;
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.myTextView isFirstResponder])
    {
        [self.myTextView resignFirstResponder];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}


#pragma mark - UICollectionView Delegate & DataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ImageCell";
    Image_Cell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    imageCell.delegate = self;
    imageCell.tag = indexPath.row;
    if (indexPath.row == self.selectImageArray.count)
    {
        [imageCell.imageButton setBackgroundImage:[UIImage imageNamed:@"addImage_NoSelect"] forState:UIControlStateNormal];
        [imageCell.imageButton setBackgroundImage:[UIImage imageNamed:@"addImage_Select"] forState:UIControlStateHighlighted];
        imageCell.deleteButton.hidden = YES;
    }
    else
    {
        [imageCell.imageButton setBackgroundImage:self.selectImageArray[indexPath.row] forState:UIControlStateNormal];
        [imageCell.imageButton setBackgroundImage:self.selectImageArray[indexPath.row] forState:UIControlStateSelected];
        imageCell.deleteButton.hidden = NO;
    }
    
    return imageCell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.selectImageArray.count;
    if (count<3)
    {
        count++;
    }
    return count;
}




#pragma mark Image_Cell Delegate
- (void)imageCellDidTapDeleteButton:(Image_Cell *)cell
{
    NSInteger row = [self.myTextView.myCollectionView indexPathForCell:cell].row;
    [self.selectImageArray removeObjectAtIndex:row];
    [self.selectAssets removeObjectAtIndex:row];
    [self.selectAssetsURL removeObjectAtIndex:row];
    
    [self.myTextView.myCollectionView reloadData];
    
    [self saveReportCache];
    
    //编辑图片后清除上传缓存
    [self deleteUploadImageCache];
}


- (void)imageCellDidTapImageButton:(Image_Cell *)cell
{
    NSInteger index = cell.tag;
    
    //是否添加图片按钮
    if (index == self.selectImageArray.count)
    {
        [self selectImageButtonEvent:nil];
    }
    else
    {
        
        NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:10];
        MWPhoto *photo;
        
        
        for (UIImage *image in self.selectImageArray)
        {
            
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
        [photoBrowser setCurrentPhotoIndex:[self.myTextView.myCollectionView indexPathForCell:cell].row];
        
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        {
            // conditionly check for any version >= iOS 8
            [self showViewController:photoBrowser sender:nil];
            
        }
        else
        {
            // iOS 7 or below
            [self.navigationController pushViewController:photoBrowser animated:YES];
        }
    }
}


#pragma mark - MWPhotoBrowser Delegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.photos.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    return self.photos[index];
}



#pragma mark - UzysAssetsPickerControllerDelegate

- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    
//    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
//    {
//        self.selectImageArray = [[NSMutableArray alloc] init];
//        
//        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
//        {
//            ALAsset *representation = obj;
//            
//            
//            UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullResolutionImage
//                                               scale:representation.defaultRepresentation.scale
//                                         orientation:(UIImageOrientation)representation.defaultRepresentation.orientation];
//            
//            [self.selectImageArray addObject:img];
//
//        }];
//    }
    self.selectAssets = [[NSMutableArray alloc] init];
    self.selectAssets = [assets mutableCopy];
    
    [self updateImageWithAssets:self.selectAssets];
    
    
    self.selectAssetsURL = [NSMutableArray new];
    for (ALAsset *asset in self.selectAssets)
    {
        [self.selectAssetsURL addObject:[NSString stringWithFormat:@"%@",asset.defaultRepresentation.url]];
    }
    
    
    //编辑图片后清除上传缓存
    [self deleteUploadImageCache];
}
- (void)UzysAssetsPickerControllerDidCancel:(UzysAssetsPickerController *)picker
{
    
}

#pragma mark - Bottom Button Event

- (IBAction)selectImageButtonEvent:(id)sender
{
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = 3;
    
    if (self.selectAssets && self.selectAssets.count>0)
    {
        picker.selectAssets = [self.selectAssets mutableCopy];
    }
    
    [self.navigationController pushViewController:picker animated:YES];
}

- (IBAction)reportModelButtonEvent:(id)sender
{
    [self performSegueWithIdentifier:@"goReportModel" sender:nil];
}

- (IBAction)reportHistoryButtonEvent:(id)sender
{
    
}

- (void)cancelButtonEvent:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark  发送建议按钮
- (void)sendAdviceButtonEvent:(id)sender
{
    if ([self.myTextView isFirstResponder])
        [self.myTextView resignFirstResponder];
    
    _uploadStage = _attachDic.count;
    _errorString = @"";
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    [hud show:NO];
    
    
    BOOL needUploadImage = NO;
    for (int i=0; i<self.selectImageArray.count; i++)
    {
        
        if (![self isExistKey:[NSString stringWithFormat:@"%d",i] forDictionary:_attachDic])
        {
            needUploadImage = YES;
            [self uploadAttachToServer:self.selectImageArray[i] index:i block:^{
                [self sendAdviceToServer];
            }];
        }
    }
    
    if (!needUploadImage)
    {
        [self sendAdviceToServer];
    }
}

#pragma mark- NetWorking
- (void)uploadAttachToServer:(UIImage *)image index:(NSInteger)index block:(void(^)())completeBlock
{
    
    NSData *imageData = [image compressImageToTargetMemory:200];
    
    NSDictionary *parameters = @{@"method": @"uploadFile",
                                 @"fileType": @"2"};
    
    [GCRequest userUploadFileWithParameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"reportImage.jpg" mimeType:@"image/jpeg"];
        
    } withBlock:^(NSDictionary *responseData, NSError *error){
        
        _uploadStage++;
        
        if (!error)
        {
            if ([[responseData valueForKey:@"ret_code"] isEqualToString:@"0"])
            {
                // 保存用户图片URL
                [_attachDic setObject:[NSString parseDictionary:responseData forKeyPath:@"fileUrl"]
                               forKey:[NSString stringWithFormat:@"%ld",index]];
                
                hud.labelText = [NSString stringWithFormat:@"%@(%ld/%ld)",NSLocalizedString(@"Thumbnail uploading", nil),_attachDic.count,self.selectImageArray.count];
                
                if (_uploadStage == _selectImageArray.count)
                {
                    
                    if (!_errorString || _errorString.length>0)
                    {
                        hud.mode = MBProgressHUDModeText;
                        hud.labelText = _errorString;
                        [hud hide:YES afterDelay:HUD_TIME_DELAY];
                    }
                    else
                    {
                        completeBlock();
                    }
                }
            }
            else
            {
                
                if (_uploadStage == _selectImageArray.count)
                {
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                    [hud hide:YES afterDelay:HUD_TIME_DELAY];
                }
                else
                {
                    _errorString = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
                }
            }
        }
        else
        {
            
            if (_uploadStage == _selectImageArray.count)
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString localizedErrorMesssagesFromError:error];
                [hud hide:YES afterDelay:HUD_TIME_DELAY];

            }
            else
            {
                _errorString = [NSString localizedMsgFromRet_code:responseData[@"ret_code"] withHUD:YES];
            }

        }
    }];
}

- (void)sendAdviceToServer
{
    
    NSDictionary *parameters = @{@"method":@"sendDoctorSuggests",
                                 @"sign":@"sign",
                                 @"sessionId":[NSString sessionID],
                                 @"content":self.myTextView.text,
                                 @"linkManId":self.linkManId,
                                 @"exptId":[NSString exptId],
                                 @"adviceAttach":[self configureAdviceAttachString]
                                 };
    
    
    [GCRequest sendDoctorSuggestsWithParameters:parameters block:^(NSDictionary *responseData, NSError *error) {
        if (!error)
        {
            
            if ([responseData[@"ret_code"] isEqualToString:@"0"])
            {
                [self deleteUploadImageCache];
                
                [ReportCache deleteEntityInContext:[CoreDataStack sharedCoreDataStack].context
                                         predicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"linkManId = %@",self.linkManId]]];
                
                LoadedLog *log = [LoadedLog shareLoadedLog];
                log.patient = @"";
                [[CoreDataStack sharedCoreDataStack] saveContext];
                

                isNeedSave = NO;
                
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"Send Succeed", nil);
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(HUD_TIME_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [hud hide:YES];
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
                
   
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


- (NSString *)configureAdviceAttachString
{
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *attachPath in [_attachDic allValues])
    {
        NSDictionary *dic = @{@"attachName":@"",@"attachPath":attachPath};
        [array addObject:dic];
    }
    
    if (array.count<=0)
    {
        return @"";
    }
    else
    {
        NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
        NSString *attachString =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return attachString;
    }
}


#pragma mark - 缓存策略
- (BOOL)isExistKey:(NSString *)key forDictionary:(NSDictionary *)dic
{
    for (NSString *string in [dic allKeys])
    {
        if ([string isEqualToString:key])
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)deleteUploadImageCache
{
    _uploadStage = 0;
    _errorString = @"";
    [_attachDic removeAllObjects];
    [_alreadyUploaoDic removeAllObjects];
}



- (void)saveReportCache
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"linkManId = %@",self.linkManId]];
    NSArray *objects = [ReportCache findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context];
    
    ReportCache *cache;
    if (objects.count<=0)
    {
        cache = [ReportCache createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
    }
    else
    {
        cache = objects[0];
    }
    
    cache.linkManId = self.linkManId;
    cache.content = self.myTextView.text;
    
    NSMutableOrderedSet *orderSet = [[NSMutableOrderedSet alloc] init];
    for (NSURL *url in self.selectAssetsURL)
    {
        ImageCache *imageCache = [ImageCache createEntityInContext:[CoreDataStack sharedCoreDataStack].context];
        imageCache.url = [NSString stringWithFormat:@"%@",url];
        [orderSet addObject:imageCache];
    }
    
    cache.imageCache = orderSet;
    
    [[CoreDataStack sharedCoreDataStack] saveContext];
}


- (void)updateAssetWithUrls:(NSArray *)urls
{
    self.selectAssets = [[NSMutableArray alloc] init];
    
    library = [[ALAssetsLibrary alloc] init];
    
    __block NSInteger count = urls.count;
    for (NSURL *url in urls)
    {
            [library assetForURL:url resultBlock:^(ALAsset *asset) {
                if (asset)
                {
                    [self.selectAssets addObject:asset];
                }
                
                count--;
                if (count <=0)
                {
                    [self updateImageWithAssets:self.selectAssets];
                }
                    
            } failureBlock:^(NSError *error) {
                NSLog(@"GetAssetByURL Error : %@",error.localizedDescription);
            }];
        
    }
}


- (void)updateImageWithAssets:(NSArray *)array
{
    self.selectImageArray = [NSMutableArray new];
    for (ALAsset *asset in array)
    {
        UIImage *image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
        [self.selectImageArray addObject:image];
    }
    
    [self.myTextView updateReportViewLayout];
    [self.myTextView.myCollectionView reloadData];
    
}

@end
