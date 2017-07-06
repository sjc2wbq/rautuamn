//
//  UIScrollView+STRefresh.m
//  SwipeTableView
//
//  Created by Roy lee on 16/7/10.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

#import "UIScrollView+STRefresh.h"
#import <objc/runtime.h>

@implementation UIScrollView (STRefresh)

- (STRefreshHeader *)st_header {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setSt_header:(STRefreshHeader *)st_header{
    [self.st_header removeFromSuperview];
    [self addSubview:st_header];
    
    SEL key = @selector(st_header);
    objc_setAssociatedObject(self, key, st_header, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
