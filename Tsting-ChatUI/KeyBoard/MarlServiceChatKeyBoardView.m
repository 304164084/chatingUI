//
//  MarlChatKeyBoardView.m
//  Tsting-ChatUI
//
//  Created by bonlion on 2018/9/20.
//  Copyright © 2018 dasui. All rights reserved.
//

#import "MarlServiceChatKeyBoardView.h"
#import "MarlServiceChatTextView.h"
#import "MarlServiceChatMoreOperationsView.h"

NSString *const KeyBoardWillHiddenNotify = @"KeyBoardWillHiddenNotify";
static NSString *const MarlServiceKeyboardMoreButtonAnimationKey = @"MarlServiceKeyboardMoreButtonAnimationKey_Transform";

static CGFloat const space = 8.f; //按钮距离上边距
static CGFloat const btnHeight = 28.f;
static CGFloat const textViewHeight = 36.f;
static CGFloat  moreOperationsViewHeight = 114.f;

@interface MarlServiceChatKeyBoardView ()<UITextViewDelegate>
/** container view */
@property (nonatomic, strong) UIView *containerView;
/** text view */
@property (nonatomic, strong) MarlServiceChatTextView *textView;
/** more operations view */
@property (nonatomic, strong) MarlServiceChatMoreOperationsView *moreOperationsView;
/** more button */
@property (nonatomic, strong) UIButton *moreButton;
/** more button state */
@property (nonatomic, assign) BOOL moreButtonClicked;

@end

@implementation MarlServiceChatKeyBoardView

- (instancetype)init
{
    if (self = [super init]) {
        [self setupPropertyDefaultValue];
        [self addNotifications];
        [self setupViews];
    }
    return self;
}
// MARK: - 设置属性默认值
- (void)setupPropertyDefaultValue
{
    // TODO: - 114pt 未适配的高度在 X系列上看起来也不错~
    moreOperationsViewHeight = IS_IPHONE_X ? (moreOperationsViewHeight + Safe_Bottom_Area) : moreOperationsViewHeight;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupPropertyDefaultValue];
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
    CGFloat textViewBetweenTop = 8.f;

    self.containerView.frame = CGRectMake(0, 0, self.width, self.height);
    
    //加号按钮  保持距离底部10pt   52.f为输入框的初始高度
    self.moreButton.frame = CGRectMake(IsRightToLeft ? margin : self.containerView.width - btnHeight - margin, (52.f - btnHeight) / 2.f, btnHeight, btnHeight);
    
    //输入视图
    self.textView.frame = CGRectMake(IsRightToLeft ? margin + btnHeight + viewMargin : margin, textViewBetweenTop, self.containerView.width - margin * 2 - btnHeight - viewMargin, textViewHeight);
}

// MARK: - 更改高度 & 响应代理
- (void)changeFrame:(CGFloat)height
{
    //当输入框大小改变时，改变containerView的frame
    self.containerView.height = height + (space * 2);
    
    self.y -= (height -  self.textView.height);
    self.height = self.containerView.height;
    
    //改变更多按钮的位置
    self.moreButton.y = self.containerView.height - 12.f - self.moreButton.height;
    
    //改变输入框的frame
    self.textView.height = height;
    
    [self changeTableViewFrame];
}
// MARK: - 点击空白处，键盘收起时，移动self至底部
- (void)keyboardHide {
    
    if (self.moreButtonClicked) {
        [self.moreButton.layer addAnimation:[self animationRotationZWithToValue:0 fromValue:-M_PI_4 duration:.5f] forKey:MarlServiceKeyboardMoreButtonAnimationKey];
    }
    //收起键盘
    [self.textView resignFirstResponder];
   
    CGFloat kScreenHeight = [UIScreen mainScreen].bounds.size.height;

    [UIView animateWithDuration:0.25 animations:^{
        //设置self的frame到最底部
        //  - NaviHeight
        self.y = kScreenHeight - self.containerView.height - (IS_IPHONE_X ? Safe_Bottom_Area : 0.f);
        self.height = self.containerView.height;
        
        if (self.moreButtonClicked) {
            [self changeTableViewFrame];
            [self removeBottomViewFromSupview];
        }
    }];
}

