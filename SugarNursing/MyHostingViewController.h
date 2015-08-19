//
//  MyHostingViewController.h
//  SugarNursing
//
//  Created by Ian on 14-11-25.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSPullToRefresh.h>
#import "RefreshTableView.h"


typedef NS_ENUM(NSInteger, RefreshTableViewFlag)
{
    RefreshTableViewFlagWaitting = 1,
    RefreshTableViewFlagConfirm = 2,
    RefreshTableViewFlagRefuse = 4,
    RefreshTableViewFlagOver = 3
};

@interface MyHostingViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
UITabBarDelegate,
SSPullToRefreshViewDelegate
>

@property (weak, nonatomic) IBOutlet UITabBar *myTabBar;

@property (weak, nonatomic) IBOutlet RefreshTableView *tableViewWaitting;

@property (weak, nonatomic) IBOutlet RefreshTableView *tableViewConfirm;

@property (weak, nonatomic) IBOutlet RefreshTableView *tableViewRefuse;

@property (weak, nonatomic) IBOutlet RefreshTableView *tableViewOver;

@end
