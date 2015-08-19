//
//  UIImage+Compress.m
//  SugarNursing
//
//  Created by Ian on 15/6/10.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "UIImage+Compress.h"

@implementation UIImage (Compress)


- (NSData *)compressImageToTargetMemory:(NSInteger)targetMemory
{
    NSData *data = UIImageJPEGRepresentation(self, 1.0);
    NSInteger memory = data.length/1024;
    if (memory <targetMemory)
    {
        return data;
    }
    else
    {
        
        data = UIImageJPEGRepresentation(self, 0.5);
        if (data.length/1024 > targetMemory)
        {
            
            data = UIImageJPEGRepresentation(self, 0.01);
            if (data.length/1024 > targetMemory)
            {
                
                UIImage *compressImage = [self compressImageToWidth:self.size.width/2 height:self.size.height/2];
                NSData *compressData = UIImageJPEGRepresentation(compressImage, 0.01);
                while (compressData.length/1024 > targetMemory)
                {
                    compressImage = [compressImage compressImageToWidth:compressImage.size.width/2 height:compressImage.size.height/2];
                    compressData = UIImageJPEGRepresentation(compressImage, 0.01);
                }
                
                return compressData;
            }
            
        }
        
    }
    
    return data;
}


- (UIImage *)compressImageToWidth:(float)width height:(float)height
{
    float imageWidth = self.size.width;
    float imageHeight = self.size.height;
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [self drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [self drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

@end