// MARK: - 接收键盘将要显示的通知
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (self.moreButtonClicked) {
        [self.moreButton.layer addAnimation:[self animationRotationZWithToValue:0 fromValue:-M_PI_4 duration:.5f] forKey:MarlServiceKeyboardMoreButtonAnimationKey];
    }
    [self removeBottomViewFromSupview];
    
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:duration delay:0 options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] animations:^{
        self.y = endFrame.origin.y - self.containerView.height;
        self.height = self.containerView.height;
        
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
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:duration delay:0 options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] animations:^{
        self.y = endFrame.origin.y - self.containerView.height - (IS_IPHONE_X ? Safe_Bottom_Area : 0.f);
        self.height = self.containerView.height;
        
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
    [self.moreOperationsView removeFromSuperview];
    self.moreOperationsView = nil;
    self.moreButtonClicked = NO;
}

// MARK: - 点击发送按钮
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //判断输入的字是否是回车，即按下return
    if ([text isEqualToString:@"\n"]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardSendTextMessage:)]) {
            [self.delegate keyboardSendTextMessage:textView.text];
        }
        [self changeFrame:textViewHeight];
        textView.text = @"";
        /** 这里返回NO，就代表return键值失效，即页面上按下return，
         不会出现换行，如果为yes，则输入页面会换行 */
        return NO;
    }
    return YES;
}

// MARK: - more button 操作
- (void)actionMoreOperations:(UIButton *)button {
    if (self.moreButtonClicked == NO) {
        self.moreButtonClicked = YES;
        
        // 动画
        [button.layer addAnimation:[self animationRotationZWithToValue:-M_PI_4 fromValue:0.f duration:.5f] forKey:MarlServiceKeyboardMoreButtonAnimationKey];
        
        //回收键盘
        [self.textView resignFirstResponder];
        [self addSubview:self.moreOperationsView];
        //改变更多、self的frame
        
        [UIView animateWithDuration:0.25 animations:^{
            self.moreOperationsView.frame = CGRectMake(0, self.containerView.height, self.width, moreOperationsViewHeight);
            //  - NaviHeight
            self.y = [UIScreen mainScreen].bounds.size.height - self.containerView.height - moreOperationsViewHeight;
            self.height = self.containerView.height + moreOperationsViewHeight;
            
            [self changeTableViewFrame];
        }];
    } else { //再次点击更多按钮
        //键盘弹起
        [self.textView becomeFirstResponder];
        
        // 动画
        [button.layer addAnimation:[self animationRotationZWithToValue:0 fromValue:-M_PI_4 duration:.5f] forKey:MarlServiceKeyboardMoreButtonAnimationKey];
    }
}
// MARK: - lazy load
- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [UIView new];
        
        [self addSubview:_containerView];
    }
    return _containerView;
}

//更多按钮
- (UIButton *)moreButton
{
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setBackgroundImage:[UIImage imageNamed:@"service_keyboard_more"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(actionMoreOperations:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:_moreButton];
    }
    return _moreButton;
}

- (MarlServiceChatTextView *)textView
{
    if (!_textView) {
        _textView = [[MarlServiceChatTextView alloc] init];
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
        [self.containerView addSubview:_textView];
    }
    return _textView;
}

- (MarlServiceChatMoreOperationsView *)moreOperationsView
{
    if (!_moreOperationsView) {
        _moreOperationsView = [[MarlServiceChatMoreOperationsView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.width, moreOperationsViewHeight)];
        _moreOperationsView.backgroundColor = [UIColor whiteColor];
        // MARK: 发送图片消息
        __weak typeof(self)weakSelf = self;
        _moreOperationsView.selectedImageHandler = ^(UIImage * _Nonnull image) {
            __strong typeof(weakSelf)strongSelf = weakSelf;
            if ([strongSelf.delegate respondsToSelector:@selector(keyboardSendImageMessage:)]) {
                [strongSelf.delegate keyboardSendImageMessage:image];

                [strongSelf changeTableViewFrame];
            }
        };
    }
    return _moreOperationsView;
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

// MARK: - 移除监听
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
