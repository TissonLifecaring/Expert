//
//  ReportDetailViewController.m
//  SugarNursing
//
//  Created by Ian on 15/6/1.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "ReportDetailViewController.h"
#import "UIViewController+Notifications.h"
#import "UtilsMacro.h"
#import <MBProgressHUD.h>
#import "SendReportViewController.h"

typedef NS_ENUM(NSInteger, GCTextViewType)
{
    GCTextViewTypeTitle = 1001,
    GCTextViewTypeContent = 1002
};

@interface ReportDetailViewController ()
<
UITextViewDelegate
>
{
    CGFloat _titleTextViewLastInputHeight;
    CGFloat _contentTextViewLastInputHeight;
    BOOL _textDidChange;
    MBProgressHUD *_hud;
}

@property (assign, nonatomic) NSInteger kbHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleTextViewWidthConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleTextViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentTextViewHeightConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentTextViewBottomConstraint;



@end

@implementation ReportDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubView];
}

- (void)initSubView
{
    if (self.reportType == GCReportTypeDetail)
    {
        self.titleTextView.text = self.reportTitle;
        self.contentTextView.text = self.reportContent;
    }
    else
    {
        self.titleTextView.text = @"";
        self.contentTextView.text = @"";
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(saveButtonEvent)];
        self.navigationItem.rightBarButtonItem = saveItem;
    }
    
    self.titleTextView.placeholder = @"请输入报告标题";
    self.contentTextView.placeholder = @"请输入报告内容";
    
    [self updateSubviewConstraint];
    
    [self configureNavigationBarItem];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [self updateSubviewConstraint];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


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
    
    
    [self scrollViewScrollToCaretWithTextView:[self.titleTextView isFirstResponder] ? self.titleTextView : self.contentTextView
                                    animation:YES];
}


- (void)configureNavigationBarItem
{
    if (self.reportType == GCReportTypeDetail)
    {
        if (_textDidChange)
        {
            UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(saveButtonEvent)];
            self.navigationItem.rightBarButtonItem = saveItem;
        }
        else
        {
            UIBarButtonItem *userItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Use", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(userButtonEvent)];
            self.navigationItem.rightBarButtonItem = userItem;
        }
    }
    else
    {
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(addButtonEvent)];
        self.navigationItem.rightBarButtonItem = addItem;
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateSubviewConstraint];
}

#pragma mark - 高度计算

- (void)updateSubviewConstraint
{
    CGSize titleSize = [self.titleTextView sizeThatFits:CGSizeMake(CGRectGetWidth(self.view.bounds) - 20, 1000)];
    CGSize contentSize = [self.contentTextView sizeThatFits:CGSizeMake(CGRectGetWidth(self.view.bounds) - 20, 10000)];
    
    if (titleSize.height != _titleTextViewLastInputHeight || contentSize.height != _contentTextViewLastInputHeight)
    {
        _titleTextViewLastInputHeight = titleSize.height;
        _contentTextViewLastInputHeight = contentSize.height;
        
        self.titleTextViewWidthConstraint.constant = CGRectGetWidth(self.view.bounds) - 20;
        self.titleTextViewHeightConstraint.constant = titleSize.height;
        
        if (contentSize.height < CGRectGetHeight(self.view.bounds) - 10 - titleSize.height - 1 - 10)
        {
            contentSize.height = CGRectGetHeight(self.view.bounds) - 10 - titleSize.height - 1 - 10;
        }
        
        self.contentTextViewHeightConstraint.constant = contentSize.height;
        
        //1是分割线 , 10是分割线到contentTextView距离
        CGSize size = CGSizeMake(CGRectGetWidth(self.view.bounds), titleSize.height + contentSize.height + 1 +10);
        
        
        //保证scrollView的滑动
        if (size.height - 10 < CGRectGetHeight(self.myScrollView.bounds))
            size.height = CGRectGetHeight(self.myScrollView.bounds);
        
        size.height+= 20;
        [self.myScrollView setContentSize:size];
        
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }
}


- (CGFloat)topViewHeight
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

