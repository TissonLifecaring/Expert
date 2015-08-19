//
//  UIImage+Compress.h
//  SugarNursing
//
//  Created by Ian on 15/6/10.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compress)

- (NSData *)compressImageToTargetMemory:(NSInteger)targetMemory;

- (UIImage *)compressImageToWidth:(float)width height:(float)height;


@end
