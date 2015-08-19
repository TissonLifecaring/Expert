//
//  Bulletin.h
//  SugarNursing
//
//  Created by Ian on 15-1-23.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Bulletin : NSManagedObject

@property (nonatomic, retain) NSString * bulletinId;
@property (nonatomic, retain) NSString * centerId;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * messageType;
@property (nonatomic, retain) NSString * orgId;
@property (nonatomic, retain) NSString * sendTime;
@property (nonatomic, retain) NSString * sendUser;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;

@end
