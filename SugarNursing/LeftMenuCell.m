//
//  LeftMenuCell.m
//  SugarNursing
//
//  Created by Dan on 14-11-5.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import "LeftMenuCell.h"
#import "MsgRemind.h"
#import "CoreDataStack.h"
#import "M13BadgeView.h"
#import "VendorMacro.h"


@implementation LeftMenuCell

- (void)configureCellWithIndexPath:(NSIndexPath *)indexPath iconName:(NSString *)iconName LabelText:(NSString *)labelText
{
    self.LeftMenuIcon.image = [UIImage imageNamed:iconName];
    self.LeftMenuLabel.text = labelText;
    
    
    [self configureBadgeMessageViewWithIndexPath:indexPath labelText:labelText];
    
    
//    [self showMsgPointWithLabelText:labelText];
}


- (void)configureBadgeMessageViewWithIndexPath:(NSIndexPath *)indexPath labelText:(NSString *)labelText
{
    NSInteger count = 0;
    
    MsgRemind *remind = [MsgRemind shareMsgRemind];
    
    if ([labelText isEqualToString:NSLocalizedString(@"My Hosting", nil)])
    {
        count = [remind.hostingConfirmRemindCount integerValue] + [remind.hostingRefuseRemindCount integerValue];
        [self addBadgeViewWithMessageCount:count];
    }
    else if ([labelText isEqualToString:NSLocalizedString(@"My Takeover", nil)])
    {
        count = [remind.takeoverWaittingRemindCount integerValue];
        [self addBadgeViewWithMessageCount:count];
    }
    else if ([labelText isEqualToString:NSLocalizedString(@"My Message", nil)])
    {
        count = [remind.messageAgentRemindCount integerValue] + [remind.messageApproveRemindCount integerValue] + [remind.messageBulletinRemindCount integerValue];
        [self addBadgeViewWithMessageCount:count];
    }
    else
    {
        [self addBadgeViewWithMessageCount:count];
    }
}

- (void)addBadgeViewWithMessageCount:(NSInteger)count
{
    
    M13BadgeView *_badgeView = (M13BadgeView *)[self.LeftMenuLabel viewWithTag:BADGE_VIEW_TAG];
    
    if (!_badgeView)
    {
        
        NSInteger badgeWidthHeitght = 20.0;
        
        _badgeView = [[M13BadgeView alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    badgeWidthHeitght,
                                                                    badgeWidthHeitght)];
        _badgeView.tag = BADGE_VIEW_TAG;
        _badgeView.hidesWhenZero = YES;
        [self.LeftMenuLabel addSubview:_badgeView];
        
        _badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
        _badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentMiddle;
    }
    
    _badgeView.text = [NSString stringWithFormat:@"%ld",count];
}

//- (void)showMsgPointWithLabelText:(NSString *)labelText
//{
//
//    MsgRemind *remind = [MsgRemind shareMsgRemind];
//    
//    if ([labelText isEqualToString:NSLocalizedString(@"My Hosting", nil)])
//    {
//        if ([remind.hostingConfirmRemindCount integerValue]>0 || [remind.hostingRefuseRemindCount integerValue]>0)
//        {
//            self.leftMenuMsgPoint.hidden = NO;
//        }
//        else
//        {
//            self.leftMenuMsgPoint.hidden = YES;
//        }
//    }
//    else if ([labelText isEqualToString:NSLocalizedString(@"My Takeover", nil)])
//    {
//        self.leftMenuMsgPoint.hidden = [remind.takeoverWaittingRemindCount integerValue]>0 ? NO : YES;
//    }
//    else if ([labelText isEqualToString:NSLocalizedString(@"My Message", nil)])
//    {
//        BOOL showMsgPoint = ([remind.messageApproveRemindCount integerValue]>0 ||
//                             [remind.messageAgentRemindCount integerValue]>0   ||
//                             [remind.messageBulletinRemindCount integerValue]>0);
//        if (showMsgPoint)
//        {
//            self.leftMenuMsgPoint.hidden = NO;
//        }
//        else
//        {
//            self.leftMenuMsgPoint.hidden = YES;
//        }
//    }
//}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
