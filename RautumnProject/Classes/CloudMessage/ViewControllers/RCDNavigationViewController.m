//
//  RCDNavigationViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/7/25.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDNavigationViewController.h"
#import "UIColor+RCColor.h"

@interface RCDNavigationViewController ()

@end

@implementation RCDNavigationViewController

+ (void)initialize{
    //统一导航条样式
//    UIFont *font = [UIFont systemFontOfSize:19.f];
//    NSDictionary *textAttributes = @{
//                                     NSFontAttributeName : font,
//                                     NSForegroundColorAttributeName : [UIColor blackColor]
//                                     };
//    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
//    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
//    [[UINavigationBar appearance]
//     setBarTintColor:[UIColor blackColor]];
//    [UINavigationBar appearance].shadowImage = [[UIImage alloc] init];
    
}
- (void)viewDidLoad {
  [super viewDidLoad];

  __weak RCDNavigationViewController *weakSelf = self;

  if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    self.interactivePopGestureRecognizer.delegate = weakSelf;

    self.delegate = weakSelf;

    self.interactivePopGestureRecognizer.enabled = YES;
  }
}
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated {
  if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)] &&
      animated == YES) {
    self.interactivePopGestureRecognizer.enabled = NO;
  }
    if (viewController.accessibilityElementCount > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        UIBarButtonItem * item = [[UIBarButtonItem alloc] init];
        item.title = @"返回";
        viewController.navigationItem.backBarButtonItem = item;
//        viewController.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    }
  [super pushViewController:viewController animated:animated];
}

- (void)back {
    [self popViewControllerAnimated:YES];
}
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
  if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)] &&
      animated == YES) {
    self.interactivePopGestureRecognizer.enabled = NO;
  }

  return [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController
                        animated:(BOOL)animated {
  if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    self.interactivePopGestureRecognizer.enabled = NO;
  }
  return [super popToViewController:viewController animated:animated];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate {
  if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    self.interactivePopGestureRecognizer.enabled = YES;
  }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  if ([gestureRecognizer isEqual:self.interactivePopGestureRecognizer] &&
      self.viewControllers.count > 1 &&
      [self.visibleViewController isEqual:[self.viewControllers lastObject]]) {
    //判断当导航堆栈中存在页面，并且可见视图如果不是导航堆栈中的最后一个视图时，就会屏蔽掉滑动返回的手势。此设置是为了避免页面滑动返回时因动画存在延迟所导致的卡死。
    return YES;
  } else {
    return NO;
  }
}

@end
