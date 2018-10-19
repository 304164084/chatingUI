//
//  MarlServiceChatInputView.h
//  Tsting-ChatUI
//
//  Created by bonlion on 2018/9/20.
//  Copyright © 2018 dasui. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ButtonClickBlock)(NSInteger index);
typedef void(^ReturnClickBlock)(NSString *result);
NS_ASSUME_NONNULL_BEGIN

@interface MarlServiceChatInputView : UIView
/** 获取 textview输入的内容 */
@property (nonatomic,copy)NSString *result;
- (void)setIsBecomeFirstResponder:(BOOL)isBecomeFirstResponder;
@end

NS_ASSUME_NONNULL_END
