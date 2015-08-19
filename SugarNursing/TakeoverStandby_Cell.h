//
//  TakeoverStandby_Cell.h
//  SugarNursing
//
//  Created by Ian on 14-12-10.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface TakeoverStandby_Cell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) id theDelegate;


- (void)configureCellWithContent:(NSAttributedString *)contentString acceptBlock:(void(^)(TakeoverStandby_Cell *cell))block1 refuseBlock:(void(^)(TakeoverStandby_Cell *cell))block2;

@end
