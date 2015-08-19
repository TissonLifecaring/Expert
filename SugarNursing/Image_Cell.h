//
//  Image_Cell.h
//  SugarNursing
//
//  Created by Ian on 15/5/28.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Image_Cell;
@protocol ImageCellDelegate <NSObject>

- (void)imageCellDidTapDeleteButton:(Image_Cell *)cell;

- (void)imageCellDidTapImageButton:(Image_Cell *)cell;
@end

@interface Image_Cell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIButton *imageButton;

@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) id<ImageCellDelegate> delegate;

@end
