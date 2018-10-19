//
//  MarlChatKeyBoardView.m
//  Tsting-ChatUI
//
//  Created by bonlion on 2018/9/20.
//  Copyright © 2018 dasui. All rights reserved.
//

#import "MarlChatKeyBoardView.h"
#import "MarlChatTextView.h"
#import "MarlChatMoreOperationsView.h"

NSString *const KeyBoardWillHiddenNotify = @"keyboardHide";

CGFloat const subviewsHeight = 36.f;
CGFloat const space = 8.f; //按钮距离上边距
CGFloat const btnHeight = 28.f;
CGFloat const textViewHeight = 36.f;
CGFloat const moreOperationsViewHeight = 200.f;

@interface MarlChatKeyBoardView ()<UITextViewDelegate>
/** container view */
@property (nonatomic, strong) UIView *containerView;
/** text view */
@property (nonatomic, strong) MarlChatTextView *textView;
/** more operations view */
@property (nonatomic, strong) MarlChatMoreOperationsView *moreOperationsView;
/** more button */
@property (nonatomic, strong) UIButton *moreButton;
/** more button state */
@property (nonatomic, assign) BOOL moreButtonClicked;

@end

@implementation MarlChatKeyBoardView

- (instancetype)init
{
    if (self = [super init]) {
        [self addNotifications];
        [self setupViews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addNotifications];
        [self setupViews];
    }
    return self;
}

// MARK: - register notify
- (void)addNotifications
{
    //监听键盘出现
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //监听键盘消失
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //此通知主要是为了获取点击空白处回收键盘的处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide) name:KeyBoardWillHiddenNotify object:nil];

}
// MARK: - UI
- (void)setupViews
{
    CGFloat margin = 16.f;
    CGFloat viewMargin = 12.f;

    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.mas_equalTo(self);
    }];
    
    // 加号按钮
    [self.containerView addSubview:self.moreButton];
    
    //输入视图
    [self.containerView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.containerView).offset(margin);
        make.trailing.mas_equalTo(self.moreButton.mas_leading).offset(-viewMargin);
//        make.centerY.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.containerView).offset(space);
        make.bottom.mas_equalTo(self.containerView).offset(-space);
        // 加一个初始高度
        make.height.mas_equalTo(@(textViewHeight));
    }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@(btnHeight));
        make.height.mas_equalTo(@(btnHeight));
        make.bottom.mas_equalTo(self.textView);
        make.trailing.mas_equalTo(self.containerView).offset(-margin);
    }];
}

// MARK: - 更改高度 & 响应代理
- (void)changeFrame:(CGFloat)height
{
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(height));
    }];
    [self.containerView setNeedsLayout];
    [self.containerView layoutIfNeeded];

    [self changeTableViewFrame];
}
// MARK: - 点击空白处，键盘收起时，移动self至底部
- (void)keyboardHide {
    //收起键盘
    [self removeBottomViewFromSupview];
    [self.textView resignFirstResponder];

    [UIView animateWithDuration:0.25 animations:^{
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.superview).offset(IS_IPHONE_X ? -Safe_Bottom_Area : 0.f);
        }];
        [self.superview layoutIfNeeded];

        [self changeTableViewFrame];
    }];
}

// MARK: - 接收键盘将要显示的通知
- (void)keyboardWillShow:(NSNotification *)notification
{
    [self removeBottomViewFromSupview];
    
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:duration delay:0 options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] animations:^{
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.superview).offset(-endFrame.size.height);
        }];
        [self.superview layoutIfNeeded];

        [self changeTableViewFrame];
    } completion:nil];
}
// MARK: - 接收键盘即将消失的通知
- (void)keyboardWillHide:(NSNotification *)notification {

    //如果是弹出了底部视图时
    if (self.moreButtonClicked) {
        return;
    }
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

    [UIView animateWithDuration:duration delay:0 options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] animations:^{

        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.superview).offset(IS_IPHONE_X ? -Safe_Bottom_Area : 0.f);
        }];
        [self.superview layoutIfNeeded];

        [self changeTableViewFrame];
    } completion:nil];
}

