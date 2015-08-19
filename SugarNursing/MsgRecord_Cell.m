//
//  MsgRecord_Cell.m
//  糖博士
//
//  Created by Ian on 14-11-11.
//  Copyright (c) 2014年 Ian. All rights reserved.
//

#import "MsgRecord_Cell.h"


static CGFloat kLineOriginY = 30;


@implementation MsgRecord_Cell
@synthesize timeLabel;


- (void)configureCellWithModel:(id)model delegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)theDelegate;
{
    Advice *advice = (Advice *)model;
    [self.contentLabel setText:advice.content];
    [self.timeLabel setText:advice.adviceTime];
    [self.detailLabel setText:advice.exptName];
    
    
    self.myCollectView.delegate = theDelegate;
    self.myCollectView.dataSource = theDelegate;
    
    if (advice.adviceAttach.count > 0)
    {
        self.collectViewHeightConstraint.constant = 50;
        self.contentLabelBottomConstraint.constant = 70;
    }
    else
    {
        self.collectViewHeightConstraint.constant = 0;
        self.contentLabelBottomConstraint.constant = 12;
    }
    
    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];
}



- (void)drawLine
{
    UIGraphicsBeginImageContext(self.frame.size);
    
    UIBezierPath *path = [self setupBezierPath];
    CAShapeLayer *layer= [self setupShapeLayer];
    
    [self.layer addSublayer:layer];
    
    [path moveToPoint:CGPointMake(30, kLineOriginY)];
    
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - 30, kLineOriginY)];
    
    layer.path = path.CGPath;
    
    
    UIGraphicsEndImageContext();
}


- (UIBezierPath *)setupBezierPath
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineWidth = 0.2;
    return path;
}

- (CAShapeLayer *)setupShapeLayer
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [[UIColor blackColor] CGColor];
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineWidth = 0.2;
    shapeLayer.strokeColor = [[UIColor blackColor] CGColor];
    shapeLayer.strokeEnd = 1;
    return shapeLayer;
}

@end
