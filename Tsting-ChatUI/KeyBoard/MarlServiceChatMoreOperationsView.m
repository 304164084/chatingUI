//
//  MarlChatMoreOperationsView.m
//  Tsting-ChatUI
//
//  Created by bonlion on 2018/9/20.
//  Copyright © 2018 dasui. All rights reserved.
//

#import "MarlServiceChatMoreOperationsView.h"
#import "UIView+UITools.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, MarlChatingMoreViewButtonActionType) {
    MarlChatingMoreViewButtonActionTypeCamera = 1 << 0,
    MarlChatingMoreViewButtonActionTypeAlbum = 1 << 1,
};

@interface MarlServiceChatMoreOperationsView ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
/** camera */
@property (nonatomic, strong) UIButton *cameraButton;
/** album */
@property (nonatomic, strong) UIButton *albumButton;
@end

@implementation MarlServiceChatMoreOperationsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

// MARK: - UI
- (void)setupViews
{
    // camera
    _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraButton setImage:[UIImage imageNamed:@"service_keyboard_Camera"] forState:UIControlStateNormal];

    [_cameraButton setTitle:NSLocalizedString(@"Camera", @"相机") forState:UIControlStateNormal];
    [_cameraButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _cameraButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_cameraButton addTarget:self action:@selector(actionClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [_cameraButton setImagePositionWithType:SSImagePositionTypeTop spacing:5.f];
    _cameraButton.tag = MarlChatingMoreViewButtonActionTypeCamera;
    
    [self addSubview:_cameraButton];
    [_cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(9.f);
        make.leading.mas_equalTo(self).offset(24.f);
//        make.size.mas_equalTo(CGSizeMake(109, 97));
        make.width.mas_equalTo(@(109.f));
        make.height.mas_equalTo(@(97.f));
    }];
    
    // album
    _albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_albumButton setImage:[UIImage imageNamed:@"service_keyboard_Album"] forState:UIControlStateNormal];
  
    [_albumButton setTitle:NSLocalizedString(@"Album", @"相簿") forState:UIControlStateNormal];
    [_albumButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _albumButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_albumButton addTarget:self action:@selector(actionClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [_albumButton setImagePositionWithType:SSImagePositionTypeTop spacing:5.f];
    _albumButton.tag = MarlChatingMoreViewButtonActionTypeAlbum;
    
    [self addSubview:_albumButton];
    [_albumButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cameraButton);
        make.leading.mas_equalTo(self.cameraButton.mas_trailing);
//        make.size.mas_equalTo(self.cameraButton);
        make.width.mas_equalTo(self.cameraButton);
        make.height.mas_equalTo(self.cameraButton);
    }];
    
}

// MARK: - 按钮处理事件
- (void)actionClicked:(UIButton *)button
{
    if (![UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceRear] && button.tag == MarlChatingMoreViewButtonActionTypeCamera) return;
    
    
    if (button.tag == MarlChatingMoreViewButtonActionTypeCamera) {
        //读取媒体类型
        NSString *mediaType = AVMediaTypeVideo;
        //读取设备授权状态
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"ok") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"setting", @"设置") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // FIXME: - 跳转到相册
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Cannot use camera", @"无法使用相机") message:NSLocalizedString(@"To take photo normally, you may go to [ Settings]>[Privacy]>[Camera] on your device", @"描述") preferredStyle:(UIAlertControllerStyleAlert)];
            [alerVC addAction:cancelAction];
            [alerVC addAction:sureAction];
            
            [self.viewController presentViewController:alerVC animated:YES completion:nil];
            
            return;
        }
    }
    
    if (button.tag == MarlChatingMoreViewButtonActionTypeAlbum) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0

#else
        __block canOpenAlbum = NO;
        [self checkPhotoAuth:^(BOOL auth) {
            canOpenAlbum = auth;
        }];
        if (!canOpenAlbum) {
            // 这里 如果在iOS 11 之前不授权 第二次进入会显示系统的提示页面.
            return;
        }
#endif
    }
    
    NSUInteger sourceType = -1;
    switch (button.tag) {
        case MarlChatingMoreViewButtonActionTypeCamera:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            
            break;
        case MarlChatingMoreViewButtonActionTypeAlbum:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            
            break;
            
        default:
            
            break;
    }
    if (sourceType == -1) return; // 如果还是-1说明都不支持

    //
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
//    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.viewController presentViewController:imagePickerController animated:YES completion:nil];
    });
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *normalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *image = editedImage ? editedImage : normalImage;
    if (_selectedImageHandler && image) {
        _selectedImageHandler(image);
    }
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}
// MARK: - 判断用户相册权限
- (void)checkPhotoAuth:(void (^)(BOOL auth))result
{
    PHAuthorizationStatus current = [PHPhotoLibrary authorizationStatus];
    switch (current) {
        case PHAuthorizationStatusNotDetermined:    //用户还没有选择(第一次)
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    //授权
                    if (result) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            result(YES);
                        });
                    }
                }else {
                    //其他
                    if (result) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            result(NO);
                        });
                    }
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:       //家长控制
        {
            if (result) {
                result(NO);
            }
        }
            break;
        case PHAuthorizationStatusDenied:           //用户拒绝
        {
            if (result) {
                result(NO);
            }
        }
            break;
        case PHAuthorizationStatusAuthorized:       //已授权
        {
            if (result) {
                result(YES);
            }
        }
            break;
        default:
            break;
    }
    
}


@end
