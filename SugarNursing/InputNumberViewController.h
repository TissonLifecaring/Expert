//
//  InputNumberViewController.h
//  SugarNursing
//
//  Created by Ian on 14-12-18.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputNumberViewController : UIViewController
<
UITextFieldDelegate
>

@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *areaCode;

@end
