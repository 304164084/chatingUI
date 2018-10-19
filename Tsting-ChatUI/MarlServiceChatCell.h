//
//  MarlServiceChatCell.h
//  Tsting-ChatUI
//
//  Created by bonlion on 2018/9/21.
//  Copyright © 2018 dasui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSString *const MarlServiceChatCellID;

/** 聊天角色类型 */
typedef NS_ENUM(NSUInteger, MarlChatRoleType) {
    /** 聊天角色客服/非服务端 */
    MarlChatRoleTypeCustomer = 0,
    /** 聊天角色客户端/用户 */
    MarlChatRoleTypeUser = 1,
};

@interface MarlServiceChatCell : UITableViewCell

/** content */
@property (nonatomic, copy) NSString *content;
/** 聊天角色类型 */
@property (nonatomic, assign) MarlChatRoleType roleType;

@end

NS_ASSUME_NONNULL_END
