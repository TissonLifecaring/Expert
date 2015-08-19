//
//  MessageInfoViewController.h
//  SugarNursing
//
//  Created by Ian on 14-12-24.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MsgType)
{
    MsgTypeApprove = 0,
    MsgTypeBulletin = 1,
    MsgTypeAgent = 2
};

@interface MessageInfoViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (assign, nonatomic) MsgType msgType;


@end
