//
//  UzysAssetsViewCell.m
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 12..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

// 版权属于原作者
// http://code4app.com(cn) http://code4app.net(en)
// 来源于最专业的源码分享网站: Code4App

#import "UzysAssetsViewCell.h"
@interface UzysAssetsViewCell()
@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *videoImage;

@property (nonatomic, strong) UIButton *checkButton;
@end


@implementation UzysAssetsViewCell

static UIFont *videoTimeFont = nil;

static CGFloat videoTimeHeight;
static UIImage *videoIcon;
static UIColor *videoTitleColor;
static UIImage *checkedIcon;
static UIImage *uncheckedIcon;
static UIColor *selectedColor;

+ (void)initialize
{
    videoTitleColor      = [UIColor whiteColor];
    videoTimeFont       = [UIFont systemFontOfSize:12];
    videoTimeHeight     = 20.0f;
    videoIcon       = [UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_assets_video"];
    
//    checkedIcon     = [UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_photo_thumb_check"];
//    
//    uncheckedIcon = [UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_photo_thumb_uncheck"];
    
    selectedColor   = [UIColor colorWithWhite:1 alpha:0.3];
}

- (void)checkButtonClickEvent:(id)sender
{
        if(self.isSelect)
        {
            [self setNeedsDisplay];
            
            self.isSelect = NO;
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction animations:^{
                self.transform = CGAffineTransformMakeScale(1.03, 1.03);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 delay:0. options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
                    self.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    
                }];
            }];
            
            
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(uzysAssetsViewCell:didClickSmallButton:)])
            {
                [self.delegate uzysAssetsViewCell:self didClickSmallButton:sender];
            }
        }
        else
        {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(uzysAssetsViewCell:shouldSelectItemWithButton:)])
            {
                
                if ([self.delegate uzysAssetsViewCell:self shouldSelectItemWithButton:self.checkButton])
                {
                    
                    [self setNeedsDisplay];
                    
                    self.isSelect = YES;
                    
                    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction animations:^{
                        self.transform = CGAffineTransformMakeScale(0.97, 0.97);
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
                            self.transform = CGAffineTransformIdentity;
                        } completion:^(BOOL finished) {
                            
                        }];
                    }];
                    
                    
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(uzysAssetsViewCell:didClickSmallButton:)])
                    {
                        [self.delegate uzysAssetsViewCell:self didClickSmallButton:sender];
                    }
                    
                }
            }
        }
        
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.opaque = YES;
        
        self.checkButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [self.checkButton addTarget:self action:@selector(checkButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.checkButton setCenter:CGPointMake([self itemWidthHeight] - self.checkButton.bounds.size.width/2 -2, self.checkButton.bounds.size.height/2)];
        [self addSubview:self.checkButton];
    }
    return self;
}


- (CGFloat)itemWidthHeight
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
        [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown)
    {
        return rect.size.width/3 - 3;
    }
    else
    {
        return rect.size.height/3 - 3;
    }
}

- (void)applyData:(ALAsset *)asset
{
    self.asset  = asset;
    self.image  = [UIImage imageWithCGImage:asset.thumbnail];
    self.type   = [asset valueForProperty:ALAssetPropertyType];
    self.title  = [UzysAssetsViewCell getTimeStringOfTimeInterval:[[asset valueForProperty:ALAssetPropertyDuration] doubleValue]];
    
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
}


- (void)drawRect:(CGRect)rect
{
    
    
    // Image
    [self.image drawInRect:CGRectMake(0, 0, [self itemWidthHeight], [self itemWidthHeight])];
    
    // Video title
    if ([self.type isEqual:ALAssetTypeVideo])
    {
        // Create a gradient from transparent to black
        CGFloat colors [] =
        {
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.8,
            0.0, 0.0, 0.0, 1.0
        };
        
        CGFloat locations [] = {0.0, 0.75, 1.0};
        
        CGColorSpaceRef baseSpace   = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient      = CGGradientCreateWithColorComponents(baseSpace, colors, locations, 2);
        CGContextRef context    = UIGraphicsGetCurrentContext();
        
        CGFloat height          = rect.size.height;
        CGPoint startPoint      = CGPointMake(CGRectGetMidX(rect), height - videoTimeHeight);
        CGPoint endPoint        = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
        
        NSDictionary *attributes = @{NSFontAttributeName:videoTimeFont,NSForegroundColorAttributeName:videoTitleColor};
        CGSize titleSize        = [self.title sizeWithAttributes:attributes];
        [self.title drawInRect:CGRectMake(rect.size.width - (NSInteger)titleSize.width - 2 , startPoint.y + (videoTimeHeight - 12) / 2, [self itemWidthHeight], height) withAttributes:attributes];
        
        [videoIcon drawAtPoint:CGPointMake(2, startPoint.y + (videoTimeHeight - videoIcon.size.height) / 2)];
    }
    
    if (self.isSelect)
    {
//        CGContextRef context    = UIGraphicsGetCurrentContext();
//		CGContextSetFillColorWithColor(context, selectedColor.CGColor);
//		CGContextFillRect(context, rect);
//        [checkedIcon drawAtPoint:CGPointMake(CGRectGetMaxX(rect) - checkedIcon.size.width -2, CGRectGetMinY(rect)+2)];
        
//        uncheckedIcon = [UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_photo_thumb_uncheck"];
        
        
        [self.checkButton setImage:[UIImage imageNamed:@"imageSelect_1"]
                          forState:UIControlStateNormal];

    }
    else
    {
//        [uncheckedIcon drawAtPoint:CGPointMake(CGRectGetMaxX(rect) - uncheckedIcon.size.width -2, CGRectGetMinY(rect)+2)];
//        uncheckedIcon = [UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_photo_thumb_check"];
        
        
        
        [self.checkButton setImage:[UIImage imageNamed:@"imageSelect_0"]
                          forState:UIControlStateNormal];
    }
}


+ (NSString *)getTimeStringOfTimeInterval:(NSTimeInterval)timeInterval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *dateRef = [[NSDate alloc] init];
    NSDate *dateNow = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:dateRef];
    
    unsigned int uFlags =
    NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit |
    NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;

    
    NSDateComponents *components = [calendar components:uFlags
                                               fromDate:dateRef
                                                 toDate:dateNow
                                                options:0];
    NSString *retTimeInterval;
    if (components.hour > 0)
    {
        retTimeInterval = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)components.hour, (long)components.minute, (long)components.second];
    }
    
    else
    {
        retTimeInterval = [NSString stringWithFormat:@"%ld:%02ld", (long)components.minute, (long)components.second];
    }
    return retTimeInterval;
}


@end
