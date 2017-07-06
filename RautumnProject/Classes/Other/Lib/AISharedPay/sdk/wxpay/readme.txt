//
//  readme.txt
//  HybridDemo
//
//  Created by mouxiaochun on 16/2/25.
//  Copyright © 2016年 mouxiaochun. All rights reserved.
//

微信支付集成:
1、向项目中添加文件夹wxpay
2、添加动态库和框架:
- libz.tbd
- libc++.tbd
- Security.framework
- CoreMotion.Framework
- CFNetwork.framework
- CoreTelephony.framework
- SystemConfiguration.framework
- CoreMotion

3、在WXDefines.h文件中修改相应的微信支付信息，例如 WX_APP_ID、WX_APP_SECRET等 建议将除WX_APP_ID的信息放在项目中以外，其他的均从服务端获取，保证信息的安全

4、在AppDelegate.m文件中
    (1) 引入AISharedPay.h
    (2) app启动函数中添加: [AISharedPay registerWXPay];
    (3) 再添加如下代码:
        - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
        {
            return [AISharedPay  handleOpenURL:url];

        }

        - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
        {

            return [AISharedPay handleOpenURL:url];
        }

5、在您需要使用微信支付的m文件中调用微信支付:

    PayOrder *order  = PayOrder.new;
    order.orderNo    = [NSString stringWithFormat:@"%0.lf",[[NSDate date] timeIntervalSince1970]];
    order.orderName  = @"微信支付测试";
    order.orderPrice = @"0.01";
    order.paymentType = PaymentTypeWeiXin;
    //发起支付
    [AISharedPay openPayment:order paymentBlock:^(BOOL success, id object, NSString *msg) {
        NSLog(@"msg: %@",msg);
        //这里已经支付成功，请在这里处理你接下来需要的逻辑

    }];

//wxd930ea5d5a258f4f  wechatShare


