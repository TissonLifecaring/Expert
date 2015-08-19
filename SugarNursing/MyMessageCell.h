//
//  MyMessageCell.h
//  SugarNursing
//
//  Created by Ian on 14-12-4.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMessageCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *msgImageView;

@property (weak, nonatomic) IBOutlet UILabel *msgTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgDetailLabel;

@property (weak, nonatomic) IBOutlet UILabel *msgDateLabel;

@end
