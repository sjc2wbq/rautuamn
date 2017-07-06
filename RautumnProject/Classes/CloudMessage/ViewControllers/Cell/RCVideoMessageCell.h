//
//  RCVideoMessageCell.h
//  RautumnProject
//
//  Created by 陈雷 on 2017/3/7.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface RCVideoMessageCell : RCMessageCell
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;
@property(nonatomic,strong)UIImageView *videoImageView;
@property(nonatomic,strong)UIImageView *videoPlayImageView;
//
- (void)setDataModel:(RCMessageModel *)model;
- (void)initialize;
@end
