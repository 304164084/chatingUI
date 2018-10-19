//
//  MarlServiceChatCell.m
//  Tsting-ChatUI
//
//  Created by bonlion on 2018/9/21.
//  Copyright © 2018 dasui. All rights reserved.
//

#import "MarlServiceChatCell.h"
NSString *const MarlServiceChatCellID = @"MarlServiceChatCellID";

@interface MarlServiceChatCell ()

/** img view */
@property (nonatomic, strong) UIImageView *headImageView;
/** content label */
@property (nonatomic, strong) UILabel *contentLabel;
/** chat bubble view */
@property (nonatomic, strong) UIView *chatBubbleView;

@end

@implementation MarlServiceChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
        [self setupViews];
    }
    return self;
}
// MARK: - UI
- (void)setupViews
{
    // head img view
    UIImage *img = [UIImage imageNamed:@"user_head_female"];
    _headImageView = [[UIImageView alloc] initWithImage:img];
    
    [self.contentView addSubview:_headImageView];
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(16.f);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(8.f);
        make.size.mas_equalTo(img.size);
    }];
    
    // 聊天气泡
    _chatBubbleView = [UIView new];
    _chatBubbleView.backgroundColor = [UIColor colorWithRed:254/255.0 green:219/255.0 blue:67/255.0 alpha:1];
    _chatBubbleView.layer.cornerRadius = 8;
    
    [self.contentView addSubview:_chatBubbleView];
    [_chatBubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(16.f);
        make.leading.mas_equalTo(self.headImageView.mas_trailing).offset(8.f);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    // content label
    _contentLabel = [UILabel new];
    _contentLabel.textColor = [UIColor blackColor];
    _contentLabel.font = [UIFont systemFontOfSize:16];
    _contentLabel.numberOfLines = 0;
    
    [self.chatBubbleView addSubview:_contentLabel];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.chatBubbleView.mas_top).offset(12.f);
        make.leading.mas_equalTo(self.chatBubbleView.mas_leading).offset(12.f);
        make.trailing.mas_equalTo(self.chatBubbleView.mas_trailing).offset(-12.f);
        make.bottom.mas_equalTo(self.chatBubbleView.mas_bottom).offset(-12.f);
        make.width.mas_lessThanOrEqualTo(@(239.f)).priorityHigh();
    }];
}
- (void)setContent:(NSString *)content
{
    _content = content;
    NSInteger random = arc4random_uniform(100);
    NSUInteger type = random % 2;
    NSLog(@"random ->%ld", random);

    self.contentLabel.text = content;
    
}
- (void)setRoleType:(MarlChatRoleType)roleType
{
    _roleType = roleType;
    if (roleType == MarlChatRoleTypeUser) {
        UIImage *img = [UIImage imageNamed:@"user_head_male"];
        _headImageView.image = img;
        [_headImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(16.f);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-8.f);
            make.size.mas_equalTo(img.size);
        }];
        
        [_chatBubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(16.f);
            make.trailing.mas_equalTo(self.headImageView.mas_leading).offset(-8.f);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
    }
}

@end
