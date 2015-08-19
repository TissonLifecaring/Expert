//
//  MemberInfoCell.h
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbnailImageView.h"

@interface MemberInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ThumbnailImageView *MemberInfoBG;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userSexLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAgeLabel;

@end
