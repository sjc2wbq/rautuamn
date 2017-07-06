//
//  AISharedPay.h
//  AISharedPay
//
//  Created by mouxiaochun on 16/1/19.
//  Copyright © 2016年 mmc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayOrder.h"

typedef void (^PaymentCompletion)(BOOL success,id object,NSString *msg) ;

@interface AISharedPay : NSObject
+ (AISharedPay *)shared;
+ (void)registerWXPay;
//实现跳转页面
+ (BOOL)handleOpenURL:(NSURL *)url;


/**
 ** 发起支付
 **/
//自己签名，返回
+ (void)openPayment:(PayOrder *)order paymentBlock:(PaymentCompletion)block;


//客户端仅使用服务端返回的数据时，可调用以下两方法
+ (void) handleAlipay:(NSString *)orderString paymentBlock:(PaymentCompletion)block;
+ (void)handleWeixinPayment:(NSDictionary *)params paymentBlock:(PaymentCompletion)block;

@end
