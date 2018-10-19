//
//  MarlServiceChatInputView.m
//  Tsting-ChatUI
//
//  Created by bonlion on 2018/9/20.
//  Copyright © 2018 dasui. All rights reserved.
//

#import "MarlServiceChatInputView.h"

@interface MarlServiceChatInputView ()<UITextViewDelegate>

/** text view */
@property (nonatomic, strong) UITextView *textView;
/** more actions button */
@property (nonatomic, strong) UIButton *moreActionsButton;
/** 原始 frame */
@property (nonatomic, assign) CGRect originalFrame;
/** 按钮回调 */
@property (nonatomic,copy)ButtonClickBlock callBack;
/** 点击return */
@property (nonatomic,copy)ReturnClickBlock returnClickCallBack;

@property (nonatomic, assign)CGFloat textInputHeight;
@end

@implementation MarlServiceChatInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.originalFrame = frame;
        [self setupDefaultPropertys];
        [self addNotifications];
        [self setupViews];
    }
    return self;
}
// MARK: - 初始化时的默认属性
- (void)setupDefaultPropertys
{
    self.backgroundColor = [UIColor whiteColor];
    
}
// MARK: - 注册通知
- (void)addNotifications
{
    // 监听键盘frame即将改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
// MARK: - UI
- (void)setupViews
{
    // more action button
    _moreActionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // FIXME: - 填充图片
    [_moreActionsButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    // FIXME: - 图片填充后删掉此行
    [_moreActionsButton setTitle:@"更多" forState:UIControlStateNormal];
    [_moreActionsButton addTarget:self action:@selector(actionMoreOperations:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_moreActionsButton];
    [_moreActionsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self).offset(-16.f);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(28.f, 28.f));
    }];
    
    // textView
    _textView = [UITextView new];
    _textView.layer.cornerRadius = 8.f;
    _textView.layer.borderWidth = 0.5f;
    _textView.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1].CGColor;
    _textView.layer.masksToBounds = YES;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.returnKeyType = UIReturnKeySend;
    _textView.enablesReturnKeyAutomatically = YES;
    _textView.delegate = self;
    _textView.scrollEnabled = NO;
    _textView.scrollsToTop = NO;
    _textView.showsHorizontalScrollIndicator = NO;
//    _textView.enablesReturnKeyAutomatically = YES;
    _textView.font = [UIFont systemFontOfSize:14];
    [self addSubview:_textView];
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(7.f);
        make.leading.mas_equalTo(self.mas_leading).offset(16.f);
        make.trailing.mas_equalTo(self.moreActionsButton.mas_leading).offset(-12.f);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-6.f);
//        make.height.greaterThanOrEqualTo(@(36.f)).priorityMedium();
    }];
    
    
    
}
// MARK: - 接收通知
- (void)keyboardWillChangeFrame:(NSNotification *)note
{
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame = self.frame;
    frame.origin.y = endFrame.origin.y - frame.size.height;
    self.originalFrame = frame;
    
    [UIView animateWithDuration:duration animations:^{
        self.frame = frame;
    }];
}
// MARK: - more action 按钮操作
- (void)actionMoreOperations:(UIButton *)button
{
    
}

// MARK: - textView delegate
- (void)textViewDidChange:(UITextView *)textView
{
    self.result = textView.text;
    
    CGFloat height = ceilf([self sizeThatFits:CGSizeMake(self.frame.size.width, MAXFLOAT)].height);
    
    self.textView.height = height;
    self.y = self.y - (height + 13 - self.height);
    self.height = height + 13;
//    CGRect frame = self.frame;
//    frame.size.height = height;
 
//    self.frame = frame;
//    [textView scrollRangeToVisible:NSMakeRange(0, 0)];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {//判断输入的字是否是回车，即按下return
        if (self.returnClickCallBack) {
            self.returnClickCallBack(textView.text);
        }
        self.textView.text = nil;
        self.result = @"";
        [self textViewDidChange:self.textView];
        return NO;
    }
    
    return YES;
}
// MARK: - 销毁通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)setIsBecomeFirstResponder:(BOOL)isBecomeFirstResponder
{
    if (isBecomeFirstResponder) {
        [self.textView becomeFirstResponder];
    } else {
        [self.textView resignFirstResponder];
    }
}

@end
