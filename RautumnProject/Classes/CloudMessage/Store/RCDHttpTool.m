//
//  RCDHttpTool.m
//  RCloudMessage
//
//  Created by Liv on 15/4/15.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDHttpTool.h"
#import "AFHttpTool.h"
#import "RCDGroupInfo.h"
#import "RCDRCIMDataSource.h"
#import "RCDUserInfo.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"
#import "SortForTime.h"
#import "RCDUserInfoManager.h"

@implementation RCDHttpTool

+ (RCDHttpTool *)shareInstance {
  static RCDHttpTool *instance = nil;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    instance = [[[self class] alloc] init];
    instance.allGroups = [NSMutableArray new];
    instance.allFriends = [NSMutableArray new];
  });
  return instance;
}





//根据id获取单个群组
- (void)getGroupByID:(NSString *)groupID
   successCompletion:(void (^)(RCDGroupInfo *group))completion {
  [AFHttpTool getGroupByID:groupID
      success:^(id response) {
          
          NSDictionary * infoDic = [NSJSONSerialization JSONObjectWithData:(NSData *)response options:NSJSONReadingAllowFragments error:nil];
          if ([infoDic[@"result_code"] isEqualToString:@"0"]) {
              NSDictionary * dict = [infoDic objectForKey:@"result_data"];
              RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
              group.groupName = [dict objectForKey:@"name"];
              group.groupId = groupID;
              group.portraitUri = [dict objectForKey:@"coverPhotoUrl"];
              [[RCDataBaseManager shareInstance] insertGroupToDB:group];
              if ([group.groupId isEqualToString:groupID] && completion) {
                  completion(group);
              }else{
                  if (completion) {
                      completion(nil);
                  }
              }
          } else {
              if (completion) {
                  completion(nil);
              }
          }

      }
      failure:^(NSError *err) {
        RCDGroupInfo *group =
            [[RCDataBaseManager shareInstance] getGroupByGroupId:groupID];
        if (!group.portraitUri || group.portraitUri.length <= 0) {
          group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
        }
        completion(group);
      }];
}

//根据userId获取单个用户信息
- (void)getUserInfoByUserID:(NSString *)userID
                 completion:(void (^)(RCUserInfo *user))completion {
  RCUserInfo *userInfo =
      [[RCDataBaseManager shareInstance] getUserByUserId:userID];
  if (!userInfo) {
    [AFHttpTool getUserInfo:userID
        success:^(id response) {
          if (response) {
              
              NSDictionary * infoDic = [NSJSONSerialization JSONObjectWithData:(NSData *)response options:NSJSONReadingAllowFragments error:nil];
              if ([infoDic[@"result_code"] isEqualToString:@"0"]) {
                  NSDictionary * dict = [infoDic objectForKey:@"result_data"];
                  
                  RCUserInfo *user = [[RCUserInfo alloc] init];
                  user.userId = dict[@"userId"];
                  user.name = [dict objectForKey:@"nickName"];
                  NSString *portraitUri = [[dict objectForKey:@"headPortUrl"] stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
                  if (!portraitUri || portraitUri.length <= 0) {
                      portraitUri = [RCDUtilities defaultUserPortrait:user];
                  }
                  user.portraitUri = portraitUri;
                  [[RCDataBaseManager shareInstance] insertUserToDB:user];
                  
                  RCDUserInfo *Details = [[RCDataBaseManager shareInstance] getFriendInfo:userID];
                  if (Details == nil) {
                      Details = [[RCDUserInfo alloc] init];
                  }
                  Details.name = [dict objectForKey:@"nickName"];
                  Details.portraitUri = portraitUri;
                  Details.userId = [dict objectForKey:@"userId"];
                  Details.displayName = dict[@"nickName"];
                  [[RCDataBaseManager shareInstance] insertFriendToDB:Details];
                  if (completion) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                        completion(user);
                      });
                    }
              }

          } else {
            RCUserInfo *user = [RCUserInfo new];
            user.userId = userID;
            user.name = [NSString stringWithFormat:@"name%@", userID];
            user.portraitUri = [RCDUtilities defaultUserPortrait:user];

            if (completion) {
              dispatch_async(dispatch_get_main_queue(), ^{
                completion(user);
              });
            }
          }
        }
        failure:^(NSError *err) {
          NSLog(@"getUserInfoByUserID error");
          if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
              RCUserInfo *user = [RCUserInfo new];
              user.userId = userID;
              user.name = [NSString stringWithFormat:@"name%@", userID];
              user.portraitUri = [RCDUtilities defaultUserPortrait:user];

              completion(user);
            });
          }
        }];
  } else {
    if (completion) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (!userInfo.portraitUri || userInfo.portraitUri.length <= 0) {
          userInfo.portraitUri = [RCDUtilities defaultUserPortrait:userInfo];
        }
        completion(userInfo);
      });
    }
  }
}




