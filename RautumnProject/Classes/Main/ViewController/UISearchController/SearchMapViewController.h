//
//  MainViewController.h
//  GDMapPlaceAroundDemo
//
//  Created by Mr.JJ on 16/6/14.
//  Copyright © 2016年 Mr.JJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchMapViewController;
@protocol SearchMapViewControllerDelegate <NSObject>
-(void)searchMapViewController:(SearchMapViewController *)vc sendLocationWithLatitude:(double)latitude longitude:(double )longitude address:(NSString *)address;


@end
@interface SearchMapViewController : UIViewController
@property(weak,nonatomic) id<SearchMapViewControllerDelegate> delegate;
@end
