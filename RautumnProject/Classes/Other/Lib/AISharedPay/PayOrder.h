//
//  PayOrder.h
//  HybridDemo
//
//  Created by mouxiaochun on 16/2/25.
//  Copyright © 2016年 mouxiaochun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PaymentType{
    PaymentTypeAlipay = 0,
    PaymentTypeWeiXin
}PaymentType;

@interface PayOrder : NSObject
//订单号
@property (nonatomic, strong) NSString *orderNo;
//订单名称
@property (nonatomic, strong) NSString *orderName;
//订单描述
@property (nonatomic, strong) NSString *orderDesc;
//订单价格
@property (nonatomic, strong) NSString *orderPrice;
//订单支付方式
@property (nonatomic, assign) PaymentType paymentType;
- (NSString *)orderPrice;


- (BOOL) isValidate;

@end
