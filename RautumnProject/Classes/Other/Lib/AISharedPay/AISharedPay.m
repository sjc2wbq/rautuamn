//
//  AISharedPay.m
//  AISharedPay
//
//  Created by mouxiaochun on 16/1/19.
//  Copyright © 2016年 mmc. All rights reserved.
//

#import "AISharedPay.h"
#import "WXApi.h"
#import "WXDefines.h"
#import "payRequsestHandler.h"
#import <AlipaySDK/AlipaySDK.h>
#import "AlipayDefines.h"
#import "Order.h"
#import "APAuthV2Info.h"
#import "DataSigner.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"
#import <UIKit/UIKit.h>
@interface AISharedPay() <WXApiDelegate>
{
    PayOrder *_payOrder;
    PaymentCompletion _paymentBlock;//支付成功后回调
}
@end

@implementation AISharedPay

+ (AISharedPay *)shared {
    static AISharedPay *pay = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        pay = [[[self class] alloc] init];
    });
    return pay;
}


+ (void)registerWXPay {
    [WXApi registerApp:WX_APP_ID withDescription:WX_APP_DESC];
}

//实现跳转页面
+ (BOOL)handleOpenURL:(NSURL *)url {

    return [[AISharedPay shared] handleOpenURL:url];
}

//实现跳转页面
- (BOOL)handleOpenURL:(NSURL *)url
{
    NSLog(@"1url = %@   [url host] = %@",url,[url host]);
    
    if(url != nil && [[url host] isEqualToString:@"pay"]){
        //微信支付
        NSLog(@"微信支付");
        return [WXApi handleOpenURL:url delegate:self];
    } else if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"handle result = %@",resultDic);
        }];
    }
    
    return YES;
}

//收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]])
    {
#warning 支付结果处理
        PayResp *response = (PayResp *)resp;
        
        //        NSLog(@"支付结果 %d===%@",response.errCode,response.errStr);
        NSString *payMsg = nil;
        switch (response.errCode) {
            case WXSuccess: {
                
                NSLog(@"支付成功");
                
                //...支付成功相应的处理，跳转界面等
                if (_paymentBlock) {
                    _paymentBlock(YES,_payOrder,@"支付已成功!");
                }
                break;
            }
            case WXErrCodeUserCancel: {
                
                NSLog(@"用户取消支付");
                payMsg = @"您已取消支付订单!";

                //...支付取消相应的处理
                
                break;
            }
            default: {
                
                NSLog(@"支付失败");
                payMsg = @"对不起，支付结果失败！请稍后再试!";

                //...做相应的处理，重新支付或删除支付
                
                break;
            }
        }
        if (payMsg.length > 0) {
//        [JCAlertView showOneButtonWithTitle:@"支付结果" Message:payMsg ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:nil];
        
        }
       
    }
    
}


#pragma mark ---  订单
/**
 ** 发起支付
 **/
+ (void)openPayment:(PayOrder *)order paymentBlock:(PaymentCompletion)block {

    [[AISharedPay shared] openPayment:order paymentBlock:block];
}

- (void)openPayment:(PayOrder *)order paymentBlock:(PaymentCompletion)block {

    if (order.paymentType == PaymentTypeWeiXin) {
        [self doWeiXinPay:order paymentBlock:block];
    }else if (order.paymentType == PaymentTypeAlipay) {
        [self doAlipay:order paymentBlock:block];
    }
}

/**
 ** 微信支付
 **/
- (void)doWeiXinPay:(PayOrder *)order paymentBlock:(PaymentCompletion)block
{
    [AISharedPay registerWXPay];
    _payOrder = nil;
    _payOrder = order;
    _paymentBlock = nil;
    _paymentBlock = block;
    
    if (!order.isValidate) {
        return;
    }
    
    //创建支付签名对象
    payRequsestHandler *req = [[payRequsestHandler alloc] init];
    //初始化支付签名对象
   // [req init:WX_APP_ID mch_id:WX_MCH_ID];
    //设置密钥
  //  [req setKey:WX_PARTNER_ID];
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSDictionary *info = @{@"orderno":order.orderNo,@"order_name":order.orderName,@"order_price":order.orderPrice};
    NSMutableDictionary *dict = [req sendPay_Weixin:info];
    if(dict == nil){
        //错误提示
        NSString *debug = [req getDebugifo];
        NSLog(@"%@\n\n",debug);
    }else{
        NSLog(@"%@\n\n",[req getDebugifo]);
        NSString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        
        [WXApi sendReq:req];
    }

}


