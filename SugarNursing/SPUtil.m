
//  SPUtil.m
//  WXOpenIMSampleDev
//
//  Created by huanglei on 15/4/12.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "SPUtil.h"
#import <MBProgressHUD.h>
#import "UtilsMacro.h"
#import <SDWebImageDownloader.h>
#import <UIImageView+WebCache.h>


@implementation SPUtil

+ (instancetype)sharedInstance
{
    static SPUtil *sUtil = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sUtil = [[SPUtil alloc] init];
    });
    
    return sUtil;
}

- (void)showNotificationInViewController:(UIViewController *)viewController title:(NSString *)title  subtitle:(NSString *)subtitle type:(SPMessageNotificationType)type
{
    /// 我们在Demo中使用了第三方库TSMessage来显示提示信息
    /// 强烈建议您使用自己的提示信息显示方法，以便保持App内风格一致
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    hud.detailsLabelText = subtitle;
    [hud show:YES];
    [hud hide:YES afterDelay:1.2];
}


- (void)getPersonDisplayName:(NSString *__autoreleasing *)aName avatar:(UIImage *__autoreleasing *)aAvatar ofPerson:(YWPerson *)aPerson completeBlock:(void(^)())completeBlock
{
    //自己
    if ([aPerson.personId isEqualToString:[NSString exptId]])
    {
        NSArray *objects = [UserInfomation findAllInContext:[CoreDataStack sharedCoreDataStack].context];
        
        if (objects.count>0)
        {
            UserInfomation *info = objects[0];
            
            if (aName) {
                *aName = info.exptName;
            }
            
            if (aAvatar) {
                
//                UIImageView *imageView = [UIImageView new];
//                [imageView sd_setImageWithURL:[NSURL URLWithString:info.headimageUrl]
//                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                        
//                                        *aAvatar = image;
//                                        completeBlock();
//                                    }];
                *aAvatar = [UIImage imageNamed:@"patientHeadImage"];
                completeBlock();
            }
        }
    }
    //病人
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"otherMappintInfo.otherAccount = %@",aPerson.personId];
        NSArray *objects = [Patient findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context];
        
        if (objects.count>0)
        {
            
            Patient *patient = objects[0];
            
            if (aName) {
                *aName = patient.userName;
            }
            
            if (aAvatar) {
                
//                UIImageView *imageView = [UIImageView new];
//                NSString *imageUrl = patient.headImageUrl;
//                if (!imageUrl || imageUrl.length<=0)  completeBlock();
//                    
//                [imageView sd_setImageWithURL:[NSURL URLWithString:patient.headImageUrl]
//                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                        
//                                        *aAvatar = image;
//                                        completeBlock();
//                                    }];
                
                *aAvatar = [UIImage imageNamed:@"patientHeadImage"];
                completeBlock();
                
            }
        }
    }
}

- (void)getPersonDisplayInfoOfPerson:(YWPerson *)aPerson CompleteBlock:(void(^)(NSString *name, UIImage *image))completeBlock
{
    
    NSString *aName = nil;
    NSString *openIMAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"openIMAccount"];
    //自己
    if ([aPerson.personId isEqualToString:openIMAccount])
    {
        NSArray *objects = [UserInfomation findAllInContext:[CoreDataStack sharedCoreDataStack].context];
        
        if (objects.count>0)
        {
            UserInfomation *info = objects[0];
            
            aName = info.exptName;
            
            NSString *imageUrl = info.headimageUrl;
            if (!imageUrl || imageUrl.length<=0)
            {
                completeBlock(aName, nil);
                return;
            }
            
            UIImageView *imageView = [UIImageView new];
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:info.headimageUrl]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    
                                    completeBlock(aName, image);
                                }];
        }
    }
    //病人
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"otherMappintInfo.otherAccount = %@",aPerson.personId];
        NSArray *objects = [Patient findAllWithPredicate:predicate inContext:[CoreDataStack sharedCoreDataStack].context];
        
        if (objects.count>0)
        {
            
            Patient *patient = objects[0];
            
            aName = patient.userName;
            
//            completeBlock(aName, aImage);
            
            NSString *imageUrl = patient.headImageUrl;
            if (!imageUrl || imageUrl.length<=0)
            {
                UIImage *aImage = [UIImage imageNamed:@"patientHeadImage"];
                completeBlock(aName, aImage);
                return;
            }
            
            UIImageView *imageView = [UIImageView new];
            [imageView sd_setImageWithURL:[NSURL URLWithString:patient.headImageUrl]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    
                                    completeBlock(aName, image);
                                }];
        }
    }
}



@end
