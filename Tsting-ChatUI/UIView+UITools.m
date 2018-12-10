//
//  UIView+UITools.m
//  Tsting-ChatUI
//
//  Created by 隋老大 on 2018/12/10.
//  Copyright © 2018 dasui. All rights reserved.
//

#import "UIView+UITools.h"

@implementation UIView (UITools)
@dynamic viewController;

- (UIViewController *)viewController
{
    UIResponder *responder = [self nextResponder];
    while (responder) {
        
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}
@end
