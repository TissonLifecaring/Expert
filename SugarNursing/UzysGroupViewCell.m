//
//  uzysGroupViewCell.m
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 13..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

// 版权属于原作者
// http://code4app.com(cn) http://code4app.net(en)
// 来源于最专业的源码分享网站: Code4App

#import "UzysAssetsPickerController_Configuration.h"
#import "UzysGroupViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation UzysGroupViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        self.textLabel.font = [UIFont systemFontOfSize:17];
//        self.detailTextLabel.font = [UIFont systemFontOfSize:17];
//        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_checkMark"]];
        self.selectedBackgroundView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if(selected)
    {
        self.accessoryView.hidden = NO;
    }
    else
    {
        self.accessoryView.hidden = YES;
    }
}


- (void)applyData:(ALAssetsGroup *)assetsGroup
{
    self.assetsGroup            = assetsGroup;
    
    CGImageRef posterImage      = assetsGroup.posterImage;
//    size_t height               = CGImageGetHeight(posterImage);
    float scale                 = 1;
    
    self.myImageView.image        = [UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp];
    
    NSString *name = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    NSString *number = [NSString stringWithFormat:@"%ld", (long)[assetsGroup numberOfAssets]];
    self.titleLabel.text         = [NSString stringWithFormat:@"%@ ( %@ )",name,number];
    
    self.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
}
@end
