//
//  AgentMsg.h
//  SugarNursing
//
//  Created by Ian on 15-2-6.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AgentMsg : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * messageType;
@property (nonatomic, retain) NSString * noticeId;
@property (nonatomic, retain) NSString * readFlag;
@property (nonatomic, retain) NSString * readTime;
@property (nonatomic, retain) NSString * sendTime;
@property (nonatomic, retain) NSString * sendUser;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * userId;

@end