- (void)doAlipay:(PayOrder *)order paymentBlock:(PaymentCompletion)block{

    if (!order.isValidate) {
        return;
    }
    
    Order *alipayOrder = [[Order alloc] init];
    alipayOrder.tradeNO = order.orderNo;
    alipayOrder.productName = order.orderName;
    alipayOrder.productDescription = order.orderDesc;
    alipayOrder.amount = order.orderPrice;
    //以下是一些固定信息
    alipayOrder.notifyURL = ALIPAY_NOTIFY_URL;
    alipayOrder.service = @"mobile.securitypay.pay";
    alipayOrder.paymentType = @"1";
    alipayOrder.inputCharset = @"utf-8";
    alipayOrder.itBPay = @"30m";
    alipayOrder.showUrl = @"m.alipay.com";
    alipayOrder.partner = ALIPAY_PartnerID;
    alipayOrder.seller = ALIPAY_Seller;

    //将商品信息拼接成字符串
    NSString *orderSpec = [alipayOrder description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(AlipayPrivateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [self handleAlipay:orderString paymentBlock:block];
    }

   
}

+ (void) handleAlipay:(NSString *)orderString paymentBlock:(PaymentCompletion)block {
    [[AISharedPay shared] handleAlipay:orderString paymentBlock:block];
    
}

- (void) handleAlipay:(NSString *)orderString paymentBlock:(PaymentCompletion)block{

    [[AlipaySDK defaultService] payOrder:orderString fromScheme:ALIPAY_APP_SCHEME callback:^(NSDictionary *resultDic) {
        
        NSLog(@"reslut = %@",resultDic);
        NSString *payMsg = nil;
        int status = [[resultDic objectForKey:@"resultStatus"] intValue];
        if (status == 9000) {
            /*
             *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
             */
            
            //交易成功
            NSString* key = AlipayPubKey;//签约帐户后获取到的支付宝公钥
            id<DataVerifier> verifier;
            verifier = CreateRSADataVerifier(key);
            NSString *resultString = [resultDic objectForKey:@"result"];
            //验证签名成功，交易结果无篡改
            if (block) {
                block(YES,resultString,@"支付已成功!");
            }
            //                AlixPayResult *result = [[AlixPayResult alloc] initWithString:resultString];
            //                if ([verifier verifyString:[resultDic objectForKey:@"result"] withSign:result.signString])
            //                {
            //                    //验证签名成功，交易结果无篡改
            //                    if (_paymentBlock) {
            //                        _paymentBlock(YES,_payOrder,@"支付已成功!");
            //                    }
            //                }else{
            //                    payMsg = @"交易失败或已取消支付!";
            //                }
            
        }else{
            payMsg = @"交易失败或已取消支付!";
        }
        
        if (payMsg.length > 0) {
            
//            [JCAlertView showOneButtonWithTitle:@"支付结果" Message:payMsg ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:nil];

        }
        
    }];
}

+ (void)handleWeixinPayment:(NSDictionary *)params paymentBlock:(PaymentCompletion)block {

    [[AISharedPay shared] handleWeixinPayment:params paymentBlock:block];
}
- (void)handleWeixinPayment:(NSDictionary *)params paymentBlock:(PaymentCompletion)block {
    [AISharedPay registerWXPay];
    _paymentBlock = nil;
    _paymentBlock = block;
    //调起微信支付
    NSMutableString *stamp  = [params objectForKey:@"timeStamp"];
    PayReq* req             = [[PayReq alloc] init];
    req.partnerId           = [params objectForKey:@"partnerId"];
    req.prepayId            = [params objectForKey:@"prepayId"];
    req.nonceStr            = [params objectForKey:@"nonceStr"];
    req.timeStamp           = stamp.intValue;
    req.package             = [params objectForKey:@"package"];
    req.sign                = [params objectForKey:@"sign"];
    BOOL d=  [WXApi sendReq:req];
    if (d) {
        NSLog(@"调用微信APP成功");
    }
}

#pragma mark ---



@end
