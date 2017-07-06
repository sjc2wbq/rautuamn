//
//  RCDHttpTool.h
//  RCloudMessage
//
//  Created by Liv on 15/4/15.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDCommonDefine.h"
#import "RCDGroupInfo.h"
#import "RCDUserInfo.h"
#import <Foundation/Foundation.h>
#import <RongIMLib/RCGroup.h>
#import <RongIMLib/RCUserInfo.h>
#import <UIKit/UIKit.h>
#define RCDHTTPTOOL [RCDHttpTool shareInstance]

@interface RCDHttpTool : NSObject

@property(nonatomic, strong) NSMutableArray *allFriends;
@property(nonatomic, strong) NSMutableArray *allGroups;

+ (RCDHttpTool *)shareInstance;

//获取个人信息
- (void)getUserInfoByUserID:(NSString *)userID
                 completion:(void (^)(RCUserInfo *user))completion;



//根据id获取单个群组
- (void)getGroupByID:(NSString *)groupID
   successCompletion:(void (^)(RCDGroupInfo *group))completion;



//更新自己的用户名
- (void)updateName:(NSString *)userName
           success:(void (^)(id response))success
           failure:(void (^)(NSError *err))failure;

//从demo server 获取用户的信息，更新本地数据库
- (void)updateUserInfo:(NSString *)userID
               success:(void (^)(RCDUserInfo *user))success
               failure:(void (^)(NSError *err))failure;


//获取用户详细资料
- (void)getFriendDetailsWithFriendId:(NSString *)friendId
                             success:(void (^)(RCDUserInfo *user))success
                             failure:(void (^)(NSError *err))failure;
@end
