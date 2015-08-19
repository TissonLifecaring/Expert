//
//  NSManagedObject+Savers.h
//  SugarNursing
//
//  Created by Dan on 14-12-29.
//  Copyright (c) 2014年 Tisson. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Savers)



- (void)updateCoreDataForData:(NSDictionary *)data withKeyPath:(NSString *)keyPath;

+ (void)coverCoreDataWithArray:(NSArray *)array;


#pragma mark 用于存放拥有唯一标识的数据, 标识重复时会覆盖
+ (void)updateCoreDataWithListArray:(NSArray *)array identifierKey:(NSString *)identifierKey;

#pragma mark 持久化手段(当返回数组的最后一个元素不存在与本地数据库时,则先删除本地数据再重新添加,避免本地数据跟后台不同步)
+ (void)synchronizationDataWithListArray:(NSArray *)array identifierKey:(NSString *)identifierKey;
@end
