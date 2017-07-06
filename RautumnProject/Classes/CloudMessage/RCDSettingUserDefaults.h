//
//  RCDSettingUserDefaults.h
//  RautumnProject
//
//  Created by 陈雷 on 2017/3/9.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCDSettingUserDefaults : NSObject
#pragma mark - set
//设置appKey
+ (void)setRCAppKey:(NSString *)appKey;
//设置DemoServer
+ (void)setRCDemoServer:(NSString *)demoServer;
//设置NaviServer
+ (void)setRCNaviServer:(NSString *)naviServer;
//设置FileServer
+ (void)setRCFileServer:(NSString *)fileServer;
#pragma mark - get
//获取appKey
+ (NSString *)getRCAppKey;
//获取DemoServer
+ (NSString *)getRCDemoServer;
//获取NaviServer
+ (NSString *)getRCNaviServer;
//获取FileServer
+ (NSString *)getRCFileServer;
@end
