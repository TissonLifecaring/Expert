//
//  RefreshTableView.h
//  SugarNursing
//
//  Created by Ian on 15-4-28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSPullToRefresh.h>

@interface RefreshTableView : UITableView<SSPullToRefreshViewDelegate>

@property (strong, nonatomic) SSPullToRefreshView *refreshView;

@property (weak, nonatomic) id<SSPullToRefreshViewDelegate,UITableViewDelegate> myDelegate;
@end
