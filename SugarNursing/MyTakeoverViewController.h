//
//  MyTakeoverViewController.h
//  SugarNursing
//
//  Created by Ian on 14-12-30.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshTableView.h"

typedef NS_ENUM(NSInteger, RefreshTableViewFlag)
{
    RefreshTableViewFlagWaitting = 1,
    RefreshTableViewFlagConfirm = 2,
    RefreshTableViewFlagRefuse = 4,
    RefreshTableViewFlagOver = 3
};


@interface MyTakeoverViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
UITabBarDelegate
>


@property (weak, nonatomic) IBOutlet UITabBar *myTabBar;

@property (weak, nonatomic) IBOutlet RefreshTableView *tableViewWaitting;

@property (weak, nonatomic) IBOutlet RefreshTableView *tableViewConfirm;

@property (weak, nonatomic) IBOutlet RefreshTableView *tableViewRefuse;

@property (weak, nonatomic) IBOutlet RefreshTableView *tableViewOver;

@end
