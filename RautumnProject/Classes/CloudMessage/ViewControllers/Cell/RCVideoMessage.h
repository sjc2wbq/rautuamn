//
//  RCVideoMessage.h
//  RautumnProject
//
//  Created by 陈雷 on 2017/3/7.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import <RongIMLib/RCMessageContentView.h>
#define RCLocalMessageTypeIdentifier @”RC:SimpleMsg”
@interface RCVideoMessage : RCMessageContent<NSCoding>
@property(nonatomic,strong)NSString *content;
@property(nonatomic, strong) NSString* extra;
@property(nonatomic, strong) NSString* videoUri;
@property(nonatomic, strong) NSString* imageUri;
@property(nonatomic, strong) UIImage* thumbnailImage;
+(instancetype)messageWithContent:(NSString *)content;
@end
