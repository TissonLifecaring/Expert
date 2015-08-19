//
//  ReportList_Cell.m
//  SugarNursing
//
//  Created by Ian on 15/6/1.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "ReportList_Cell.h"
#import "DeviceHelper.h"

@implementation ReportList_Cell


- (void)configureCellWithParameter:(NSDictionary *)parameters indexPath:(NSIndexPath *)indexPath
{
    [self.reportTitleLabel setFont:[UIFont systemFontOfSize:[DeviceHelper biggestFontSize]]];
    [self.reportContentLabel setFont:[UIFont systemFontOfSize:[DeviceHelper normalFontSize]]];
    [self.reportTitleLabel setText:parameters[@"title"]];
    [self.reportContentLabel setText:parameters[@"content"]];
    
    if (!self.longPressGestureRecognizer)
    {
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesEvent:)];
        [self.contentView addGestureRecognizer:self.longPressGestureRecognizer];
    }
}

- (void)longPressGesEvent:(UIGestureRecognizer *)ges
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(reportListCellHadBeenLongPress:)])
    {
        [self.delegate reportListCellHadBeenLongPress:self];
    }
}


@end
