//
//  PayOrder.m
//  HybridDemo
//
//  Created by mouxiaochun on 16/2/25.
//  Copyright © 2016年 mouxiaochun. All rights reserved.
//

#import "PayOrder.h"

@implementation PayOrder
- (NSString *)orderPrice {
    if (_paymentType == PaymentTypeWeiXin) {
        NSString* price = [NSString stringWithFormat:@"%.0f",[_orderPrice floatValue]*100.0];
        return price;
    }
    return _orderPrice;
}

- (BOOL)isValidate {

    return YES;
}

@end
