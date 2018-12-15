//
//  MarlChatTextView.h
//  Tsting-ChatUI
//
//  Created by bonlion on 2018/9/20.
//  Copyright © 2018 dasui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TextHeightChangedBlock)(CGFloat textHeight);

@interface MarlServiceChatTextView : UITextView
/** textView最大行数 */
@property (nonatomic, assign) NSUInteger maxNumberOfLines;
/** 文字大小 */
@property (nonatomic, strong) UIFont *textFont;
/**
 *  文字高度改变block → 文字高度改变会自动调用
 *  block参数(textHeight) → 文字高度
 */
@property (nonatomic, strong) TextHeightChangedBlock textChangedBlock;

- (void)textValueDidChanged:(TextHeightChangedBlock)block;
@end

NS_ASSUME_NONNULL_END
