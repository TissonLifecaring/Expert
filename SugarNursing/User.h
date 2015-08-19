//
//  User.h
//  SugarNursing
//
//  Created by Ian on 15-1-4.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * exptId;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSString * sessionToken;
@property (nonatomic, retain) NSString * username;

@end
