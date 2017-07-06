//
//  UIView+FindNav.m
//  CMCC-JiFen
//
//  Created by mouxiaochun on 15/5/25.
//  Copyright (c) 2015年 MacMini. All rights reserved.
//

#import "UIView+FindNav.h"
 @implementation UIView(FindNav)
-(UINavigationController *)navigationController{
    
    
    UIViewController *vc = [self findViewController];
    
    return vc.navigationController;
}

- (UIViewController *)findViewController
{
    id target=self;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]])
            break;
    }
    return target;
}

///**
// *    @brief    通过viewController内的view,获取Controller
// *
// *    @param     view     subView
// *
// *    @return    UIViewController
// */
//- (UIViewController *)recursionView2ViewController:(UIView *)view
//{
//    __block UIViewController *viewController;
//    __block void (^blocks)(UIView *) = nil;
//    blocks = ^(UIView *view)
//    {
//        if([view.superview isKindOfClass:NSClassFromString(@"UIViewControllerWrapperView")])
//        {
//            Ivar ivar = class_getInstanceVariable([UIView class], "_viewDelegate");
//            viewController = object_getIvar(view, ivar);
//        }
//        else blocks(view.superview);
//    };
//    blocks(view);
//    return viewController;
//}



#pragma mark ---
 
@end
