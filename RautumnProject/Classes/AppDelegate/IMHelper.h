//
//  IMHelper.h
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/23.
//  Copyright © 2016年 Rautumn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMHelper : NSObject
+ (instancetype)shareInstance;
- (void)setUpRongYunIM:(NSDictionary *)launchOptions;
//插入分享消息
- (void)insertSharedMessageIfNeed;
//为消息分享保存会话信息
- (void)saveConversationInfoForMessageShare;
@end
