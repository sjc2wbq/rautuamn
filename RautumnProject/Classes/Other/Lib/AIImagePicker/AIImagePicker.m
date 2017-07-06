//
//  AIImagePicker.m
//  FCHealthy
//
//  Created by mouxiaochun on 16/2/25.
//  Copyright © 2016年 mmc. All rights reserved.
//

#import "AIImagePicker.h"
#import "UIView+FindNav.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AIFileManager.h"
@interface AIImagePicker () <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UIView *inView;
@end
@implementation AIImagePicker

- (void)showInView:(UIView *)view {
    _inView = nil;
    _inView = view;
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机选择", nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow];

}


#pragma mark - actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title hasPrefix:@"从手机选择"]) {
        [self openLibrary];
    }else if ([title hasPrefix:@"拍照"]){
        
        [self openCamera];
        
    }else{
        
        [actionSheet dismissWithClickedButtonIndex:5 animated:YES];
    }
    
    
}


-(void)openLibrary
{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = self.allowEditting;
    picker.navigationBar.barStyle = UIBarStyleDefault;
    
    UINavigationController   *nav = _inView.navigationController;
    [nav presentViewController:picker animated:YES completion:NULL];
    
    
}
-(void)openCamera
{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.navigationBar.tintColor =  [UIColor whiteColor];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = self.allowEditting;
    picker.navigationBar.barStyle = UIBarStyleDefault;
    UINavigationController   *nav = _inView.navigationController;
    [nav presentViewController:picker animated:YES completion:NULL];
}
#pragma mark ImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if ([picker.mediaTypes containsObject:(NSString *)kUTTypeImage]) {
       // dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [picker.view showHUD:@"处理中..."];
//            });
        
            UIImage *imageReadyPost = nil;
            
            if (self.allowEditting) {
                imageReadyPost = [info objectForKey:UIImagePickerControllerEditedImage];
            }else{
                imageReadyPost = [info objectForKey:UIImagePickerControllerOriginalImage];
            }
            UIImageOrientation imageOrientation=imageReadyPost.imageOrientation;
            if(imageOrientation!=UIImageOrientationUp)
            {
                // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
                // 以下为调整图片角度的部分
                UIGraphicsBeginImageContext(imageReadyPost.size);
                [imageReadyPost drawInRect:CGRectMake(0, 0, imageReadyPost.size.width, imageReadyPost.size.height)];
                imageReadyPost = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                // 调整图片角度完毕
            }
            NSData *data = UIImageJPEGRepresentation(imageReadyPost, 1);
            NSInteger kb = data.length / 1024;
            CGFloat scale = 1;
            if (kb > 2048) {
                kb = kb / 2014;
                scale = 0.3;
            }else if(kb > 1024){
                scale = 0.5;
            }else if(kb > 200)
            {
                scale = 0.7;
            }
            if (scale < 1.0) {
                data     =  UIImageJPEGRepresentation(imageReadyPost, scale);
            }

        
            imageReadyPost = [UIImage imageWithData:data];
            [self handleImage:imageReadyPost withPicker:picker];
       // });
    }else{
        [picker dismissViewControllerAnimated:YES completion:NULL];

    }
    
    
    
}

-(void)handleImage:(UIImage *)image withPicker:(UIImagePickerController *)picker{
    
    NSTimeInterval  time=[[NSDate date] timeIntervalSince1970];
    NSString  *str=[NSString stringWithFormat:@"%0.f",time];
    NSString *filename = [NSString stringWithFormat:@"%@.jpg",str];
    NSData *dataImage =   UIImageJPEGRepresentation(image, 1.0);
    NSString *filePath = [AIFileManager setObject:dataImage forKey:filename];
    dispatch_async(dispatch_get_main_queue(), ^{
        // No need to hod onto (retain)
        if (_imagePickerCompletion) {
            _imagePickerCompletion(image,filePath);
        }
        [picker dismissViewControllerAnimated:YES completion:NULL];

    });
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


#pragma mark --- Setter && getter

@end
