
//
//  AFHttpTool.m
//  RCloud_liv_demo
//
//  Created by Liv on 14-10-22.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "AFHttpTool.h"
#import <AFNetworking/AFNetworking.h>
#import "RCDCommonDefine.h"
#import <RongIMKit/RongIMKit.h>
#import "RautumnProject-Swift.h"
#import "RCDSettingUserDefaults.h"

#define DevDemoServer                                                          \
  @"http://119.254.110.241/" // Beijing SUN-QUAN 测试环境（北京）
#define ProDemoServer                                                          \
  @"http://119.254.110.79:8080/" // Beijing Liu-Bei 线上环境（北京）
#define PrivateCloudDemoServer @"http://139.217.26.223/" //私有云测试

#define DemoServer @"http://api.sealtalk.im/" //线上正式环境
//#define DemoServer @"http://apiqa.rongcloud.net/" //线上非正式环境
//#define DemoServer @"http://api.hitalk.im/" //测试环境

//#define ContentType @"text/plain"
#define ContentType @"text/html"

// 正式
#define PREURL @"http://www.rautumn.com/"
#define requestUrl @"http://www.rautumn.com/appserver/api"

//#define PREURL @"http://www.rautumn.com:8070/"
//#define requestUrl @"http://www.rautumn.com:8070/appserver/api"

@implementation AFHttpTool

+ (AFHttpTool *)shareInstance {
  static AFHttpTool *instance = nil;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    instance = [[[self class] alloc] init];
  });
  return instance;
}

+ (void)requestWihtMethod:(RequestMethodType)methodType
                      url:(NSString *)url
                   params:(NSDictionary *)params
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure {
//    NSURL *baseURL =  nil;
//    BOOL isPrivateMode = NO;
//#if RCDPrivateCloudManualMode
//    isPrivateMode = YES;
//#endif
  
//    if(isPrivateMode){
//        NSString *baseStr = [RCDSettingUserDefaults getRCDemoServer];
//        baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",baseStr]];
//    }else {
//        baseURL = [NSURL URLWithString:DemoServer];
//    }

    //获得请求管理者

    AFHTTPSessionManager * mgr =     [AFHTTPSessionManager manager];
    mgr.requestSerializer = [AFHTTPRequestSerializer serializer];
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];

//#ifdef ContentType
//  mgr.responseSerializer.acceptableContentTypes =
//      [NSSet setWithObject:ContentType];
//#endif
//  mgr.requestSerializer.HTTPShouldHandleCookies = YES;
//
//  NSString *cookieString =
//      [[NSUserDefaults standardUserDefaults] objectForKey:@"UserCookies"];
//
//  if (cookieString)
//    [mgr.requestSerializer setValue:cookieString forHTTPHeaderField:@"Cookie"];
//
//  url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
  switch (methodType) {
  case RequestMethodTypeGet: {
      // GET请求
      [mgr GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          if (success) {
              NSLog(@"responseObject-======-%@", responseObject);
//              NSDictionary * dict = [NSJSONSerialization ser];
              success(responseObject);
          }
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          if (failure) {
              failure(error);
          }
      }];
    
  } break;

  case RequestMethodTypePost: {
    // POST请求
      [mgr POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      NSDictionary *  response =    [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];

          if (success) {
              NSDictionary * allHeaderFields = [(NSHTTPURLResponse *)task.response allHeaderFields];
              if ([url isEqualToString:@"user/login"]) {
                  NSString *cookieString = [allHeaderFields
                                            valueForKey:@"Set-Cookie"];
                  NSMutableString *finalCookie = [NSMutableString new];
                  //                      NSData *data = [NSKeyedArchiver
                  //                      archivedDataWithRootObject:cookieString];
                  NSArray *cookieStrings =
                  [cookieString componentsSeparatedByString:@","];
                  for (NSString *temp in cookieStrings) {
                      NSArray *tempArr = [temp componentsSeparatedByString:@";"];
                      [finalCookie
                       appendString:[NSString
                                     stringWithFormat:@"%@;", tempArr[0]]];
                  }
                  [[NSUserDefaults standardUserDefaults] setObject:finalCookie
                                                            forKey:@"UserCookies"];
                  [[NSUserDefaults standardUserDefaults] synchronize];
              }
              success(response);
          }

      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          if (failure) {
              failure(error);
          }
          NSLog(@"%@", [NSString stringWithFormat:@"error----%@",error]);
      }];

  } break;
  default:
    break;
  }
}



// get user info
+ (void)getUserInfo:(NSString *)userId
            success:(void (^)(id response))success
            failure:(void (^)(NSError *err))failure {
    [AFHttpTool
     requestWihtMethod:RequestMethodTypeGet
     url:requestUrl
     params:@{@"action":@"getUserNickNameAndHed",@"userId":userId}
     success:success
     failure:failure];
}


// get group by id
+ (void)getGroupByID:(NSString *)groupID
             success:(void (^)(id response))success
             failure:(void (^)(NSError *err))failure {

    [AFHttpTool
     requestWihtMethod:RequestMethodTypeGet
     url:requestUrl
     params:@{@"action":@"getRauGroup",@"groupId":groupID,@"userId":[RCIM sharedRCIM].currentUserInfo.userId}
     success:success
     failure:failure];
    
}



//获取用户详细资料
+ (void)getFriendDetailsByID:(NSString *)friendId
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure {

  [AFHttpTool
   requestWihtMethod:RequestMethodTypeGet
   url:requestUrl
   params:@{@"action":@"getUserNickNameAndHed",@"userId":friendId}
   success:success
   failure:failure];
    
}
@end