// MARK: - 改变tableView的frame
- (void)changeTableViewFrame {
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardChangedFrameWithMinY:)]) {
        [self.delegate keyboardChangedFrameWithMinY:self.y];
    }
}

// MARK: - 移除更多操作视图
- (void)removeBottomViewFromSupview {

    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(0.f);
    }];
    [self layoutIfNeeded];
    
    [self.moreOperationsView removeFromSuperview];
    self.moreOperationsView = nil;
    self.moreButtonClicked = NO;
}

// MARK: - 点击发送按钮
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //判断输入的字是否是回车，即按下return
    if ([text isEqualToString:@"\n"]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardSendMessage:)]) {
            [self.delegate keyboardSendMessage:textView.text];
        }
        [self changeFrame:textViewHeight];
        textView.text = @"";
        /*这里返回NO，就代表return键值失效，即页面上按下return，
         不会出现换行，如果为yes，则输入页面会换行*/
        return NO;
    }
    return YES;
}

// MARK: - more button 操作
- (void)actionMoreOperations:(UIButton *)button {
    if (self.moreButtonClicked == NO) {
        self.moreButtonClicked = YES;
        
        [button.layer addAnimation:[self animationRotationZWithToValue:-M_PI_4 fromValue:0.f duration:.5f] forKey:@"transform"];
        //回收键盘
        [self.textView resignFirstResponder];
        [self addSubview:self.moreOperationsView];
        [self.moreOperationsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(@(0.f));
            make.bottom.mas_equalTo(self);
        }];
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self).offset(-moreOperationsViewHeight);
        }];
        [self layoutIfNeeded];

        //改变更多、self的frame
        
        [UIView animateWithDuration:.25 animations:^{

            [self.moreOperationsView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(@(moreOperationsViewHeight));
            }];
            
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.superview).offset(IS_IPHONE_X ? -Safe_Bottom_Area : 0.f);
            }];
            [self layoutIfNeeded];

            [self changeTableViewFrame];
        }];
    } else { //再次点击更多按钮
        //键盘弹起
        [self.textView becomeFirstResponder];
        
        [button.layer addAnimation:[self animationRotationZWithToValue:0 fromValue:-M_PI_4 duration:.5f] forKey:@"transform"];
    }
}
// MARK: - Z轴旋转动画
- (CABasicAnimation *)animationRotationZWithToValue:(CGFloat)toValue fromValue:(CGFloat)fromValue duration:(NSTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    animation.fromValue = [NSNumber numberWithDouble:fromValue];
    animation.toValue = [NSNumber numberWithDouble:toValue];
    animation.duration = duration;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    return animation;
}
// MARK: - lazy load
- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.layer.borderWidth = 1;
        _containerView.layer.borderColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.89 alpha:1.00].CGColor;

    }
    return _containerView;
}

//更多按钮
- (UIButton *)moreButton
{
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setBackgroundImage:[UIImage imageNamed:@"moreImg"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(actionMoreOperations:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (MarlChatTextView *)textView
{
    if (!_textView) {
        _textView = [[MarlChatTextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:16];
        [_textView textValueDidChanged:^(CGFloat textHeight) {
            [self changeFrame:textHeight];
        }];
        _textView.maxNumberOfLines = 5;
        _textView.layer.cornerRadius = 8.f;
        _textView.layer.borderWidth = 1;
        _textView.layer.borderColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.89 alpha:1.00].CGColor;
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeySend;
    }
    return _textView;
}

- (MarlChatMoreOperationsView *)moreOperationsView
{
    if (!_moreOperationsView) {
        _moreOperationsView = [[MarlChatMoreOperationsView alloc] initWithFrame:CGRectZero];
        _moreOperationsView.backgroundColor = [UIColor blueColor];
    }
    return _moreOperationsView;
}
// MARK: - 移除监听
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
