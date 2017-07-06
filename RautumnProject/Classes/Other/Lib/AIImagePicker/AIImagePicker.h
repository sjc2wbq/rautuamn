//
//  AIImagePicker.h
//  FCHealthy
//
//  Created by mouxiaochun on 16/2/25.
//  Copyright © 2016年 mmc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^ImagePickerCompletion)(UIImage *image, NSString *filePath) ;

@interface AIImagePicker : NSObject

@property(strong, nonatomic) ImagePickerCompletion imagePickerCompletion;
@property(assign, nonatomic) BOOL allowEditting;

- (void)showInView:(UIView *)view;



@end
