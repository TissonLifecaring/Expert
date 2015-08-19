//
//  EffectValueCell.h
//  SugarNursing
//
//  Created by Ian on 15-1-21.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"

@interface EffectValueCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CustomLabel *maximumValue;
@property (weak, nonatomic) IBOutlet CustomLabel *minimumValue;
@property (weak, nonatomic) IBOutlet CustomLabel *evaluateType;

@end
