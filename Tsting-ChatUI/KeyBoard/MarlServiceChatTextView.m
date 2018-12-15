//
//  MarlChatTextView.m
//  Tsting-ChatUI
//
//  Created by bonlion on 2018/9/20.
//  Copyright © 2018 dasui. All rights reserved.
//

#import "MarlServiceChatTextView.h"

CGFloat const defaultTextFont = 25.f;
@interface MarlServiceChatTextView ()
/** 文字最大高度 */
@property (nonatomic, assign) CGFloat maxTextH;
@end

@implementation MarlServiceChatTextView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        if (!self.textFont) {
            self.textFont = [UIFont systemFontOfSize:defaultTextFont];
        }
        [self setupPropertys];
    }
    return self;
}
- (instancetype)init {
    if (self = [super init]) {
        if (!self.textFont) {
            self.textFont = [UIFont systemFontOfSize:defaultTextFont];
        }
        [self setupPropertys];
    }
    return self;
}
- (void)setupPropertys {
    self.scrollEnabled = NO;
    self.scrollsToTop = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.enablesReturnKeyAutomatically = YES;
    //实时监听textView值得改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChanged) name:UITextViewTextDidChangeNotification object:self];
}
// MARK: - receive notify
- (void)textDidChanged {
    //计算高度
    CGFloat height = ceilf([self sizeThatFits:CGSizeMake(self.frame.size.width, MAXFLOAT)].height);
    if (height > _maxTextH) {
        height = _maxTextH;
        self.scrollEnabled = YES;   //当textView大于最大高度的时候让其可以滚动
    } else {
        self.scrollEnabled = NO;
        if (_textChangedBlock && self.scrollEnabled == NO) {
            _textChangedBlock(height);
        }
    }
//    [self setNeedsLayout];
//    [self layoutIfNeeded];
}
// MARK: - limit max line height
- (void)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines {
    _maxNumberOfLines = maxNumberOfLines;
    /**
     *  根据最大的行数计算textView的最大高度
     *  计算最大高度 = (每行高度 * 总行数 + 文字上下间距)
     */
    _maxTextH = ceil(self.font.lineHeight * maxNumberOfLines + self.textContainerInset.top + self.textContainerInset.bottom);
}
// MARK: - text view height changed handler func
- (void)textValueDidChanged:(TextHeightChangedBlock)block {
    _textChangedBlock = block;
}
// MARK: - 移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}
@end
