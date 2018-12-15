//
//  MarlChatMoreOperationsView.h
//  Tsting-ChatUI
//
//  Created by bonlion on 2018/9/20.
//  Copyright © 2018 dasui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MarlServiceChatMoreOperationsView : UIView
/** 选中的照片 */
@property (nonatomic, strong) void (^selectedImageHandler)(UIImage *image);
@end

NS_ASSUME_NONNULL_END
