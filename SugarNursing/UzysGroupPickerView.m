//
//  UzysGroupPickerView.m
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 13..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

// 版权属于原作者
// http://code4app.com(cn) http://code4app.net(en)
// 来源于最专业的源码分享网站: Code4App

#import "UzysGroupPickerView.h"
#import "UzysGroupViewCell.h"
#import "UzysAssetsPickerController_Configuration.h"
#import "DeviceHelper.h"
#import "SystemVersion.h"


#define BounceAnimationPixel 5
#define NavigationHeight 64
@implementation UzysGroupPickerView

- (id)initWithGroups:(NSMutableArray *)groups
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
        self.groups = groups;
        [self setupLayout];
        [self setupTableView];
        [self addObserver:self forKeyPath:@"groups" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"groups"];
}

- (void)setupLayout
{
    //anchorPoint 를 잡는데 화살표 지점으로 잡아야함
    CGRect rect = [DeviceHelper screenBounds];
    rect.origin.y -= rect.size.height;
    self.frame = rect;
    self.layer.cornerRadius = 4;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    }


- (void)updateViewsFrame
{
    
    CGRect rect = [DeviceHelper screenBounds];
    rect.origin.x = 0;
    rect.origin.y += [self topBarHeight];
    rect.size.height -= [self topBarHeight];
    [self.tableView setFrame:rect];
    
    CGRect frame = [DeviceHelper screenBounds];
    if (!self.isOpen)
    {
        frame.origin.y -= frame.size.height;
    }
    self.frame = frame;
}

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [self topBarHeight], CGRectGetWidth([UIScreen mainScreen].bounds), self.bounds.size.height -NavigationHeight) style:UITableViewStylePlain];
//    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.tableView.contentInset = UIEdgeInsetsMake(1, 0, 0, 0);
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.rowHeight = kGroupPickerViewCellLength;
//    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.tableView];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UzysGroupCell" bundle:nil]
         forCellReuseIdentifier:@"UzysGroupCell"];
    [self updateViewsFrame];
}

- (void)reloadData
{
    [self.tableView reloadData];
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
    
    
    return statusHeight + 44;
}


- (CGRect)mainViewBound
{
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown)
        {
            return self.bounds;
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
        return self.bounds;
    }
}


- (void)show
{
    __block CGRect rect = [DeviceHelper screenBounds];
    [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        rect.origin.y += BounceAnimationPixel;
        self.frame = rect;
    } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15f delay:0.f options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
                rect.origin.y = 0;
                    self.frame = rect;
            } completion:^(BOOL finished) {
            }];
    }];
    self.isOpen = YES;
}
- (void)dismiss:(BOOL)animated
{
    if (!animated)
    {
        CGRect rect = [DeviceHelper screenBounds];
        rect.origin.y -= rect.size.height;
        self.frame = rect;
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect rect = [DeviceHelper screenBounds];
            rect.origin.y -= rect.size.height;
            self.frame = rect;
        } completion:^(BOOL finished) {
        }];
    }
    self.isOpen = NO;

}
- (void)toggle
{
    if(self.frame.origin.y <0)
    {
        [self show];
    }
    else
    {
        [self dismiss:YES];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UzysGroupCell"; 
    
    UzysGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell applyData:[self.groups objectAtIndex:indexPath.row]];
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGroupPickerViewCellLength;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.blockTouchCell)
        self.blockTouchCell(indexPath.row);
}

@end
