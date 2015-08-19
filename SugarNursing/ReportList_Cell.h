//
//  ReportList_Cell.h
//  SugarNursing
//
//  Created by Ian on 15/6/1.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinesLabel.h"

@class ReportList_Cell;
@protocol ReportListDelegate <NSObject>

- (void)reportListCellHadBeenLongPress:(ReportList_Cell *)cell;

@end

@interface ReportList_Cell : UITableViewCell


@property (strong, nonatomic) IBOutlet LinesLabel *reportTitleLabel;

@property (strong, nonatomic) IBOutlet LinesLabel *reportContentLabel;

@property (weak, nonatomic) id<ReportListDelegate> delegate;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

- (void)configureCellWithParameter:(NSDictionary *)parameters indexPath:(NSIndexPath *)indexPath;

@end
