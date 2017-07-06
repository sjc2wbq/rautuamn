//
//  RCDSettingUserDefaults.m
//  RautumnProject
//
//  Created by 陈雷 on 2017/3/9.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

#import "RCDSettingUserDefaults.h"

#define RCUserDefaultsSet(value,key) [[NSUserDefaults standardUserDefaults] setValue:value forKey:key]
#define RCUserDefaultsGet(key) [[NSUserDefaults standardUserDefaults] valueForKey:key]

static NSString *rcAppKeySettingKey = @"rcAppKeySettingKey";
static NSString *rcDemoServerSettingKey = @"rcDemoServerSettingKey";
static NSString *rcNaviServerSettingKey = @"rcNaviServerSettingKey";
static NSString *rcFileServerSettingKey = @"rcFileServerSettingKey";

@implementation RCDSettingUserDefaults
#pragma mark - set
//设置appKey
+ (void)setRCAppKey:(NSString *)appKey {
    RCUserDefaultsSet(appKey, rcAppKeySettingKey);
}
//设置DemoServer
+ (void)setRCDemoServer:(NSString *)demoServer {
    RCUserDefaultsSet(demoServer, rcDemoServerSettingKey);
}
//设置NaviServer
+ (void)setRCNaviServer:(NSString *)naviServer {
    RCUserDefaultsSet(naviServer, rcNaviServerSettingKey);
}
//设置FileServer
+ (void)setRCFileServer:(NSString *)fileServer {
    RCUserDefaultsSet(fileServer, rcFileServerSettingKey);
}
#pragma mark - get
//获取appKey
+ (NSString *)getRCAppKey {
    return RCUserDefaultsGet(rcAppKeySettingKey);
}
//获取DemoServer
+ (NSString *)getRCDemoServer {
    return RCUserDefaultsGet(rcDemoServerSettingKey);
}
//获取NaviServer
+ (NSString *)getRCNaviServer {
    return RCUserDefaultsGet(rcNaviServerSettingKey);
}
//获取FileServer
+ (NSString *)getRCFileServer {
    return RCUserDefaultsGet(rcFileServerSettingKey);
}
@end
