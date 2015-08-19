//
//  DiseaseInfo_Cell.m
//  SugarNursing
//
//  Created by Ian on 14-12-10.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "DiseaseInfo_Cell.h"
#import <UIImageView+AFNetworking.h>
#import "MediAttach.h"


static CGFloat kCollectionCellWidthHeight = 40.0;

@implementation DiseaseInfo_Cell
- (void)awakeFromNib
{
    
}


- (void)configureCellWithMediRecord:(MediRecord *)mediRecord;
{
    
    self.hospitalLabel.text = [self isEmptyString:mediRecord.diagHosp];
    self.cureConditionLabel.text = [self isEmptyString:mediRecord.treatMent];
    self.medicalHistoryLabel.text = [self isEmptyString:mediRecord.mediRecord];
    self.cureScheme.text = [self isEmptyString:mediRecord.treatPlan];
    
    
    self.record = mediRecord;
    
    NSInteger attCount = mediRecord.mediAttach.count;
    
    
    NSInteger lineNumber;
    if (attCount<=0)
    {
        lineNumber = 0;
    }
    else if (attCount<=4)
    {
        lineNumber = 1;
    }
    else
    {
        lineNumber = 2;
    }
    
    self.collectionViewConstraintHeight.constant = lineNumber * kCollectionCellWidthHeight + 10;

    [self.collectionView reloadData];
}


- (NSString *)isEmptyString:(NSString *)string
{
    
    if (!string || string.length <= 0)
    {
        return NSLocalizedString(@"None", nil);
    }
    
    return string;
}


#pragma mark - UICollectionView DataSource & Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.record.mediAttach.count;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ImageCell";
    
    NSOrderedSet *attArray = self.record.mediAttach;
    MediAttach *attach = attArray[indexPath.row];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UIImageView *attImageView = (UIImageView *)[cell viewWithTag:101];
    [attImageView setImage:nil];
    [attImageView setImageWithURL:[NSURL URLWithString:attach.attachPath] placeholderImage:nil];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.theDelegate diseaseInfoCell:self didTapImageViewAtIndex:indexPath.row];
}


@end
