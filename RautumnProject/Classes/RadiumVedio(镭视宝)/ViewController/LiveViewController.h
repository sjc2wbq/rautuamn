//
//  LiveViewController.h
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/10.
//  Copyright © 2017年 Rautumn. All rights reserved.
//
#import "RCDLiveMessageBaseCell.h"
#import "RCDLiveMessageModel.h"
#import <AFNetworking/AFNetworking.h>
#import "RCDLiveInputBar.h"
#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>
///输入栏扩展输入的唯一标示
#define PLUGIN_BOARD_ITEM_ALBUM_TAG    1001
#define PLUGIN_BOARD_ITEM_CAMERA_TAG   1002
#define PLUGIN_BOARD_ITEM_LOCATION_TAG 1003
#define PLUGIN_BOARD_ITEM_SMALLVideo_TAG 1004
#if RC_VOIP_ENABLE
#define PLUGIN_BOARD_ITEM_VOIP_TAG     1004
#endif

@interface UserInfo : RCUserInfo

@end

@interface LiveViewController : UIViewController
#pragma mark - 会话属性

/*!
 当前会话的会话类型
 */
@property(nonatomic) RCConversationType conversationType;

/*!
 目标会话ID
 */
@property(nonatomic, strong) NSString *targetId;

/*!
 屏幕方向
 */
@property(nonatomic, assign) BOOL isScreenVertical;

/*!
 播放内容地址
 */
@property(nonatomic, strong) NSString *contentURL;

#pragma mark - 会话页面属性

/*!
 聊天内容的消息Cell数据模型的数据源
 
 @discussion 数据源中存放的元素为消息Cell的数据模型，即RCDLiveMessageModel对象。
 */
@property(nonatomic, strong) NSMutableArray<RCDLiveMessageModel *> *conversationDataRepository;

/*!
 消息列表CollectionView和输入框都在这个view里
 */
@property(nonatomic, strong) UIView *contentView;

/*!
 会话页面的CollectionView
 */
@property(nonatomic, strong) UICollectionView *conversationMessageCollectionView;

#pragma mark - 输入工具栏

@property(nonatomic,strong) RCDLiveInputBar *inputBar;

#pragma mark - 显示设置
/*!
 设置进入聊天室需要获取的历史消息数量（仅在当前会话为聊天室时生效）
 
 @discussion 此属性需要在viewDidLoad之前进行设置。
 -1表示不获取任何历史消息，0表示不特殊设置而使用SDK默认的设置（默认为获取10条），0<messageCount<=50为具体获取的消息数量,最大值为50。
 */
@property(nonatomic, assign) int defaultHistoryMessageCountOfChatRoom;
/**
 * 顶部区域和底部区域按钮栏的背景颜色
 */
@property (nonatomic, strong) UIColor *barColor;
/**
 * 顶部区域和底部区域按钮栏的高度
 */
@property (nonatomic, assign) CGFloat barHeight;
/**
 * 用来控制按钮显示之后消失的时间
 */
@property (nonatomic, assign) NSTimeInterval fadeDelay;
/**
 * 用来控制快进快退按钮点击一次的跳转进度
 */
@property (nonatomic, assign) NSTimeInterval seekTimeSpan;
/**
 * 用来控制是否显示剩余时间还是显示总的时间长度
 */
@property (nonatomic) BOOL timeRemainingDecrements;
/**
 *  设置播放的视频地址，需要在试图启动之前设置
 *  参数url为本地地址或网络地址
 *  如果位本地地址，则需要用[NSURL fileURLWithPath:path]初始化NSURL
 *  如果为网络地址则需要用[NSURL URLWithString:path]初始化NSURL
 */
- (void) SetMoiveSource:(NSURL*)url;

@property(nonatomic,strong)NSMutableArray<UserInfo *> *userList;
@property(nonatomic,weak) NSString * titleStr;
@end
