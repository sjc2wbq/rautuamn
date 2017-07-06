//
//  PlayVideoViewController.h
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/27.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayVideoViewController : UIViewController

/**
 * videoPath
 */
@property(nonatomic, strong)NSURL *videoUrl;
@property (weak, nonatomic)  UIImage * placeholderImage;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderImageView;
@end
