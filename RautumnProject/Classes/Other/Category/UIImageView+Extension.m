//
//  UIImageView+Extension.m
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/14.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

#import "UIImageView+Extension.h"
#import <AVFoundation/AVFoundation.h>
@implementation UIImageView (Extension)



- (void)movieImage:(UIImage *)image
{
    
    self.image = image;
    
    
}

- (void)getVedioImgWithUrl:(NSURL *)url
{
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
    
    AVAssetImageGeneratorCompletionHandler handler =
    ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        
        if (result != AVAssetImageGeneratorSucceeded) {
        }//没成功
        
        UIImage *thumbImg = [UIImage imageWithCGImage:im];
        
        [self performSelectorOnMainThread:@selector(movieImage:) withObject:thumbImg waitUntilDone:YES];
    };
    generator.maximumSize = self.frame.size;
    [generator generateCGImagesAsynchronouslyForTimes:
     [NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    
}
@end