- (void)scrollViewScrollToCaretWithTextView:(UITextView *)textView animation:(BOOL)animation
{
    // 获取光标的位置区域
    CGRect cursorPosition = [textView caretRectForPosition:textView.selectedTextRange.start];
    
    // 光标相对顶层视图(scrollView)frame的坐标高度
    CGFloat height = cursorPosition.origin.y + textView.frame.origin.y;
    
    CGFloat currentPoint = cursorPosition.origin.y + cursorPosition.size.height;
    
    
    // 可见scrollView区域， 由于键盘有中英输入法，所以会导致可见区域的变化
    CGFloat cursorValueMax = [self mainViewBound].size.height - [self topViewHeight] - self.kbHeight;
    
    if (height > cursorValueMax - 50)
    {
        // 当光标在可见区域底部50pix内，即距离键盘50pix内
        [self.myScrollView setContentOffset:CGPointMake(0, currentPoint + textView.frame.origin.y - cursorValueMax + 50)
                                   animated:animation];
    }
    else if (height < 20)
    {                     // 当光标在可见区域顶部20pix内，即距离顶部20pix内
        
        [self.myScrollView scrollRectToVisible:CGRectMake(0,
                                                          cursorPosition.origin.y - 20,
                                                          CGRectGetWidth(self.view.bounds),
                                                          60)
                                      animated:animation];
    }
}

- (void)saveReportModelEditing
{
    [self.delegate reportDidChangeTitle:self.titleTextView.text content:self.contentTextView.text indexRow:self.reportIndexRow];
}


#pragma mark - TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView.tag == GCTextViewTypeTitle)
    {
        [self.myScrollView scrollsToTop];
    }
    else
    {
        
    }
}



- (void)textViewDidChange:(UITextView *)textView
{
    _textDidChange = YES;
    if (self.reportType == GCReportTypeDetail)
    {
        [self configureNavigationBarItem];
    }
    
    [self updateSubviewConstraint];
    [self scrollViewScrollToCaretWithTextView:textView animation:NO];
    [self textViewContentTextIsOverFlow:textView];
}

- (void)textViewContentTextIsOverFlow:(UITextView *)textView
{
    
    NSString *text = textView.text;
    
    if (textView.tag == GCTextViewTypeTitle)
    {
        if (text.length >40)
        {
            [textView setTextColor:[UIColor redColor]];
        }
        else
        {
            [textView setTextColor:[UIColor blackColor]];
        }
    }
    else
    {
        if (text.length >2000)
        {
            [textView setTextColor:[UIColor redColor]];
        }
        else
        {
            [textView setTextColor:UIColorFromRGB(0x666666)];
        }
    }
}


#pragma mark - ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.titleTextView isFirstResponder])
        [self.titleTextView resignFirstResponder];
    if ([self.contentTextView isFirstResponder])
        [self.contentTextView resignFirstResponder];
}


#pragma mark - Button Event
- (void)saveButtonEvent
{
    
    if ([self.titleTextView isFirstResponder])
    {
        [self.titleTextView resignFirstResponder];
    }
    
    if ([self.contentTextView isFirstResponder])
    {
        [self.contentTextView resignFirstResponder];
    }
    
    if ([self judgeInputIsValid])
    {
        [self.myScrollView setContentOffset:CGPointMake(0, 0)];
        
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        
        if ([self.delegate respondsToSelector:@selector(reportDidChangeTitle:content:indexRow:)])
        {
            [self.delegate reportDidChangeTitle:self.titleTextView.text content:self.contentTextView.text indexRow:self.reportIndexRow];
        }
        
        
        _hud.mode = MBProgressHUDModeText;
        _hud.labelText = NSLocalizedString(@"Save Success", nil);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (HUD_TIME_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_hud hide:YES];
            _textDidChange = NO;
            [self configureNavigationBarItem];
        });
    }
}

- (void)addButtonEvent
{
    if ([self judgeInputIsValid])
    {
        
        if ([self.delegate respondsToSelector:@selector(reportAddModelWithTitle:content:)])
        {
            [self.delegate reportAddModelWithTitle:self.titleTextView.text content:self.contentTextView.text];
        }

        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)userButtonEvent
{
    SendReportViewController *sendReportVC = [self.navigationController viewControllers][0];
    sendReportVC.reportModel = @{@"title":self.titleTextView.text,@"content":self.contentTextView.text,@"seq":[NSNumber numberWithInteger:0]};
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - Others
- (BOOL)judgeInputIsValid
{
    NSString *remindString;
    if (self.titleTextView.text.length<=0)
    {
        remindString = NSLocalizedString(@"Please Input The Report Title", nil);
    }
    
    if (self.contentTextView.text.length<=0)
    {
        remindString = NSLocalizedString(@"Please Input The Report Content", nil);
    }
    
    if (self.titleTextView.text.length>40)
    {
        remindString = NSLocalizedString(@"Report Title Length Must Less Than 40", nil);
    }
    
    if (self.contentTextView.text.length>2000) {
        remindString = NSLocalizedString(@"Report Content's Length Must Less Than 2000", nil);
    }
    
    if (remindString && remindString.length>0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil) message:remindString delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    else
    {
        return YES;
    }
    
}

@end
