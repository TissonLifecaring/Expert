//
//  UzysAssetsViewCell.h
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 12..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

// 版权属于原作者
// http://code4app.com(cn) http://code4app.net(en)
// 来源于最专业的源码分享网站: Code4App

#import <UIKit/UIKit.h>
#import "UzysAssetsPickerController_Configuration.h"

@class UzysAssetsViewCell;
@protocol UzysAssetsViewCellDelegate <NSObject>

- (void)uzysAssetsViewCell:(UzysAssetsViewCell *)cell didClickSmallButton:(UIButton *)button;
@optional
- (BOOL)uzysAssetsViewCell:(UzysAssetsViewCell *)cell shouldSelectItemWithButton:(UIButton *)button;
@end

@interface UzysAssetsViewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, strong) UIImage *image;

@property (weak, nonatomic) id<UzysAssetsViewCellDelegate> delegate;
- (void)applyData:(ALAsset *)asset;
@end
