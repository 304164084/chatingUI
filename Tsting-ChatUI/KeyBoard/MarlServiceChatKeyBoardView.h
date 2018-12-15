//
//  MarlChatKeyBoardView.h
//  Tsting-ChatUI
//
//  Created by bonlion on 2018/9/20.
//  Copyright © 2018 dasui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSString *const KeyBoardWillHiddenNotify;

@protocol MarlServiceChatKeyBoardDelegate <NSObject>
@optional
/**
 点击发送时输入框内的文案
 @param textStr 文案
 */
- (void)keyboardSendTextMessage:(NSString *)textStr;
- (void)keyboardSendImageMessage:(UIImage *)image;
//keyboardSendMessage
/**
 键盘的frame改变
 */
- (void)keyboardChangedFrameWithMinY:(CGFloat)minY;

@end

@interface MarlServiceChatKeyBoardView : UIView
/** delegate */
@property (nonatomic, weak) id<MarlServiceChatKeyBoardDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
