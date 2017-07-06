//
//  ComplaintsModel.m
//  AiChuXing
//
//  Created by Raychen on 16/6/13.
//  Copyright © 2016年 hao. All rights reserved.
//

#import "ComplaintsModel.h"

@implementation ComplaintsModel
+ (NSArray *)dataSource{
    NSMutableArray * temps =  [NSMutableArray array];
    [@[@"用户评价与实际情况不符",@"用户下单取消订单频繁",@"用户沟通协调态度不好",@"用户故意诋毁商家信誉",@"其他"] enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ComplaintsModel * model = [[ComplaintsModel alloc] init];
        model.title = obj;
        if (idx == 0) {
            model.check = YES;
        }else{
            model.check = NO;
        }
        [temps addObject:model];
    }];
    return temps;
}
@end
