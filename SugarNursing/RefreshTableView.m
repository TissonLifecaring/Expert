//
//  RefreshTableView.m
//  SugarNursing
//
//  Created by Ian on 15-4-28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "RefreshTableView.h"

@implementation RefreshTableView


- (void)awakeFromNib
{
    self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self delegate:self.myDelegate];
}


- (void)setDelegate:(id<UITableViewDelegate,SSPullToRefreshViewDelegate>)delegate
{
    [super setDelegate:delegate];
    [self.refreshView setDelegate:delegate];
    self.myDelegate = delegate;
}

@end