- (void)updateUserInfo:(NSString *)userID
               success:(void (^)(RCDUserInfo *user))success
               failure:(void (^)(NSError *err))failure {
  [AFHttpTool
   getFriendDetailsByID:userID
   success:^(id response) {
       NSDictionary * infoDic = [NSJSONSerialization JSONObjectWithData:(NSData *)response options:NSJSONReadingAllowFragments error:nil];
       if ([infoDic[@"result_code"] isEqualToString:@"0"]) {
           NSDictionary * dict = [infoDic objectForKey:@"result_data"];

           RCUserInfo *user = [[RCUserInfo alloc] init];
           user.userId = dict[@"userId"];
           user.name = [dict objectForKey:@"nickName"];
           NSString *portraitUri = [[dict objectForKey:@"headPortUrl"] stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
           
           if (!portraitUri || portraitUri.length <= 0) {
               portraitUri = [RCDUtilities defaultUserPortrait:user];
           }
           user.portraitUri = portraitUri;
           [[RCDataBaseManager shareInstance] insertUserToDB:user];
           
           RCDUserInfo *Details = [[RCDataBaseManager shareInstance] getFriendInfo:userID];
           if (Details == nil) {
               Details = [[RCDUserInfo alloc] init];
           }
           Details.name = [dict objectForKey:@"nickName"];
           Details.userId = [dict objectForKey:@"userId"];
           Details.portraitUri = portraitUri;
           Details.displayName = dict[@"nickName"];
           [[RCDataBaseManager shareInstance] insertFriendToDB:Details];
           if (success) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   success(Details);
               });
           }
       }
       NSLog(@"infoDic------%@", infoDic);
       

   } failure:^(NSError *err) {
     failure(err);
   }];

}


-(NSDate *)stringToDate:(NSString *)build
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyyMMddHHmm"];
  NSDate *date = [dateFormatter dateFromString:build];
  return date;
}


//获取用户详细资料
- (void)getFriendDetailsWithFriendId:(NSString *)friendId
                             success:(void (^)(RCDUserInfo *user))success
                             failure:(void (^)(NSError *err))failure {
    
  [AFHttpTool getFriendDetailsByID:friendId
                           success:^(id response) {
                               NSDictionary * infoDic = [NSJSONSerialization JSONObjectWithData:(NSData *)response options:NSJSONReadingAllowFragments error:nil];
                               if ([infoDic[@"result_code"] isEqualToString:@"0"]) {
                                   NSDictionary * dict = [infoDic objectForKey:@"result_data"];

                                   RCUserInfo *user = [[RCUserInfo alloc] init];
                                   user.userId = dict[@"userId"];
                                   user.name = [dict objectForKey:@"nickName"];
                                   NSString *portraitUri = [[dict objectForKey:@"headPortUrl"] stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
                                   if (!portraitUri || portraitUri.length <= 0) {
                                       portraitUri = [RCDUtilities defaultUserPortrait:user];
                                   }
                                   user.portraitUri = portraitUri;
                                   [[RCDataBaseManager shareInstance] insertUserToDB:user];
                                   
                                   RCDUserInfo *Details = [[RCDataBaseManager shareInstance] getFriendInfo:friendId];
                                   if (Details == nil) {
                                       Details = [[RCDUserInfo alloc] init];
                                   }
                                   Details.name = [dict objectForKey:@"nickName"];
                                   Details.portraitUri = portraitUri;
                                   Details.displayName = dict[@"nickName"];
                                   Details.userId = dict[@"userId"];

                                   [[RCDataBaseManager shareInstance] insertFriendToDB:Details];
                                   if (success) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           success(Details);
                                       });
                                   }
                               }
                               NSLog(@"infoDic------%@", infoDic);
                           } failure:^(NSError *err) {
                              failure(err);
                           }];
}

@end
