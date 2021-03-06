//
//  WXOConversationListViewController.h
//  TAEDemo
//
//  Created by Jai Chen on 14/12/24.
//  Copyright (c) 2014年 taobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YWConversation;
@class YWIMCore;
@class YWIMKit;


@interface YWConversationListViewController : UITableViewController

/**
 *  创建一个会话列表Controller
 *  @param aIMKit kit对象
 */
+ (instancetype)makeControllerWithIMKit:(YWIMKit *)aIMKit;


/**
 *  IMKit对象的弱引用
 */
@property (nonatomic, weak, readonly) YWIMKit *kitRef;


/**
 *  选中某个会话后的回调
 *  @param aConversation 被选中的会话
 */
typedef void(^YWConversationsListDidSelectItemBlock)(YWConversation *aConversation);

/**
 *  选中某个会话后的回调
 */
@property (nonatomic, copy, readonly) YWConversationsListDidSelectItemBlock didSelectItemBlock;

/**
 *  设置选中某个会话后的回调
 */
- (void)setDidSelectItemBlock:(YWConversationsListDidSelectItemBlock)didSelectItemBlock;

@end
