//
//  LiveViewController.m
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/10.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

#import "LiveViewController.h"

#import <AliyunPlayerSDK/AliyunPlayerSDK.h>

#import <MediaPlayer/MediaPlayer.h>

#import <AVFoundation/AVAudioSession.h>

#import "Reachability.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDLiveMessageCell.h"
#import "RCDLiveTextMessageCell.h"
#import "RCDLiveGiftMessageCell.h"
#import "RCDLiveGiftMessage.h"
#import "RCDLiveTipMessageCell.h"
#import "RCDLiveMessageModel.h"
#import "RCDLive.h"
#import "RCDLiveCollectionViewHeader.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "RCDLiveKitUtility.h"
#import "RCDLiveKitCommonDefine.h"
#import <RongIMLib/RongIMLib.h>
#import <objc/runtime.h>
#import "RCDLiveTipMessageCell.h"
#import "MBProgressHUD.h"
#import "RautumnProject-Swift.h"
#import "RCDLivePortraitViewCell.h"
#import "AFHttpTool.h"
//#import "UCLOUDLivePlaying.h"
//#import "LELivePlaying.h"
//#import "QINIULivePlaying.h"
//#import "QCLOUDLivePlaying.h"

#import "UIView+RCDDanmaku.h"
#import "RCDDanmaku.h"
#import "RCDDanmakuManager.h"
#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]

//输入框的高度
#define MinHeight_InputView 50.0f
#define kBounds [UIScreen mainScreen].bounds.size



@implementation UserInfo
- (BOOL)isEqual:(UserInfo *)object{
    return [object.userId isEqualToString:self.userId];
}
@end

typedef NS_ENUM(NSInteger, GestureType){
    GestureTypeOfNone = 0,
    GestureTypeOfVolume,
    GestureTypeOfBrightness,
    GestureTypeOfProgress,
};

static const CGFloat iPhoneScreenPortraitWidth = 320.f;
@interface LiveViewController () <
UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout, RCDLiveMessageCellDelegate, UIGestureRecognizerDelegate,
UIScrollViewDelegate, UINavigationControllerDelegate,RCTKInputBarControlDelegate,RCConnectionStatusChangeDelegate,UIAlertViewDelegate,RCChatRoomStatusDelegate>
{
    NSURL*  mSourceURL;
    NSTimer* mTimer;
    NSTimer* mSeekTimer;
    BOOL replay;
    BOOL bSeeking;
    Reachability *conn;
    BOOL mPaused;
}

#define VolumeStep 0.02f
#define BrightnessStep 0.02f
#define MovieProgressStep 5.0f
@property(nonatomic,strong)UILabel *chatroomlabel;
@property(nonatomic,strong)UIImageView *chatroomImageView;

@property (nonatomic, strong) AliVcMediaPlayer* mPlayer;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *mPlayerView;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UISlider *playSlider;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UILabel *playTimeLabel;
@property (nonatomic, strong) UILabel *remainTimeLaber;
@property (nonatomic, strong) UIButton *seekForwardButton;
@property (nonatomic, strong) UIButton *seekBackwardButton;
@property (nonatomic, strong) UIView *activityBackgroundView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) Reachability *conn;

@property (nonatomic,assign)NSTimeInterval currentPlayPos;
@property (nonatomic,assign)CGFloat systemBrightness;
@property (nonatomic,assign)GestureType gestureType;
@property (nonatomic,assign)CGPoint originalLocation;
@property (nonatomic,strong)UIImageView *brightnessView;
@property (nonatomic,strong)UIProgressView *brightnessProgress;
@property (nonatomic,strong)UIView *progressTimeView;
@property (nonatomic,strong)UIImageView *prgForwardView;
@property (nonatomic,strong)UIImageView *prgBackwardView;
@property (nonatomic,strong)UILabel *progressTimeLable;
@property (nonatomic,assign)CGFloat progressValue;

@property(nonatomic, strong)RCDLiveCollectionViewHeader *collectionViewHeader;

/**
 *  存储长按返回的消息的model
 */
@property(nonatomic, strong) RCDLiveMessageModel *longPressSelectedModel;

/**
 *  是否需要滚动到底部
 */
@property(nonatomic, assign) BOOL isNeedScrollToButtom;

/**
 *  是否正在加载消息
 */
@property(nonatomic) BOOL isLoading;

/**
 *  会话名称
 */
@property(nonatomic,copy) NSString *navigationTitle;

/**
 *  点击空白区域事件
 */
@property(nonatomic, strong) UITapGestureRecognizer *resetBottomTapGesture;



/**
 *  直播互动文字显示
 */
@property(nonatomic,strong) UIView *titleView ;

/**
 *  播放器view
 */
@property(nonatomic,strong) UIView *liveView;

/**
 *  底部显示未读消息view
 */
@property (nonatomic, strong) UIView *unreadButtonView;
@property(nonatomic, strong) UILabel *unReadNewMessageLabel;
@property(nonatomic, strong) UILabel *seePsersonCountLabel;

/**
 *  滚动条不在底部的时候，接收到消息不滚动到底部，记录未读消息数
 */
@property (nonatomic, assign) NSInteger unreadNewMsgCount;

/**
 *  当前融云连接状态
 */
@property (nonatomic, assign) RCConnectionStatus currentConnectionStatus;

/**
 *  返回按钮
 */
@property (nonatomic, strong) UIButton *backBtn;

/**
 *  鲜花按钮
 */
@property(nonatomic,strong)UIButton *flowerBtn;

/**
 *  评论按钮
 */
@property(nonatomic,strong)UIButton *feedBackBtn;

/**
 *  掌声按钮
 */
@property(nonatomic,strong)UIButton *clapBtn;

@property(nonatomic,strong)UICollectionView *portraitsCollectionView;
@property(nonatomic,weak) UIAlertView *errorAV;

@property(nonatomic,strong) NSTimer *timer;

//

@end
/*
*  文本cell标示
*/
static NSString *const rctextCellIndentifier = @"rctextCellIndentifier";

/**
 *  小灰条提示cell标示
 */
static NSString *const RCDLiveTipMessageCellIndentifier = @"RCDLiveTipMessageCellIndentifier";

/**
 *  礼物cell标示
 */
static NSString *const RCDLiveGiftMessageCellIndentifier = @"RCDLiveGiftMessageCellIndentifier";

@implementation LiveViewController

- (UILabel *)chatroomlabel{
    if (!_chatroomlabel) {
        _chatroomlabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.chatroomImageView.frame) + 5, 35, 101, 37)];
        _chatroomlabel.numberOfLines = 2;
        _chatroomlabel.font = [UIFont systemFontOfSize:16.f];
        _chatroomlabel.textAlignment = NSTextAlignmentCenter;
        _chatroomlabel.textColor = [UIColor whiteColor];
        _chatroomlabel.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        _chatroomlabel.layer.cornerRadius = 20;
        _chatroomlabel.clipsToBounds = YES;
    }
    return  _chatroomlabel;
}
- (UIImageView *)chatroomImageView{
    if (!_chatroomImageView) {
        _chatroomImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_star"]];
        _chatroomImageView.frame = CGRectMake(14, 35, 37, 37);
        _chatroomImageView.contentMode = UIViewContentModeCenter;
    }
    return _chatroomImageView;
}
- (UILabel *)seePsersonCountLabel{
    if (!_seePsersonCountLabel) {
        _seePsersonCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.chatroomlabel.frame) + 5, 35, 101, 37)];
        _seePsersonCountLabel.numberOfLines = 2;
        _seePsersonCountLabel.font = [UIFont systemFontOfSize:14.f];
        _seePsersonCountLabel.textAlignment = NSTextAlignmentLeft;
        _seePsersonCountLabel.textColor = [UIColor whiteColor];
        _seePsersonCountLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _seePsersonCountLabel.layer.cornerRadius = 20;
        _seePsersonCountLabel.clipsToBounds = YES;
    }
    return  _seePsersonCountLabel;
}

//
@synthesize mPlayer;
@synthesize topBar;
@synthesize mPlayerView;
@synthesize bottomBar;
@synthesize playSlider;
@synthesize playBtn;
@synthesize volumeView;
@synthesize doneBtn;
@synthesize playTimeLabel;
@synthesize remainTimeLaber;
@synthesize seekBackwardButton;
@synthesize seekForwardButton;
@synthesize activityBackgroundView;
@synthesize activityIndicator;

@synthesize barColor;
@synthesize barHeight;
@synthesize seekTimeSpan;
@synthesize timeRemainingDecrements;
@synthesize fadeDelay;
@synthesize conn;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self rcinit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self rcinit];
    }
    return self;
}

- (void)rcinit {
    self.userList = [[NSMutableArray alloc] init];
    self.conversationDataRepository = [[NSMutableArray alloc] init];
    self.conversationMessageCollectionView = nil;
    self.targetId = nil;
    [self registerNotification];
    self.defaultHistoryMessageCountOfChatRoom = -1;
    [[RCIMClient sharedRCIMClient]setRCConnectionStatusChangeDelegate:self];
}

/**
 *  注册监听Notification
 */
- (void)registerNotification {
    //注册接收消息
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCDLiveKitDispatchMessageNotification
     object:nil];
    
}

/**
 *  注册cell
 *
 *  @param cellClass  cell类型
 *  @param identifier cell标示
 */
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.conversationMessageCollectionView registerClass:cellClass
                               forCellWithReuseIdentifier:identifier];
}
-(UserInfo *)parseUserInfoFormDic:(NSDictionary *)dic{
    UserInfo *user = [[UserInfo alloc]init];
    user.userId = [dic objectForKey: @"id" ];
    user.name = [dic objectForKey: @"name" ];
    user.portraitUri = [dic objectForKey: @"icon" ];
    return user;
}
- (void)onChatRoomQuited:(NSString *)chatroomId{
    NSLog(@"onChatRoomQuited");

}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    RCUserInfo * userinfo = [[RCUserInfo alloc] init];
    userinfo.name = [UserModel shared].name;
    userinfo.portraitUri = [[UserModel shared].portraitUri stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
    userinfo.userId = [NSString stringWithFormat:@"%ld",(long)[UserModel shared].ID];
    [RCIM sharedRCIM].currentUserInfo = userinfo;
    [RCIMClient sharedRCIMClient].currentUserInfo = userinfo;

    
    
//    [MPMusicPlayerController applicationMusicPlayer].volume = 1;
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    self.fd_interactivePopDisabled = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    barHeight = 70.f;
    barColor = [UIColor colorWithRed:195/255.0 green:29/255.0 blue:29/255.0 alpha:0.5];
    fadeDelay = 5.0f;
    timeRemainingDecrements = YES;
    seekTimeSpan = 10000;
    mPaused = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [self PlayMoive];
    
    mPlayer.scalingMode = scalingModeAspectFitWithCropping;
    
    //add network notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
    self.conn = [Reachability reachabilityForInternetConnection];
    [self.conn startNotifier];
    
    
    //默认进行弹幕缓存，不过量加载弹幕，如果想要同时大批量的显示弹幕，设置为yes，弹幕就不会做弹道检测和缓存
    RCDanmakuManager.isAllowOverLoad = NO;
    
 
    //初始化UI
    [self initializedSubViews];
    
    [self initChatroomMemberInfo];
    
    [[RCIMClient sharedRCIMClient] setChatRoomStatusDelegate:self];
    __weak LiveViewController *weakSelf = self;
    
    //直播间类型进入时需要调用加入直播间接口，退出时需要调用退出直播间接口
    if (ConversationType_CHATROOM == self.conversationType) {
        [[RCIMClient sharedRCIMClient]
         joinChatRoom:self.targetId
         messageCount:self.defaultHistoryMessageCountOfChatRoom
         success:^{
             dispatch_async(dispatch_get_main_queue(), ^{
                 //直播播放器
                 //                 self.livePlayingManager = [[KSYLivePlaying alloc] initPlaying:self.contentURL];
                 //                 //                 self.livePlayingManager = [[LELivePlaying alloc] initPlaying:@"201604183000000z4"];
                 //                 //                 self.livePlayingManager = [[QINIULivePlaying alloc] initPlaying:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"];
                 //                 //                 self.livePlayingManager = [[QCLOUDLivePlaying alloc] initPlaying:@"http://2527.vod.myqcloud.com/2527_117134a2343111e5b8f5bdca6cb9f38c.f20.mp4"];
                 //                 [self initializedLiveSubViews];
                 //                 [self.livePlayingManager startPlaying];
                 RCInformationNotificationMessage *joinChatroomMessage = [[RCInformationNotificationMessage alloc]init];
                 joinChatroomMessage.message = [NSString stringWithFormat: @"加入了直播间",@""];
                 [self sendMessage:joinChatroomMessage pushContent:nil];
             });
         }
         error:^(RCErrorCode status) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (status == KICKED_FROM_CHATROOM) {
                     [weakSelf loadErrorAlert:NSLocalizedStringFromTable(@"JoinChatRoomRejected", @"RongCloudKit", nil)];
                 } else {
                     [weakSelf loadErrorAlert:NSLocalizedStringFromTable(@"JoinChatRoomFailed", @"RongCloudKit", nil)];
                 }
             });
         }];
    }
    [self addTimer];
   
    
}
- (void)addTimer{
    self.timer  = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(timeRun) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)removeTimer{
    [self.timer invalidate];
    self.timer = nil;
}
- (void)timeRun{
    __block typeof(self) weakSelf = self;
    [[RCIMClient sharedRCIMClient] getChatRoomInfo:self.targetId count:10 order:RC_ChatRoom_Member_Asc success:^(RCChatRoomInfo *chatRoomInfo) {
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
        [chatRoomInfo.memberInfoArray enumerateObjectsUsingBlock:^(RCChatRoomMemberInfo *  _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
            UserInfo * userInfo = [[UserInfo alloc] init];
            userInfo.userId = info.userId;
            if ([self.userList containsObject:userInfo]) {
                //chatroomQueryUser
                
            }
    
            [AFHttpTool requestWihtMethod:RequestMethodTypeGet url:@"http://www.rautumn.com/appserver/api" params:@{@"action":@"chatroomQueryUser",@"userId":[NSString stringWithFormat:@"%ld",(long)[UserModel shared].ID],@"rsvId":self.targetId} success:^(id response) {
                NSDictionary * infoDic = [NSJSONSerialization JSONObjectWithData:(NSData *)response options:NSJSONReadingAllowFragments error:nil];
                if ([infoDic[@"result_code"] isEqualToString:@"0"]) {
                
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary * dict = [infoDic objectForKey:@"result_data"];
                        NSArray * dicts = [dict objectForKey:@"userList"];
                        NSMutableArray * array = [NSMutableArray array];
                        [dicts enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            UserInfo *userInfo = [[UserInfo alloc] init];
                            userInfo.name = obj[@"nickName"];
                            userInfo.userId = obj[@"userId"];
                            userInfo.portraitUri = obj[@"headPortUrl"];
                            [array addObject:userInfo];
                        }];
                        [weakSelf.userList removeAllObjects];
                        [weakSelf.userList addObjectsFromArray:array];
                        [weakSelf.portraitsCollectionView reloadData];
                    });
               }
            } failure:^(NSError *err) {
                
            }];
        }];
            
            weakSelf.seePsersonCountLabel.text = [NSString stringWithFormat:@"%lu人",(unsigned long)chatRoomInfo.totalMemberCount];
            weakSelf.seePsersonCountLabel.sd_x = CGRectGetMaxX(self.chatroomlabel.frame) + 5;
            weakSelf.seePsersonCountLabel.sd_width = [self.chatroomlabel.text boundingRectWithSize:CGSizeMake(250, 35) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.width + 10;
            
        });
    } error:^(RCErrorCode status) {
        
    }];

}
- (void)networkStateChange
{
    //网络流判断网络状态
    if (mSourceURL && ![mSourceURL isFileURL]) {
        [self checkNetworkState];
    }
}

- (void)checkNetworkState
{
    // 1.检测wifi状态
    Reachability *wifi = [Reachability reachabilityForLocalWiFi];
    
    // 2.检测手机是否能上网络(WIFI\3G\2.5G)
    Reachability *conn = [Reachability reachabilityForInternetConnection];
    
    // 3.判断网络状态
    if ([wifi currentReachabilityStatus] != NotReachable) { // 有wifi
        NSLog(@"有wifi");
        
    } else if ([conn currentReachabilityStatus] != NotReachable) { // 没有使用wifi, 使用手机自带网络进行上网
        NSLog(@"使用手机自带网络进行上网");
        
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"没有wifi连接，是否重新连接播放"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"重新连接",nil];
        
                [alert show];
        
                if (mPlayer) {
                    [mPlayer stop];
                }
        
    } else { // 没有网络
        
        NSLog(@"没有网络");
    }
}


- (void)becomeActive{
    [self EnterForeGroundPlayVideo];
}

- (void)resignActive{
    [self EnterBackGroundPauseVideo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) SetMoiveSource:(NSURL*)url
{
    mSourceURL = [url copy];
}

- (void) PlayMoive
{
    if(mSourceURL == nil)
        return;
    
    //new the player
    mPlayer = [[AliVcMediaPlayer alloc] init];
    
    //add player controls
    [self setupControls];
    
    //create player, and  set the show view
    [mPlayer create:mPlayerView];
    
    //register notifications
    [self addPlayerObserver];
    
    mPlayer.mediaType = MediaType_AUTO;
    mPlayer.timeout = 25000;
    mPlayer.dropBufferDuration = 8000;
    
    //timer to update player progress
    mTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(UpdatePrg:) userInfo:nil repeats:YES];
    mSeekTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(SeekTimer:) userInfo:nil repeats:YES];
    [mTimer fire];
    [mSeekTimer fire];
    
    replay = NO;
    bSeeking = NO;
    
    //prepare and play the video
    AliVcMovieErrorCode err = [mPlayer prepareToPlay:mSourceURL];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"preprare failed,error code is %d",(int)err);
        return;
    }
    
//    mPlayer.muteMode = YES;
    
    err = [mPlayer play];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"play failed,error code is %d",(int)err);
        return;
    }
    
    //[self performSelector:@selector(hideControls:) withObject:nil afterDelay:fadeDelay];
    
    [self showLoadingIndicators];
}

- (void) setupControls
{
    //视频显示区域
    mPlayerView = [[UIView alloc] init];
    mPlayerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mPlayerView];
    
    //顶部栏
    topBar = [[UIView alloc] init];
    topBar.backgroundColor = barColor;
    topBar.alpha = 1.0f;
//    [self.view addSubview:topBar];
    
    //底部区域栏
    bottomBar = [[UIView alloc] init];
    bottomBar.backgroundColor = barColor;
    bottomBar.alpha = 1.0f;
//    [self.view addSubview:bottomBar];
    
    //顶部栏退出按钮
    doneBtn = [[UIButton alloc] init];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    [doneBtn setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake(1.f, 1.f);
    [doneBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
    [doneBtn addTarget:self action:@selector(DonePressed:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:doneBtn];
    
    //顶部栏播放进度slider
    playSlider = [[UISlider alloc] init];
    playSlider.value = 0.f;
    playSlider.continuous = YES;
    [playSlider addTarget:self action:@selector(durationSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [playSlider addTarget:self action:@selector(durationSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [playSlider addTarget:self action:@selector(durationSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    //    [topBar addSubview:playSlider];
    [bottomBar addSubview:playSlider];
    
    //播放时间
    playTimeLabel = [[UILabel alloc] init];
    playTimeLabel.backgroundColor = [UIColor clearColor];
    playTimeLabel.font = [UIFont systemFontOfSize:12.f];
    playTimeLabel.textColor = [UIColor lightTextColor];
    playTimeLabel.textAlignment = NSTextAlignmentRight;
    playTimeLabel.text = @"00:00:00";
    playTimeLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    playTimeLabel.layer.shadowRadius = 1.f;
    playTimeLabel.layer.shadowOffset = CGSizeMake(1.f, 1.f);
    playTimeLabel.layer.shadowOpacity = 0.8f;
    //    [topBar addSubview:playTimeLabel];
    [bottomBar addSubview:playTimeLabel];
    
    //剩余时间
    remainTimeLaber = [[UILabel alloc] init];
    remainTimeLaber.backgroundColor = [UIColor clearColor];
    remainTimeLaber.font = [UIFont systemFontOfSize:12.f];
    remainTimeLaber.textColor = [UIColor lightTextColor];
    remainTimeLaber.textAlignment = NSTextAlignmentLeft;
    remainTimeLaber.text = @"00:00:00";
    remainTimeLaber.layer.shadowColor = [UIColor blackColor].CGColor;
    remainTimeLaber.layer.shadowRadius = 1.f;
    remainTimeLaber.layer.shadowOffset = CGSizeMake(1.f, 1.f);
    remainTimeLaber.layer.shadowOpacity = 0.8f;
    //    [topBar addSubview:remainTimeLaber];
    [bottomBar addSubview:remainTimeLaber];
    
    //底部播放按钮
    playBtn = [[UIButton alloc] init];
    [playBtn setImage:[UIImage imageNamed:@"moviePause.png"] forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@"moviePlay.png"] forState:UIControlStateSelected];
    [playBtn setSelected:NO];
    playBtn.hidden = NO;
    [playBtn addTarget:self action:@selector(playPausePressed:) forControlEvents:UIControlEventTouchDown];
    [bottomBar addSubview:playBtn];
    
    //    //底部音量控制slider
    //    volumeView = [[MPVolumeView alloc] init];
    //    [volumeView setShowsRouteButton:NO];
    //    [volumeView setShowsVolumeSlider:YES];
    //    [bottomBar addSubview:volumeView];
    
    //底部快进按钮
    seekForwardButton = [[UIButton alloc] init];
    [seekForwardButton setImage:[UIImage imageNamed:@"sound.png"] forState:UIControlStateNormal];
    [seekForwardButton setImage:[UIImage imageNamed:@"mute.png"] forState:UIControlStateSelected];
    [seekForwardButton addTarget:self action:@selector(seekForwardPressed:) forControlEvents:UIControlEventTouchUpInside];
    //seekForwardButton.enabled = NO;
    seekForwardButton.hidden = NO;
    [bottomBar addSubview:seekForwardButton];
    
    //底部快退按钮
    //    seekBackwardButton = [[UIButton alloc] init];
    //    [seekBackwardButton setImage:[UIImage imageNamed:@"movieBackward.png"] forState:UIControlStateNormal];
    //    [seekBackwardButton setImage:[UIImage imageNamed:@"movieBackwardSelected.png"] forState:UIControlStateSelected];
    //    [seekBackwardButton addTarget:self action:@selector(seekBackwardPressed:) forControlEvents:UIControlEventTouchUpInside];
    //    //seekBackwardButton.enabled = NO;
    //    seekBackwardButton.hidden = NO;
    //    [bottomBar addSubview:seekBackwardButton];
    
    //缓冲指示
    activityBackgroundView = [[UIView alloc] init];
    [activityBackgroundView setBackgroundColor:[UIColor clearColor]];
    activityBackgroundView.alpha = 0.f;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.alpha = 0.f;
    activityIndicator.hidesWhenStopped = YES;
    
    //亮度调节图标
    _brightnessView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2, self.view.frame.size.height/2, 125, 125)];
    _brightnessView.image = [UIImage imageNamed:@"video_brightness_bg.png"];
    _brightnessProgress = [[UIProgressView alloc]initWithFrame:CGRectMake(_brightnessView.frame.size.width/2, _brightnessView.frame.size.height/2-30, 80, 10)];
    _brightnessProgress.trackImage = [UIImage imageNamed:@"video_num_bg.png"];
    _brightnessProgress.progressImage = [UIImage imageNamed:@"video_num_front.png"];
    _brightnessProgress.progress = [UIScreen mainScreen].brightness;
    [_brightnessView addSubview:_brightnessProgress];
//    [self.view addSubview:_brightnessView];
    _brightnessView.alpha = 0;
    
    //手势进度控制
    _progressTimeView = [[UIView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2-100, self.view.bounds.size.height/2-30, 200, 30)];
    _prgForwardView = [[UIImageView alloc]initWithFrame:CGRectMake(82,5,36,30)];
    _prgForwardView.image = [UIImage imageNamed:@"movieForward.png"];
    _prgBackwardView = [[UIImageView alloc]initWithFrame:CGRectMake(82,5,36,30)];
    _prgBackwardView.image = [UIImage imageNamed:@"movieBackward.png"];
    
    _progressTimeView.backgroundColor = [UIColor clearColor];
    _progressTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 200, 60)];
    _progressTimeLable.textAlignment = NSTextAlignmentCenter;
    _progressTimeLable.textColor = [UIColor whiteColor];
    _progressTimeLable.backgroundColor = [UIColor clearColor];
    _progressTimeLable.font = [UIFont systemFontOfSize:25];
    _progressTimeLable.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    _progressTimeLable.shadowOffset = CGSizeMake(1.0, 1.0);
    [_progressTimeView addSubview:_progressTimeLable];
    [_progressTimeView addSubview:_prgForwardView];
    [_progressTimeView addSubview:_prgBackwardView];
    _prgForwardView.hidden = YES;
    _prgBackwardView.hidden = YES;
    _progressTimeView.hidden = YES;
//    [self.view addSubview:_progressTimeView];
    
    [self adjustLayoutsubViews];
}

- (void)showLoadingIndicators {
    [self.view addSubview:activityBackgroundView];
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    [UIView animateWithDuration:0.2f animations:^{
        activityBackgroundView.alpha = 1.f;
        activityIndicator.alpha = 1.f;
    }];
}

- (void)hideLoadingIndicators {
    [UIView animateWithDuration:0.2f delay:0.0 options:0 animations:^{
        self.activityBackgroundView.alpha = 0.0f;
        self.activityIndicator.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.activityBackgroundView removeFromSuperview];
        [self.activityIndicator removeFromSuperview];
    }];
}

- (void)DonePressed:(UIButton *)button {
    [self removeTimer];
    [mTimer invalidate];
    mTimer = nil;
    
    //    [seekBackwardButton setSelected:NO];
    //    [seekForwardButton setSelected:NO];
    [mSeekTimer invalidate];
    mSeekTimer = nil;
    
    if(mPlayer != nil)
        [mPlayer destroy];
    
    [self removePlayerObserver];
    
    mPlayer = nil;
    mSourceURL = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)seekForwardPressed:(UIButton *)button {
    //[mPlayer seekTo:mPlayer.currentPosition+seekTimeSpan];
    button.selected = !button.selected;
    if (button.selected) {
        mPlayer.muteMode = YES;
    }
    else {
        mPlayer.muteMode = NO;
    }
}

//- (void)seekBackwardPressed:(UIButton *)button {
//    //[mPlayer seekTo:mPlayer.currentPosition-seekTimeSpan];
//    button.selected = !button.selected;
//    self.seekForwardButton.selected = NO;
//    if (button.selected) {
//        [self showControls:nil];
//    }
//    else {
//        [self performSelector:@selector(hideControls:) withObject:nil afterDelay:fadeDelay];
//    }
//}

- (float)iOSVersion {
    static float version = 0.f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [[[UIDevice currentDevice] systemVersion] floatValue];
    });
    return version;
}

- (void)adjustLayoutsubViews {
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    float iosVersion = [self iOSVersion];
    if(iosVersion < 8.0) {
        if(UIDeviceOrientationIsLandscape(orientation) || orientation == UIDeviceOrientationUnknown ||
           orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown) {
            //landscape assume  width > height
            if(width<height) {
                CGFloat temp = width;
                width = height;
                height = temp;
            }
        }
    }
    
    mPlayerView.frame = CGRectMake(0,0,width,height);
    
    //when change the view size, need to reset the view to the play.
    mPlayer.view = mPlayerView;
    
    double pos = mPlayer.currentPosition;
    
    CGFloat paddingFromBezel = width <= iPhoneScreenPortraitWidth ? 10.f : 20.f;
    CGFloat paddingBetweenButtons = width <= iPhoneScreenPortraitWidth ? 10.f : 30.f;
    CGFloat paddingBetweenLabelsAndSlider = 10.f;
    CGFloat playWidth = 18.f;
    CGFloat playHeight = 22.f;
    CGFloat labelWidth = 60.f;
    CGFloat sliderHeight = 34.f;
    topBar.frame = CGRectMake(0, 0, width, barHeight);
    doneBtn.frame = CGRectMake(paddingFromBezel, 0, 40.f, barHeight);
    playTimeLabel.frame = CGRectMake(doneBtn.frame.origin.x + doneBtn.frame.size.width + paddingBetweenButtons, 0, labelWidth, barHeight);
    remainTimeLaber.frame = CGRectMake(width - paddingFromBezel-labelWidth,0,labelWidth,barHeight);
    
    CGFloat timeRemainingX = remainTimeLaber.frame.origin.x;
    CGFloat timeElapsedX = playTimeLabel.frame.origin.x;
    CGFloat sliderWidth = ((timeRemainingX - paddingBetweenLabelsAndSlider) - (timeElapsedX + remainTimeLaber.frame.size.width + paddingBetweenLabelsAndSlider));
    playSlider.frame = CGRectMake(timeElapsedX + remainTimeLaber.frame.size.width + paddingBetweenLabelsAndSlider, barHeight/2 - sliderHeight/2, sliderWidth, sliderHeight);
    
    CGFloat bottomHeight = barHeight;
    bottomBar.frame = CGRectMake(0, height - bottomHeight, width, bottomHeight);
    //    playBtn.frame = CGRectMake(width/2-playWidth/2, bottomHeight/2 - playHeight/2, playWidth, playHeight);
    playBtn.frame = CGRectMake(paddingFromBezel, 0, 40.f, barHeight);
    CGFloat seekWidth = 36.f;
    CGFloat seekHeight = 20.f;
    CGFloat paddingBetweenPlaybackButtons = width <= iPhoneScreenPortraitWidth ? 20.f : 30.f;
    
    seekForwardButton.frame = CGRectMake(playBtn.frame.origin.x + playBtn.frame.size.width + paddingBetweenPlaybackButtons-30, barHeight/2 - seekHeight/2 + 1.f, seekWidth, seekHeight);
    //    seekBackwardButton.frame = CGRectMake(playBtn.frame.origin.x - paddingBetweenPlaybackButtons - seekWidth, barHeight/2 - seekHeight/2 + 1.f, seekWidth, seekHeight);
    
    //    //hide volume view in iPhone's portrait orientation
    //    if (width <= iPhoneScreenPortraitWidth) {
    //        volumeView.alpha = 0.f;
    //    } else {
    //        volumeView.alpha = 1.f;
    //        CGFloat volumeHeight = 20.f;
    //        CGFloat volumeWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 210.f : 80.f;
    //        volumeView.frame = CGRectMake(paddingFromBezel, barHeight/2 - volumeHeight/2, volumeWidth, volumeHeight);
    //    }
    
    _brightnessView.frame = CGRectMake(width/2-63, height/2-63, 125, 125);
    _brightnessProgress.frame = CGRectMake(25, 100, 80, 10);
    
    _progressTimeView.frame = CGRectMake(width/2-100, height/2-15, 200, 30);
    
    activityBackgroundView.frame = CGRectMake(0,120,width,height - 120 - 50);
    activityIndicator.frame = CGRectMake(0,120,width,height - 120 - 50);
}

-(void) EnterBackGroundPauseVideo
{
    
    if(mPlayer && mPaused == NO) {
        [mPlayer pause];
    }
    
    [UIScreen mainScreen].brightness = _systemBrightness;
}

-(void) EnterForeGroundPlayVideo
{
    if(mPlayer && mPaused == NO) {
        [mPlayer play];
        
        [self showControls:nil];
        [playBtn setSelected:NO];
    }
    [UIScreen mainScreen].brightness = _brightnessProgress.progress;
}

//-(void) EnterBackGroundPauseVideo_live_restart
//{
//    if(mPlayer) {
//        if (mPlayer.duration<=0) {
//            [mPlayer stop];
//        }
//        else {
//            _currentPlayPos = mPlayer.currentPosition;
//            [mPlayer pause];
//        }
//    }
//
//    [UIScreen mainScreen].brightness = _systemBrightness;
//}
//
//-(void) EnterForeGroundPlayVideo_live_restart
//{
//    if(mPlayer) {
//        if (mPlayer.duration<=0) {
//            [mPlayer prepareToPlay:mSourceURL];
//            [mPlayer play];
//            [self showLoadingIndicators];
//        }
//        else {
//            [mPlayer play];
//            [mPlayer seekTo:_currentPlayPos];
//        }
//
//        [self showControls:nil];
//        [playBtn setSelected:NO];
//    }
//
//    [UIScreen mainScreen].brightness = _brightnessProgress.progress;
//}

-(void)replay
{
    [mPlayer prepareToPlay:mSourceURL];
    replay = NO;
    bSeeking = NO;
    [mPlayer play];
    [playBtn setSelected:NO];
}

- (void)playPausePressed:(UIButton *)button {
    
    if(playBtn.selected) {
        if(replay) {
            [mPlayer prepareToPlay:mSourceURL];
            replay = NO;
            bSeeking = NO;
        }
        
        [mPlayer play];
        [mPlayer setMuteMode:YES];
        [playBtn setSelected:NO];
    }
    else {
        [mPlayer pause];
        [playBtn setSelected:YES];
    }
    [self performSelector:@selector(hideControls:) withObject:nil afterDelay:fadeDelay];
}

- (void)durationSliderTouchBegan:(UISlider *)slider {
    bSeeking = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControls:) object:nil];
}

- (void)durationSliderTouchEnded:(UISlider *)slider {
    [mPlayer seekTo:playSlider.value];
    [self performSelector:@selector(hideControls:) withObject:nil afterDelay:fadeDelay];
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    currentTime = currentTime / 1000.0;
    totalTime = totalTime / 1000.0;
    double minutesElapsed = floor(fmod(currentTime/ 60.0,60.0));
    double secondsElapsed = floor(fmod(currentTime,60.0));
    double hourElapsed = floor(currentTime/ 3600.0);
    
    playTimeLabel.text = [NSString stringWithFormat:@"%02.0f:%02.0f:%02.0f", hourElapsed,minutesElapsed, secondsElapsed];
    
    double minutesRemaining;
    double secondsRemaining;
    double hourRemaining;
    if (timeRemainingDecrements) {
        hourRemaining = floor((totalTime - currentTime)/ 3600.0);
        minutesRemaining = floor(fmod((totalTime - currentTime)/ 60.0,60.0));
        secondsRemaining = floor(fmod((totalTime - currentTime),60.0));
    } else {
        minutesRemaining = floor(fmod(totalTime/ 60.0,60.0));
        secondsRemaining = floor(fmod(totalTime,60.0));
        hourRemaining = floor(totalTime/ 3600.0);
    }
    remainTimeLaber.text = timeRemainingDecrements ? [NSString stringWithFormat:@"-%02.0f:%02.0f:%02.0f", hourRemaining,minutesRemaining, secondsRemaining] : [NSString stringWithFormat:@"%02.0f:%02.0f:%02.0f", hourRemaining,minutesRemaining, secondsRemaining];
}

-(void)SeekTimer:(NSTimer *)timer {
    
    //    if(mPlayer) {
    //        if(seekForwardButton.selected)
    //            [mPlayer seekTo:mPlayer.currentPosition+seekTimeSpan];
    //        if(seekBackwardButton.selected)
    //            [mPlayer seekTo:mPlayer.currentPosition-seekTimeSpan];
    //    }
}

#define PROP_DOUBLE_VIDEO_DECODE_FRAMES_PER_SECOND  10001
#define PROP_DOUBLE_VIDEO_OUTPUT_FRAMES_PER_SECOND  10002

#define FFP_PROP_DOUBLE_OPEN_FORMAT_TIME                 18001
#define FFP_PROP_DOUBLE_FIND_STREAM_TIME                 18002
#define FFP_PROP_DOUBLE_OPEN_STREAM_TIME                 18003
#define FFP_PROP_DOUBLE_1st_VFRAME_SHOW_TIME             18004
#define FFP_PROP_DOUBLE_1st_AFRAME_SHOW_TIME             18005
#define FFP_PROP_DOUBLE_1st_VPKT_GET_TIME                18006
#define FFP_PROP_DOUBLE_1st_APKT_GET_TIME                18007
#define FFP_PROP_DOUBLE_1st_VDECODE_TIME                 18008
#define FFP_PROP_DOUBLE_1st_ADECODE_TIME                 18009
#define FFP_PROP_DOUBLE_DECODE_TYPE                 	 18010

#define FFP_PROP_DOUBLE_LIVE_DISCARD_DURATION            18011
#define FFP_PROP_DOUBLE_LIVE_DISCARD_CNT                 18012
#define FFP_PROP_DOUBLE_DISCARD_VFRAME_CNT               18013

#define FFP_PROP_DOUBLE_RTMP_OPEN_DURATION               18040
#define FFP_PROP_DOUBLE_RTMP_OPEN_RTYCNT                 18041
#define FFP_PROP_DOUBLE_RTMP_NEGOTIATION_DURATION        18042
#define FFP_PROP_DOUBLE_HTTP_OPEN_DURATION               18060
#define FFP_PROP_DOUBLE_HTTP_OPEN_RTYCNT                 18061
#define FFP_PROP_DOUBLE_HTTP_REDIRECT_CNT                18062
#define FFP_PROP_DOUBLE_TCP_CONNECT_TIME                 18080
#define FFP_PROP_DOUBLE_TCP_DNS_TIME                     18081

//decode type
#define     FFP_PROPV_DECODER_UNKNOWN                   0
#define     FFP_PROPV_DECODER_AVCODEC                   1
#define     FFP_PROPV_DECODER_MEDIACODEC                2
#define     FFP_PROPV_DECODER_VIDEOTOOLBOX              3

#define FFP_PROP_INT64_VIDEO_CACHED_DURATION            20005
#define FFP_PROP_INT64_AUDIO_CACHED_DURATION            20006
#define FFP_PROP_INT64_VIDEO_CACHED_BYTES               20007
#define FFP_PROP_INT64_AUDIO_CACHED_BYTES               20008
#define FFP_PROP_INT64_VIDEO_CACHED_PACKETS             20009
#define FFP_PROP_INT64_AUDIO_CACHED_PACKETS             20010

-(void) testInfo
{
    if (mPlayer == nil) {
        return;
    }
    
    double video_decode_fps = [mPlayer getPropertyDouble:PROP_DOUBLE_VIDEO_DECODE_FRAMES_PER_SECOND defaultValue:0];
    double video_render_fps = [mPlayer getPropertyDouble:PROP_DOUBLE_VIDEO_OUTPUT_FRAMES_PER_SECOND defaultValue:0];
    printf("video_decode_fps is %lf, video_render_fps is %lf\n",video_decode_fps,video_render_fps);
    
    return;
    
    double open_format_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_OPEN_FORMAT_TIME defaultValue:0];
    double find_stream_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_FIND_STREAM_TIME defaultValue:0];
    double open_stream_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_OPEN_STREAM_TIME defaultValue:0];
    printf("open_format_time is %lf, find_stream_time is %lf, open_stream_time is %lf\n",open_format_time,find_stream_time,open_stream_time);
    
    double video_first_decode_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_1st_VDECODE_TIME defaultValue:0];
    double video_first_get_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_1st_VPKT_GET_TIME defaultValue:0];
    double video_first_show_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_1st_VFRAME_SHOW_TIME defaultValue:0];
    printf("video_first_decode_time is %lf, video_first_get_time is %lf, video_first_show_time is %lf\n",video_first_decode_time,video_first_get_time,video_first_show_time);
    
    double audio_first_decode_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_1st_ADECODE_TIME defaultValue:0];
    double audio_first_get_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_1st_APKT_GET_TIME defaultValue:0];
    double audio_first_show_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_1st_AFRAME_SHOW_TIME defaultValue:0];
    double video_decode_type = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_DECODE_TYPE defaultValue:0];
    printf("audio_first_decode_time is %lf, audio_first_get_time is %lf, audio_first_show_time is %lf,video_decode_type is %lf\n",audio_first_decode_time,audio_first_get_time,audio_first_show_time,video_decode_type);
    
    double rtmp_open_duration = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_RTMP_OPEN_DURATION defaultValue:0];
    double rtmp_open_retry_count = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_RTMP_OPEN_RTYCNT defaultValue:0];
    double rtmp_negotiation_duration = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_RTMP_NEGOTIATION_DURATION defaultValue:0];
    printf("rtmp_open_duration is %lf, rtmp_open_retry_count is %lf, rtmp_negotiation_duration is %lf\n",rtmp_open_duration,rtmp_open_retry_count,rtmp_negotiation_duration);
    
    double http_open_duration = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_HTTP_OPEN_DURATION defaultValue:0];
    double http_open_retry_count = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_HTTP_OPEN_RTYCNT defaultValue:0];
    double http_redirect_count = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_HTTP_REDIRECT_CNT defaultValue:0];
    printf("http_open_duration is %lf, http_open_retry_count is %lf, http_redirect_count is %lf\n",http_open_duration,http_open_retry_count,http_redirect_count);
    
    double tcp_connect_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_TCP_CONNECT_TIME defaultValue:0];
    double tcp_dns_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_TCP_DNS_TIME defaultValue:0];
    printf("tcp_connect_time is %lf, tcp_dns_time is %lf\n",tcp_connect_time,tcp_dns_time);
    
    int64_t video_cached_duration = [mPlayer getPropertyLong:FFP_PROP_INT64_VIDEO_CACHED_DURATION defaultValue:0];
    int64_t video_cached_bytes = [mPlayer getPropertyLong:FFP_PROP_INT64_VIDEO_CACHED_BYTES defaultValue:0];
    int64_t video_cached_packets = [mPlayer getPropertyLong:FFP_PROP_INT64_VIDEO_CACHED_PACKETS defaultValue:0];
    printf("video_cached_duration is %lld, video_cached_bytes is %lld, video_cached_packets is %lld\n",video_cached_duration,video_cached_bytes,video_cached_packets);
    
    int64_t audio_cached_duration = [mPlayer getPropertyLong:FFP_PROP_INT64_AUDIO_CACHED_DURATION defaultValue:0];
    int64_t audio_cached_bytes = [mPlayer getPropertyLong:FFP_PROP_INT64_AUDIO_CACHED_BYTES defaultValue:0];
    int64_t audio_cached_packets = [mPlayer getPropertyLong:FFP_PROP_INT64_AUDIO_CACHED_PACKETS defaultValue:0];
    printf("audio_cached_duration is %lld, audio_cached_bytes is %lld, audio_cached_packets is %lld\n",audio_cached_duration,audio_cached_bytes,audio_cached_packets);
    
    double drop_frame_count = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_LIVE_DISCARD_CNT defaultValue:0];
    double drop_v_frame_count = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_DISCARD_VFRAME_CNT defaultValue:0];
    double drop_frame_duration = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_LIVE_DISCARD_DURATION defaultValue:0];
    printf("drop_frame_count is %lf, drop_v_frame_count is %lf, drop_frame_duration is %lf\n",drop_frame_count,drop_v_frame_count,drop_frame_duration);
}

-(void)UpdatePrg:(NSTimer *)timer{
    
    //[self testInfo];
    
    //when seeking, do not update the slider
    if(bSeeking)
        return;
    
    playSlider.value = mPlayer.currentPosition;
    
    double currentTime = floor(playSlider.value);
    double totalTime = floor(mPlayer.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}

- (void)showControls:(void(^)(void))completion {
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControls:) object:nil];
//    [bottomBar setNeedsDisplay];
//    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
//        bottomBar.alpha = 1.f;
//        topBar.alpha = 1.f;
//    } completion:^(BOOL finished) {
//        if (completion)
//            completion();
//        //[self performSelector:@selector(hideControls:) withObject:nil afterDelay:fadeDelay];
//    }];
}

- (void)hideControls:(void(^)(void))completion {
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControls:) object:nil];
//    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
//        bottomBar.alpha = 0.f;
//        topBar.alpha = 0.f;
//    } completion:^(BOOL finished) {
//        if (completion)
//            completion();
//    }];
}

//recieve prepared notification
- (void)OnVideoPrepared:(NSNotification *)notification {
    
    NSTimeInterval duration = mPlayer.duration;
    playSlider.maximumValue = duration;
    playSlider.value = mPlayer.currentPosition;
    
    [self hideLoadingIndicators];
    
    if(duration == 0){
        //        seekForwardButton.hidden = YES;
        //        seekBackwardButton.hidden = YES;
        playBtn.hidden = YES;
        playSlider.hidden = YES;
        playTimeLabel.hidden = YES;
        remainTimeLaber.hidden = YES;
    }
}

//recieve error notification
- (void)OnVideoError:(NSNotification *)notification {
    replay = YES;
    [playBtn setSelected:YES];
    [self showControls:nil];
    
    //    [seekBackwardButton setSelected:NO];
    //    [seekForwardButton setSelected:NO];
    //    [self hideLoadingIndicators];
    
    NSString* error_msg = @"未知错误";
    AliVcMovieErrorCode error_code = mPlayer.errorCode;
    
    switch (error_code) {
        case ALIVC_ERR_FUNCTION_DENIED:
            error_msg = @"该直播资源未授权！";
            break;
        case ALIVC_ERR_ILLEGALSTATUS:
            error_msg = @"非法的播放流程！";
            break;
        case ALIVC_ERR_INVALID_INPUTFILE:
            error_msg = @"直播未开始，请稍后再来！";
            [self hideLoadingIndicators];
            break;
        case ALIVC_ERR_NO_INPUTFILE:
            error_msg = @"直播未开始，请稍后再来！";
            [self hideLoadingIndicators];
            break;
        case ALIVC_ERR_NO_NETWORK:
            error_msg = @"网络连接失败！";
            break;
        case ALIVC_ERR_NO_SUPPORT_CODEC:
            error_msg = @"不支持的视频编码格式！";
            [self hideLoadingIndicators];
            break;
        case ALIVC_ERR_NO_VIEW:
            error_msg = @"无显示窗口！";
            [self hideLoadingIndicators];
            break;
        case ALIVC_ERR_NO_MEMORY:
            error_msg = @"内存不足！";
            break;
        case ALIVC_ERR_DOWNLOAD_TIMEOUT:
            error_msg = @"网络超时！";
            break;
        case ALIVC_ERR_UNKOWN:
            error_msg = @"未知错误！";
            break;
        default:
            break;
    }
    
    //NSLog(error_msg);
    
    //the error message is important when error_cdoe > 500
    if(error_code > 500 || error_code == ALIVC_ERR_FUNCTION_DENIED) {
        
        [mPlayer reset];
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:error_msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        self.errorAV = alter;
        [alter show];
        return;
    }
    
    if(error_code == ALIVC_ERR_DOWNLOAD_TIMEOUT) {
        
        [mPlayer pause];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                        message:@"授权功能被拒绝，没有经过授权！"
                                                       delegate:self
                                              cancelButtonTitle:@"等待"
                                              otherButtonTitles:@"重新连接",nil];
        
        [alert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //[self showLoadingIndicators];

    if (alertView == self.errorAV) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if ([alertView.message isEqualToString:@"退出直播间？"]) {
            if (buttonIndex == 1) {
                [self quitConversationViewAndClear];
            }
        }else if ( [alertView.message isEqualToString:@"直播已结束！"]) {

            [self quitConversationViewAndClear];
        }

        if (buttonIndex == 0) {
            [mPlayer play];
        }
        //reconnect
        else if(buttonIndex == 1) {
            [mPlayer stop];
            [self showLoadingIndicators];
            replay = YES;
            [self replay];
        }
    }
}
//recieve finish notification
- (void)OnVideoFinish:(NSNotification *)notification {
    replay = YES;
    [playBtn setSelected:YES];
    [self showControls:nil];
    
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"直播已结束！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    
    [alter show];
    
    [mPlayer stop];
    [self PlayMoive];
    
    //    [seekBackwardButton setSelected:NO];
    //    [seekForwardButton setSelected:NO];
}

//recieve seek finish notification
- (void)OnSeekDone:(NSNotification *)notification {
    bSeeking = NO;
}

//recieve start cache notification
- (void)OnStartCache:(NSNotification *)notification {
    [self showLoadingIndicators];
}

//recieve end cache notification
- (void)OnEndCache:(NSNotification *)notification {
    [self hideLoadingIndicators];
}

-(void)addPlayerObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoPrepared:)
                                                 name:AliVcMediaPlayerLoadDidPreparedNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoError:)
                                                 name:AliVcMediaPlayerPlaybackErrorNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoFinish:)
                                                 name:AliVcMediaPlayerPlaybackDidFinishNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnSeekDone:)
                                                 name:AliVcMediaPlayerSeekingDidFinishNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnStartCache:)
                                                 name:AliVcMediaPlayerStartCachingNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnEndCache:)
                                                 name:AliVcMediaPlayerEndCachingNotification object:mPlayer];
}

-(void)removePlayerObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerLoadDidPreparedNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerPlaybackErrorNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerPlaybackDidFinishNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerSeekingDidFinishNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerStartCachingNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerEndCachingNotification object:mPlayer];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self adjustLayoutsubViews];
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    _originalLocation = CGPointZero;
//    _progressValue = 0;
//    
//    if (bottomBar.alpha == 1.0) {
//        [self hideControls:nil];
//    }
//    else
//        [self showControls:nil];
//    // _ProgressBeginToMove = _movieProgressSlider.value;
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    if (_gestureType == GestureTypeOfNone ) {
//        //[self showControls:nil];
//    }else if (_gestureType == GestureTypeOfProgress){
//        _gestureType = GestureTypeOfNone;
//        _progressTimeView.hidden = YES;
//        
//        [mPlayer seekTo:mPlayer.currentPosition+_progressValue*1000];
//        
//        _progressValue = 0;
//        //    }else if (_gestureType == GestureTypeOfVolume) {
//        //        [bottomBar addSubview:volumeView];
//        //        _gestureType = GestureTypeOfNone;
//    }
//    else {
//        _progressValue = 0;
//        _gestureType = GestureTypeOfNone;
//        _progressTimeView.hidden = YES;
//        if (_brightnessView.alpha) {
//            [UIView animateWithDuration:1 animations:^{
//                _brightnessView.alpha = 0;
//            }];
//        }
//    }
//}

- (void)volumeAdd:(CGFloat)step{
//    [MPMusicPlayerController applicationMusicPlayer].volume += step;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    _systemBrightness = [UIScreen mainScreen].brightness;
    [self.view addGestureRecognizer:_resetBottomTapGesture];
    [self.conversationMessageCollectionView reloadData];
    self.chatroomlabel.sd_width = [self.title boundingRectWithSize:CGSizeMake(250, 35) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.width + 20;
    self.chatroomlabel.text = self.title;
    
    __block typeof(self) weakSelf = self;
    [[RCIMClient sharedRCIMClient] getChatRoomInfo:self.targetId count:0 order:RC_ChatRoom_Member_Asc success:^(RCChatRoomInfo *chatRoomInfo) {
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            weakSelf.seePsersonCountLabel.text = [NSString stringWithFormat:@"%lu人",(unsigned long)chatRoomInfo.totalMemberCount];
            weakSelf.seePsersonCountLabel.sd_x = CGRectGetMaxX(self.chatroomlabel.frame) + 5;
            weakSelf.seePsersonCountLabel.sd_width = [self.chatroomlabel.text boundingRectWithSize:CGSizeMake(250, 35) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.width + 10;
 
        });
          } error:^(RCErrorCode status) {
        
    }];
    
    
   
    self.seePsersonCountLabel.st_centerY = self.chatroomlabel.st_centerY;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIScreen mainScreen].brightness = _systemBrightness;
    self.navigationController.navigationBarHidden = NO;

    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:@"kRCPlayVoiceFinishNotification"
     object:nil];
    
    [self.conversationMessageCollectionView removeGestureRecognizer:_resetBottomTapGesture];
    [self.conversationMessageCollectionView
     addGestureRecognizer:_resetBottomTapGesture];
    
    //退出页面，弹幕停止
    [self.view stopDanmaku];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationTitle = self.navigationItem.title;
}
- (void)brightnessAdd:(CGFloat)step{
    [UIScreen mainScreen].brightness += step;
    _brightnessProgress.progress = [UIScreen mainScreen].brightness;
}




- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void) dealloc
{
    topBar = nil;
    bottomBar = nil;
    playBtn = nil;
    doneBtn = nil;
    playSlider = nil;
    playTimeLabel = nil;
    remainTimeLaber = nil;
    
    _brightnessView = nil;
    _brightnessProgress = nil;
    _progressTimeView = nil;
    _prgForwardView = nil;
    _prgBackwardView = nil;
    _progressTimeLable = nil;
    [self.conn stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)sendDanmaku:(NSString *)text {
    if(!text || text.length == 0){
        return;
    }
    RCDDanmaku *danmaku = [[RCDDanmaku alloc]init];
    danmaku.contentStr = [[NSAttributedString alloc]initWithString:text attributes:@{NSForegroundColorAttributeName : kRandomColor}];
    [self.liveView sendDanmaku:danmaku];
}
- (void)sendCenterDanmaku:(NSString *)text {
    if(!text || text.length == 0){
        return;
    }
    RCDDanmaku *danmaku = [[RCDDanmaku alloc]init];
    danmaku.contentStr = [[NSAttributedString alloc]initWithString:text attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:218.0/255 green:178.0/255 blue:115.0/255 alpha:1]}];
    danmaku.position = RCDDanmakuPositionCenterTop;
    [self.liveView sendDanmaku:danmaku];
}
/**
 *  加入直播间失败的提示
 *
 *  @param title 提示内容
 */
- (void)loadErrorAlert:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
/**
 *  点击返回的时候消耗播放器和退出直播间
 *
 *  @param sender sender description
 */
- (void)leftBarButtonItemPressed:(id)sender {
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:@"退出直播间？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alertview show];
}
// 清理环境（退出直播间并断开融云连接）
- (void)quitConversationViewAndClear {
    if (self.conversationType == ConversationType_CHATROOM) {
        //直播播放器
        //        if (self.livePlayingManager) {
        //            [self.livePlayingManager destroyPlaying];
        //        }
        //退出直播间
        dispatch_async(dispatch_get_main_queue(), ^{
            RCInformationNotificationMessage * message = [RCInformationNotificationMessage notificationWithMessage:[NSString stringWithFormat:@"退出直播间",@""] extra:@"out_room"];
            message.senderUserInfo =  [RCIMClient sharedRCIMClient].currentUserInfo;
            [[RCIMClient sharedRCIMClient] sendMessage:self.conversationType targetId:self.targetId content:message pushContent:nil pushData:nil success:^(long messageId) {
                [[RCIMClient sharedRCIMClient] quitChatRoom:self.targetId
                                                    success:^{
                                                        self.conversationMessageCollectionView.dataSource = nil;
                                                        self.conversationMessageCollectionView.delegate = nil;
                                                        [[NSNotificationCenter defaultCenter] removeObserver:self];
                                                        
                                                        //断开融云连接，如果你退出直播间后还有融云的其他通讯功能操作，可以不用断开融云连接，否则断开连接后需要重新connectWithToken才能使用融云的功能
                                                        //                                                [[RCDLive sharedRCDLive]logoutRongCloud];
                                                        [self removeTimer];
                                                        
                                                        [mTimer invalidate];
                                                        mTimer = nil;
                                                        
                                                        //    [seekBackwardButton setSelected:NO];
                                                        //    [seekForwardButton setSelected:NO];
                                                        [mSeekTimer invalidate];
                                                        mSeekTimer = nil;
                                                        
                                                        if(mPlayer != nil)
                                                            [mPlayer destroy];
                                                        
                                                        [self removePlayerObserver];
                                                        
                                                        mPlayer = nil;
                                                        mSourceURL = nil;
                                                        
                                                        
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [self.navigationController popViewControllerAnimated:YES];
                                                        });
                                                        
                                                        
                                                    } error:^(RCErrorCode status) {
                                                        
                                                    }];

                
            } error:^(RCErrorCode nErrorCode, long messageId) {
                
            }];
        });
        
         }
}

- (void)initChatroomMemberInfo{
    [self.view addSubview:self.chatroomImageView];
    [self.view addSubview:self.chatroomlabel];
    [self.view addSubview:self.seePsersonCountLabel];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 16;
    layout.sectionInset = UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat memberHeadListViewY = CGRectGetMinX(_chatroomlabel.frame);
    
    self.portraitsCollectionView  = [[UICollectionView alloc] initWithFrame:CGRectMake(memberHeadListViewY,CGRectGetMaxY(_chatroomlabel.frame) + 15,self.view.frame.size.width - memberHeadListViewY,35) collectionViewLayout:layout];
    self.portraitsCollectionView.delegate = self;
    self.portraitsCollectionView.dataSource = self;
    self.portraitsCollectionView.backgroundColor = [UIColor clearColor];
    [self.portraitsCollectionView registerClass:[RCDLivePortraitViewCell class] forCellWithReuseIdentifier:@"portraitcell"];
    [self.view addSubview:self.portraitsCollectionView];
//    [self.portraitsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}


/**
 *  初始化页面控件
 */
- (void)initializedSubViews {
    //聊天区
    if(self.contentView == nil){
        CGRect contentViewFrame = CGRectMake(0, self.view.bounds.size.height-237, self.view.bounds.size.width,237);
        self.contentView.backgroundColor = RCDLive_RGBCOLOR(235, 235, 235);
        self.contentView = [[UIView alloc]initWithFrame:contentViewFrame];
        [self.view addSubview:self.contentView];
    }
    //聊天消息区
    if (nil == self.conversationMessageCollectionView) {
        UICollectionViewFlowLayout *customFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        customFlowLayout.minimumLineSpacing = 0;
        customFlowLayout.sectionInset = UIEdgeInsetsMake(10.0f, 0.0f,5.0f, 0.0f);
        customFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        CGRect _conversationViewFrame = self.contentView.bounds;
        _conversationViewFrame.origin.y = 0;
        _conversationViewFrame.size.height = self.contentView.bounds.size.height - 50;
        _conversationViewFrame.size.width = 240;
        self.conversationMessageCollectionView =
        [[UICollectionView alloc] initWithFrame:_conversationViewFrame
                           collectionViewLayout:customFlowLayout];
        [self.conversationMessageCollectionView
         setBackgroundColor:[UIColor clearColor]];
        self.conversationMessageCollectionView.showsHorizontalScrollIndicator = NO;
        self.conversationMessageCollectionView.alwaysBounceVertical = YES;
        self.conversationMessageCollectionView.dataSource = self;
        self.conversationMessageCollectionView.delegate = self;
        [self.contentView addSubview:self.conversationMessageCollectionView];
    }
    //输入区
    if(self.inputBar == nil){
        float inputBarOriginY = self.conversationMessageCollectionView.bounds.size.height +30;
        float inputBarOriginX = self.conversationMessageCollectionView.frame.origin.x;
        float inputBarSizeWidth = self.contentView.frame.size.width;
        float inputBarSizeHeight = MinHeight_InputView;
        self.inputBar = [[RCDLiveInputBar alloc]initWithFrame:CGRectMake(inputBarOriginX, inputBarOriginY,inputBarSizeWidth,inputBarSizeHeight)];
        self.inputBar.delegate = self;
        self.inputBar.backgroundColor = [UIColor clearColor];
//        self.inputBar.hidden = YES;
        [self.contentView addSubview:self.inputBar];    }
    self.collectionViewHeader = [[RCDLiveCollectionViewHeader alloc]
                                 initWithFrame:CGRectMake(0, -50, self.view.bounds.size.width, 40)];
    _collectionViewHeader.tag = 1999;
    [self.conversationMessageCollectionView addSubview:_collectionViewHeader];
    [self registerClass:[RCDLiveTextMessageCell class]forCellWithReuseIdentifier:rctextCellIndentifier];
    [self registerClass:[RCDLiveTipMessageCell class]forCellWithReuseIdentifier:RCDLiveTipMessageCellIndentifier];
    [self registerClass:[RCDLiveGiftMessageCell class]forCellWithReuseIdentifier:RCDLiveGiftMessageCellIndentifier];
    [self changeModel:YES];
    _resetBottomTapGesture =[[UITapGestureRecognizer alloc]
                             initWithTarget:self
                             action:@selector(tap4ResetDefaultBottomBarStatus:)];
    [_resetBottomTapGesture setDelegate:self];
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 10 - 100, 35, 100, 100);
    UIImageView *backImg = [[UIImageView alloc]
                            initWithImage:[UIImage imageNamed:@"close"]];
    backImg.frame = CGRectMake(100 - 35, 0, 25, 25);
    [_backBtn addSubview:backImg];
    [_backBtn addTarget:self
                 action:@selector(leftBarButtonItemPressed:)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
    
    _feedBackBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    _feedBackBtn.frame = CGRectMake(10, self.view.frame.size.height - 45, 35, 35);
    UIImageView *clapImg = [[UIImageView alloc]
                            initWithImage:[UIImage imageNamed:@"feedback"]];
    clapImg.frame = CGRectMake(0,0, 35, 35);
    [_feedBackBtn addSubview:clapImg];
    [_feedBackBtn addTarget:self
                     action:@selector(showInputBar:)
           forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_feedBackBtn];
    
    _flowerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _flowerBtn.frame = CGRectMake(self.view.frame.size.width-90, self.view.frame.size.height - 45, 35, 35);
    UIImageView *clapImg2 = [[UIImageView alloc]
                             initWithImage:[UIImage imageNamed:@"giftIcon"]];
    clapImg2.frame = CGRectMake(0,0, 35, 35);
//    [_flowerBtn addSubview:clapImg2];
    [_flowerBtn addTarget:self
                   action:@selector(flowerButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_flowerBtn];
    
    _clapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _clapBtn.frame = CGRectMake(self.view.frame.size.width-45, self.view.frame.size.height - 45, 35, 35);
    UIImageView *clapImg3 = [[UIImageView alloc]
                             initWithImage:[UIImage imageNamed:@"heartIcon"]];
    clapImg3.frame = CGRectMake(0,0, 35, 35);
//    [_clapBtn addSubview:clapImg3];
    [_clapBtn addTarget:self
                 action:@selector(clapButtonPressed:)
       forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_clapBtn];
}

-(void)showInputBar:(id)sender{
    self.inputBar.hidden = NO;
    [self.inputBar setInputBarStatus:RCDLiveBottomBarKeyboardStatus];
}

/**
 *  发送鲜花
 *
 *  @param sender sender description
 */
-(void)flowerButtonPressed:(id)sender{
    RCDLiveGiftMessage *giftMessage = [[RCDLiveGiftMessage alloc]init];
    giftMessage.type = @"0";
    [self sendMessage:giftMessage pushContent:@""];
    NSString *text = [NSString stringWithFormat:@"%@ 送了一个钻戒",giftMessage.senderUserInfo.name];
    [self sendDanmaku:text];
}

/**
 *  发送掌声
 *
 *  @param sender <#sender description#>
 */
-(void)clapButtonPressed:(id)sender{
    RCDLiveGiftMessage *giftMessage = [[RCDLiveGiftMessage alloc]init];
    giftMessage.type = @"1";
    [self sendMessage:giftMessage pushContent:@""];
    NSString *text = [NSString stringWithFormat:@"%@ 为主播点了赞",giftMessage.senderUserInfo.name];
    [self sendDanmaku:text];
    [self praiseHeart];
}

/**
 *  未读消息View
 *
 *  @return <#return value description#>
 */
- (UIView *)unreadButtonView {
    if (!_unreadButtonView) {
        _unreadButtonView = [[UIView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 80)/2, self.view.frame.size.height - MinHeight_InputView - 30, 80, 30)];
        _unreadButtonView.userInteractionEnabled = YES;
        _unreadButtonView.backgroundColor = RCDLive_HEXCOLOR(0xffffff);
        _unreadButtonView.alpha = 0.7;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabUnreadMsgCountIcon:)];
        [_unreadButtonView addGestureRecognizer:tap];
        _unreadButtonView.hidden = YES;
        [self.view addSubview:_unreadButtonView];
        _unreadButtonView.layer.cornerRadius = 4;
    }
    return _unreadButtonView;
}

/**
 *  底部新消息文字
 *
 *  @return return value description
 */
- (UILabel *)unReadNewMessageLabel {
    if (!_unReadNewMessageLabel) {
        _unReadNewMessageLabel = [[UILabel alloc]initWithFrame:_unreadButtonView.bounds];
        _unReadNewMessageLabel.backgroundColor = [UIColor clearColor];
        _unReadNewMessageLabel.font = [UIFont systemFontOfSize:12.0f];
        _unReadNewMessageLabel.textAlignment = NSTextAlignmentCenter;
        _unReadNewMessageLabel.textColor = RCDLive_HEXCOLOR(0xff4e00);
        [self.unreadButtonView addSubview:_unReadNewMessageLabel];
    }
    return _unReadNewMessageLabel;
    
}

/**
 *  更新底部新消息提示显示状态
 */
- (void)updateUnreadMsgCountLabel{
    if (self.unreadNewMsgCount == 0) {
        self.unreadButtonView.hidden = YES;
    }
    else{
        self.unreadButtonView.hidden = NO;
        self.unReadNewMessageLabel.text = @"底部有新消息";
    }
}

/**
 *  检查是否更新新消息提醒
 */
- (void) checkVisiableCell{
    NSIndexPath *lastPath = [self getLastIndexPathForVisibleItems];
    if (lastPath.row >= self.conversationDataRepository.count - self.unreadNewMsgCount || lastPath == nil || [self isAtTheBottomOfTableView] ) {
        self.unreadNewMsgCount = 0;
        [self updateUnreadMsgCountLabel];
    }
}

/**
 *  获取显示的最后一条消息的indexPath
 *
 *  @return indexPath
 */
- (NSIndexPath *)getLastIndexPathForVisibleItems
{
    NSArray *visiblePaths = [self.conversationMessageCollectionView indexPathsForVisibleItems];
    if (visiblePaths.count == 0) {
        return nil;
    }else if(visiblePaths.count == 1) {
        return (NSIndexPath *)[visiblePaths firstObject];
    }
    NSArray *sortedIndexPaths = [visiblePaths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSIndexPath *path1 = (NSIndexPath *)obj1;
        NSIndexPath *path2 = (NSIndexPath *)obj2;
        return [path1 compare:path2];
    }];
    return (NSIndexPath *)[sortedIndexPaths lastObject];
}

/**
 *  点击未读提醒滚动到底部
 *
 *  @param gesture gesture description
 */
- (void)tabUnreadMsgCountIcon:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self scrollToBottomAnimated:YES];
    }
}

/**
 *  初始化视频直播
 */
- (void)initializedLiveSubViews {
    //直播播放器
    //    _liveView = self.livePlayingManager.currentLiveView;
    _liveView.frame = self.view.frame;
    [self.view addSubview:_liveView];
    [self.view sendSubviewToBack:_liveView];
    
}

/**
 *  全屏和半屏模式切换
 *
 *  @param isFullScreen 全屏或者半屏
 */
- (void)changeModel:(BOOL)isFullScreen {
    //直播播放器
    //    self.livePlayingManager.currentLiveView.frame = self.view.frame;
    _titleView.hidden = YES;
    
    self.conversationMessageCollectionView.backgroundColor = [UIColor clearColor];
    CGRect contentViewFrame = CGRectMake(0, self.view.bounds.size.height-237, self.view.bounds.size.width,237);
    self.contentView.frame = contentViewFrame;
    _feedBackBtn.frame = CGRectMake(10, self.view.frame.size.height - 45, 35, 35);
    _flowerBtn.frame = CGRectMake(self.view.frame.size.width-90, self.view.frame.size.height - 45, 35, 35);
    _clapBtn.frame = CGRectMake(self.view.frame.size.width-45, self.view.frame.size.height - 45, 35, 35);
    [self.view sendSubviewToBack:_liveView];
    
    float inputBarOriginY = self.conversationMessageCollectionView.bounds.size.height + 30;
    float inputBarOriginX = self.conversationMessageCollectionView.frame.origin.x;
    float inputBarSizeWidth = self.contentView.frame.size.width;
    float inputBarSizeHeight = MinHeight_InputView;
    //添加输入框
    [self.inputBar changeInputBarFrame:CGRectMake(inputBarOriginX, inputBarOriginY,inputBarSizeWidth,inputBarSizeHeight)];
    [self.conversationMessageCollectionView reloadData];
    [self.unreadButtonView setFrame:CGRectMake((self.view.frame.size.width - 80)/2, self.view.frame.size.height - MinHeight_InputView - 30, 80, 30)];
}

/**
 *  顶部插入历史消息
 *
 *  @param model 消息Model
 */
- (void)pushOldMessageModel:(RCDLiveMessageModel *)model {
    if (!(!model.content && model.messageId > 0)
        && !([[model.content class] persistentFlag] & MessagePersistent_ISPERSISTED)) {
        return;
    }
    long ne_wId = model.messageId;
    for (RCDLiveMessageModel *__item in self.conversationDataRepository) {
        if (ne_wId == __item.messageId) {
            return;
        }
    }
    [self.conversationDataRepository insertObject:model atIndex:0];
}

/**
 *  加载历史消息(暂时没有保存直播间消息)
 */
- (void)loadMoreHistoryMessage {
    long lastMessageId = -1;
    if (self.conversationDataRepository.count > 0) {
        RCDLiveMessageModel *model = [self.conversationDataRepository objectAtIndex:0];
        lastMessageId = model.messageId;
    }
    
    NSArray *__messageArray =
    [[RCIMClient sharedRCIMClient] getHistoryMessages:_conversationType
                                             targetId:_targetId
                                      oldestMessageId:lastMessageId
                                                count:10];
    for (int i = 0; i < __messageArray.count; i++) {
        RCMessage *rcMsg = [__messageArray objectAtIndex:i];
        RCDLiveMessageModel *model = [[RCDLiveMessageModel alloc] initWithMessage:rcMsg];
        [self pushOldMessageModel:model];
    }
    [self.conversationMessageCollectionView reloadData];
    if (_conversationDataRepository != nil &&
        _conversationDataRepository.count > 0 &&
        [self.conversationMessageCollectionView numberOfItemsInSection:0] >=
        __messageArray.count - 1) {
        NSIndexPath *indexPath =
        [NSIndexPath indexPathForRow:__messageArray.count - 1 inSection:0];
        [self.conversationMessageCollectionView scrollToItemAtIndexPath:indexPath
                                                       atScrollPosition:UICollectionViewScrollPositionTop
                                                               animated:NO];
    }
}


#pragma mark <UIScrollViewDelegate>
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

/**
 *  滚动条滚动时显示正在加载loading
 *
 *  @param scrollView
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 是否显示右下未读icon
    if (self.unreadNewMsgCount != 0) {
        [self checkVisiableCell];
    }
    
    if (scrollView.contentOffset.y < -5.0f) {
        [self.collectionViewHeader startAnimating];
    } else {
        [self.collectionViewHeader stopAnimating];
        _isLoading = NO;
    }
}

/**
 *  滚动结束加载消息 （直播间消息还没存储，所以暂时还没有此功能）
 *
 *  @param scrollView scrollView description
 *  @param decelerate decelerate description
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y < -15.0f && !_isLoading) {
        _isLoading = YES;
    }
}

/**
 *  消息滚动到底部
 *
 *  @param animated 是否开启动画效果
 */
- (void)scrollToBottomAnimated:(BOOL)animated {
    if ([self.conversationMessageCollectionView numberOfSections] == 0) {
        return;
    }
    NSUInteger finalRow = MAX(0, [self.conversationMessageCollectionView numberOfItemsInSection:0] - 1);
    if (0 == finalRow) {
        return;
    }
    NSIndexPath *finalIndexPath =
    [NSIndexPath indexPathForItem:finalRow inSection:0];
    [self.conversationMessageCollectionView scrollToItemAtIndexPath:finalIndexPath
                                                   atScrollPosition:UICollectionViewScrollPositionTop
                                                           animated:animated];
}

#pragma mark <UICollectionViewDataSource>
/**
 *  定义展示的UICollectionViewCell的个数
 *
 *  @return
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:self.portraitsCollectionView]) {
        return self.userList.count;
    }
    return self.conversationDataRepository.count;
}

/**
 *  每个UICollectionView展示的内容
 *
 *  @return
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.portraitsCollectionView]) {
        RCDLivePortraitViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"portraitcell" forIndexPath:indexPath];
        UserInfo *user = self.userList[indexPath.row];
        [cell.portaitView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri] placeholderImage:[UIImage imageNamed:@""]];
        return cell;
    }
    RCDLiveMessageModel *model =
    [self.conversationDataRepository objectAtIndex:indexPath.row];
    RCMessageContent *messageContent = model.content;
    RCDLiveMessageBaseCell *cell = nil;
    if ([messageContent isMemberOfClass:[RCInformationNotificationMessage class]] || [messageContent isMemberOfClass:[RCTextMessage class]] || [messageContent isMemberOfClass:[RCDLiveGiftMessage class]]){
        RCDLiveTipMessageCell *__cell = [collectionView dequeueReusableCellWithReuseIdentifier:RCDLiveTipMessageCellIndentifier forIndexPath:indexPath];
        __cell.isFullScreenMode = YES;
        [__cell setDataModel:model];
        [__cell setDelegate:self];
        cell = __cell;
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

/**
 *  cell的大小
 *
 *  @return
 */
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.portraitsCollectionView]) {
        return CGSizeMake(35,35);
    }
    RCDLiveMessageModel *model =
    [self.conversationDataRepository objectAtIndex:indexPath.row];
    if (model.cellSize.height > 0) {
        return model.cellSize;
    }
    RCMessageContent *messageContent = model.content;
    if ([messageContent isMemberOfClass:[RCTextMessage class]] || [messageContent isMemberOfClass:[RCInformationNotificationMessage class]] || [messageContent isMemberOfClass:[RCDLiveGiftMessage class]]) {
        model.cellSize = [self sizeForItem:collectionView atIndexPath:indexPath];
    } else {
        return CGSizeZero;
    }
    return model.cellSize;
}

/**
 *  计算不同消息的具体尺寸
 *
 *  @return
 */
- (CGSize)sizeForItem:(UICollectionView *)collectionView
          atIndexPath:(NSIndexPath *)indexPath {
    CGFloat __width = CGRectGetWidth(collectionView.frame);
    RCDLiveMessageModel *model =
    [self.conversationDataRepository objectAtIndex:indexPath.row];
    RCMessageContent *messageContent = model.content;
    CGFloat __height = 0.0f;
    NSString *localizedMessage;
    if ([messageContent isMemberOfClass:[RCInformationNotificationMessage class]]) {
        RCInformationNotificationMessage *notification = (RCInformationNotificationMessage *)messageContent;
        localizedMessage = [RCDLiveKitUtility formatMessage:notification];
    }else if ([messageContent isMemberOfClass:[RCTextMessage class]]){
        RCTextMessage *notification = (RCTextMessage *)messageContent;
        localizedMessage = [RCDLiveKitUtility formatMessage:notification];
        NSString *name;
        if (messageContent.senderUserInfo) {
            name = messageContent.senderUserInfo.name;
        }
        localizedMessage = [NSString stringWithFormat:@"%@ %@",name,localizedMessage];
    }else if ([messageContent isMemberOfClass:[RCDLiveGiftMessage class]]){
        RCDLiveGiftMessage *notification = (RCDLiveGiftMessage *)messageContent;
        localizedMessage = @"送了一个钻戒";
        if(notification && [notification.type isEqualToString:@"1"]){
            localizedMessage = @"为主播点了赞";
        }
        
        NSString *name;
        if (messageContent.senderUserInfo) {
            name = messageContent.senderUserInfo.name;
        }
        localizedMessage = [NSString stringWithFormat:@"%@ %@",name,localizedMessage];
    }
    CGSize __labelSize = [RCDLiveTipMessageCell getTipMessageCellSize:localizedMessage];
    __height = __height + __labelSize.height;
    
    return CGSizeMake(__width, __height);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

#pragma mark <UICollectionViewDelegate>
/**
 *   UICollectionView被选中时调用的方法
 *
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.portraitsCollectionView) {
        UserInfo * userList = self.userList[indexPath.item];
        UserInfoViewController * vc = [[UserInfoViewController alloc] init];
//        vc.title = userList.name;
        vc.visitorUserId = [userList.userId integerValue];
        [self.navigationController pushViewController:vc animated:true];
    }
}


/**
 *  将消息加入本地数组
 *
 *  @return
 */
- (void)appendAndDisplayMessage:(RCMessage *)rcMessage {
    if (!rcMessage) {
        return;
    }
    RCDLiveMessageModel *model = [[RCDLiveMessageModel alloc] initWithMessage:rcMessage];
    if([rcMessage.content isMemberOfClass:[RCDLiveGiftMessage class]]){
        model.messageId = -1;
    }
    if ([self appendMessageModel:model]) {
        NSIndexPath *indexPath =
        [NSIndexPath indexPathForItem:self.conversationDataRepository.count - 1
                            inSection:0];
        if ([self.conversationMessageCollectionView numberOfItemsInSection:0] !=
            self.conversationDataRepository.count - 1) {
            return;
        }
        [self.conversationMessageCollectionView
         insertItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        if ([self isAtTheBottomOfTableView] || self.isNeedScrollToButtom) {
            [self scrollToBottomAnimated:YES];
            self.isNeedScrollToButtom=NO;
        }
    }
}

- (void)sendReceivedDanmaku:(RCMessageContent *)messageContent {
    if([messageContent isMemberOfClass:[RCInformationNotificationMessage class]]){
        RCInformationNotificationMessage *msg = (RCInformationNotificationMessage *)messageContent;
        //        [self sendDanmaku:msg.message];
        [self sendCenterDanmaku:msg.message];
    }else if ([messageContent isMemberOfClass:[RCTextMessage class]]){
        RCTextMessage *msg = (RCTextMessage *)messageContent;
        [self sendDanmaku:msg.content];
    }else if([messageContent isMemberOfClass:[RCDLiveGiftMessage class]]){
        RCDLiveGiftMessage *msg = (RCDLiveGiftMessage *)messageContent;
        NSString *tip = [msg.type isEqualToString:@"0"]?@"送了一个钻戒":@"为主播点了赞";
        NSString *text = [NSString stringWithFormat:@"%@ %@",msg.senderUserInfo.name,tip];
        [self sendDanmaku:text];
    }
}

/**
 *  如果当前会话没有这个消息id，把消息加入本地数组
 *
 *  @return
 */
- (BOOL)appendMessageModel:(RCDLiveMessageModel *)model {
    long newId = model.messageId;
    for (RCDLiveMessageModel *__item in self.conversationDataRepository) {
        /*
         * 当id为－1时，不检查是否重复，直接插入
         * 该场景用于插入临时提示。
         */
        if (newId == -1) {
            break;
        }
        if (newId == __item.messageId) {
            return NO;
        }
    }
    if (!model.content) {
        return NO;
    }
    //这里可以根据消息类型来决定是否显示，如果不希望显示直接return NO
    
    //数量不可能无限制的大，这里限制收到消息过多时，就对显示消息数量进行限制。
    //用户可以手动下拉更多消息，查看更多历史消息。
    if (self.conversationDataRepository.count>100) {
        //                NSRange range = NSMakeRange(0, 1);
        RCDLiveMessageModel *message = self.conversationDataRepository[0];
        [[RCIMClient sharedRCIMClient]deleteMessages:@[@(message.messageId)]];
        [self.conversationDataRepository removeObjectAtIndex:0];
        [self.conversationMessageCollectionView reloadData];
    }
    
    [self.conversationDataRepository addObject:model];
    return YES;
}

/**
 *  UIResponder
 *
 *  @return
 */
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return [super canPerformAction:action withSender:sender];
}

/**
 *  找出消息的位置
 *
 *  @return
 */
- (NSInteger)findDataIndexFromMessageList:(RCDLiveMessageModel *)model {
    NSInteger index = 0;
    for (int i = 0; i < self.conversationDataRepository.count; i++) {
        RCDLiveMessageModel *msg = (self.conversationDataRepository)[i];
        if (msg.messageId == model.messageId) {
            index = i;
            break;
        }
    }
    return index;
}


/**
 *  打开大图。开发者可以重写，自己下载并且展示图片。默认使用内置controller
 *
 *  @param imageMessageContent 图片消息内容
 */
- (void)presentImagePreviewController:(RCDLiveMessageModel *)model {
}

/**
 *  打开地理位置。开发者可以重写，自己根据经纬度打开地图显示位置。默认使用内置地图
 *
 *  @param locationMessageContent 位置消息
 */
- (void)presentLocationViewController:
(RCLocationMessage *)locationMessageContent {
    
}

/**
 *  关闭提示框
 *
 *  @param theTimer theTimer description
 */
- (void)timerForHideHUD:(NSTimer*)theTimer//弹出框
{
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    });
    [theTimer invalidate];
    theTimer = nil;
}


/*!
 发送消息(除图片消息外的所有消息)
 
 @param messageContent 消息的内容
 @param pushContent    接收方离线时需要显示的远程推送内容
 
 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。
 
 SDK内置的消息类型，如果您将pushContent置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent来定义推送内容，否则将不会进行远程推送。
 
 如果您需要设置发送的pushData，可以使用RCIM的发送消息接口。
 */
- (void)sendMessage:(RCMessageContent *)messageContent
        pushContent:(NSString *)pushContent {
    
    
    if (_targetId == nil) {
        return;
    }
    messageContent.senderUserInfo = [RCDLive sharedRCDLive].currentUserInfo;
    if (messageContent == nil) {
        return;
    }
    [[RCDLive sharedRCDLive] sendMessage:self.conversationType
                                targetId:self.targetId
                                 content:messageContent
                             pushContent:pushContent
                                pushData:nil
                                 success:^(long messageId) {
                                     __weak typeof(&*self) __weakself = self;
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         RCMessage *message = [[RCMessage alloc] initWithType:__weakself.conversationType
                                                                                     targetId:__weakself.targetId
                                                                                    direction:MessageDirection_SEND
                                                                                    messageId:messageId
                                                                                      content:messageContent];
                                         if ([message.content isMemberOfClass:[RCDLiveGiftMessage class]] ) {
                                             message.messageId = -1;//插入消息时如果id是-1不判断是否存在
                                         }
                                         [__weakself appendAndDisplayMessage:message];
                                         [__weakself.inputBar clearInputView];
                                     });
                                 } error:^(RCErrorCode nErrorCode, long messageId) {
                                     [[RCIMClient sharedRCIMClient]deleteMessages:@[ @(messageId) ]];
                                 }];
}

/**
 *  接收到消息的回调
 *
 *  @param notification
 */
- (void)didReceiveMessageNotification:(NSNotification *)notification {
    __block RCMessage *rcMessage = notification.object;

    RCDLiveMessageModel *model = [[RCDLiveMessageModel alloc] initWithMessage:rcMessage];
    NSDictionary *leftDic = notification.userInfo;
    if (leftDic && [leftDic[@"left"] isEqual:@(0)]) {
        self.isNeedScrollToButtom = YES;
    }

    if (model.conversationType == self.conversationType &&
        [model.targetId isEqual:self.targetId]) {
        __weak typeof(&*self) __blockSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (rcMessage) {
                if ([rcMessage.content isKindOfClass:[RCInformationNotificationMessage class]]) {
                    RCInformationNotificationMessage * mes = (RCInformationNotificationMessage *)rcMessage.content;
                    
                    if ([mes.extra isEqualToString:@"out_room"]) {
//                        if ([self.userList containsObject:(UserInfo *)mes.senderUserInfo]) {
//                            [self.userList removeObject:(UserInfo *)mes.senderUserInfo];
//                            [self.portraitsCollectionView reloadData];
//                        }
                    }else{
                        if (![self.userList containsObject:(UserInfo *)mes.senderUserInfo]) {
                            [__blockSelf.userList addObject:(UserInfo *)mes.senderUserInfo];
                            [__blockSelf.portraitsCollectionView reloadData];
                        }
                    }
               }
                __blockSelf.seePsersonCountLabel.text = [NSString stringWithFormat:@"%lu人",(unsigned long)self.userList.count];
                [__blockSelf appendAndDisplayMessage:rcMessage];
                UIMenuController *menu = [UIMenuController sharedMenuController];
                menu.menuVisible=NO;
                //如果消息不在最底部，收到消息之后不滚动到底部，加到列表中只记录未读数
                if (![self isAtTheBottomOfTableView]) {
                    self.unreadNewMsgCount ++ ;
                    [self updateUnreadMsgCountLabel];
                }
            }
        });
    }
    if([NSThread isMainThread]){
        [self sendReceivedDanmaku:rcMessage.content];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendReceivedDanmaku:rcMessage.content];
        });
    }
    
}


/**
 *  定义展示的UICollectionViewCell的个数
 *
 *  @return
 */
- (void)tap4ResetDefaultBottomBarStatus:
(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        //        CGRect collectionViewRect = self.conversationMessageCollectionView.frame;
        //        collectionViewRect.size.height = self.contentView.bounds.size.height - 0;
        //        [self.conversationMessageCollectionView setFrame:collectionViewRect];
        [self.inputBar setInputBarStatus:RCDLiveBottomBarDefaultStatus];
//        self.inputBar.hidden = YES;
    }
}

/**
 *  判断消息是否在collectionView的底部
 *
 *  @return 是否在底部
 */
- (BOOL)isAtTheBottomOfTableView {
    if (self.conversationMessageCollectionView.contentSize.height <= self.conversationMessageCollectionView.frame.size.height) {
        return YES;
    }
    if(self.conversationMessageCollectionView.contentOffset.y +200 >= (self.conversationMessageCollectionView.contentSize.height - self.conversationMessageCollectionView.frame.size.height)) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - 输入框事件
/**
 *  点击键盘回车或者emoji表情面板的发送按钮执行的方法
 *
 *  @param text  输入框的内容
 */
- (void)onTouchSendButton:(NSString *)text{
    RCTextMessage *rcTextMessage = [RCTextMessage messageWithContent:text];
    [self sendMessage:rcTextMessage pushContent:nil];
    [self sendDanmaku:rcTextMessage.content];
    //    [self.inputBar setInputBarStatus:KBottomBarDefaultStatus];
    //    [self.inputBar setHidden:YES];
}

//修复ios7下不断下拉加载历史消息偶尔崩溃的bug
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    return NO;
//}

#pragma mark RCInputBarControlDelegate

/**
 *  根据inputBar 回调来修改页面布局，inputBar frame 变化会触发这个方法
 *
 *  @param frame    输入框即将占用的大小
 *  @param duration 时间
 *  @param curve
 */
- (void)onInputBarControlContentSizeChanged:(CGRect)frame withAnimationDuration:(CGFloat)duration andAnimationCurve:(UIViewAnimationCurve)curve{
    CGRect collectionViewRect = self.contentView.frame;
    self.contentView.backgroundColor = [UIColor clearColor];
    collectionViewRect.origin.y = self.view.bounds.size.height - frame.size.height - 237 + 50;
    
    collectionViewRect.size.height = 237;
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:curve];
        [self.contentView setFrame:collectionViewRect];
        [UIView commitAnimations];
    }];
    CGRect inputbarRect = self.inputBar.frame;
    
    inputbarRect.origin.y = self.contentView.frame.size.height -50;
    [self.inputBar setFrame:inputbarRect];
    [self.view bringSubviewToFront:self.inputBar];
    [self scrollToBottomAnimated:NO];
}

/**
 *  屏幕翻转
 *
 *  @param newCollection <#newCollection description#>
 *  @param coordinator   <#coordinator description#>
 */
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    [super willTransitionToTraitCollection:newCollection
                 withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context)
     {
         if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
             //To Do: modify something for compact vertical size
             [self changeCrossOrVerticalscreen:NO];
         } else {
             [self changeCrossOrVerticalscreen:YES];
             //To Do: modify something for other vertical size
         }
         [self.view setNeedsLayout];
     } completion:nil];
}

/**
 *  横竖屏切换
 *
 *  @param isVertical isVertical description
 */
-(void)changeCrossOrVerticalscreen:(BOOL)isVertical{
    _isScreenVertical = isVertical;
    if (!isVertical) {
        //直播播放器
        //        self.livePlayingManager.currentLiveView.frame = self.view.frame;
    } else {
        //直播播放器
        //        self.livePlayingManager.currentLiveView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.contentView.frame.size.height);
    }
    float inputBarOriginY = self.conversationMessageCollectionView.bounds.size.height + 30;
    float inputBarOriginX = self.conversationMessageCollectionView.frame.origin.x;
    float inputBarSizeWidth = self.contentView.frame.size.width;
    float inputBarSizeHeight = MinHeight_InputView;
    //添加输入框
    [self.inputBar changeInputBarFrame:CGRectMake(inputBarOriginX, inputBarOriginY,inputBarSizeWidth,inputBarSizeHeight)];
    for (RCDLiveMessageModel *__item in self.conversationDataRepository) {
        __item.cellSize = CGSizeZero;
    }
    [self changeModel:YES];
    [self.view bringSubviewToFront:self.backBtn];
    [self.inputBar setHidden:YES];
}

/**
 *  连接状态改变的回调
 *
 */
- (void)onConnectionStatusChanged:(RCConnectionStatus)status {
    self.currentConnectionStatus = status;
    [self quitConversationViewAndClear];
    UIWindow *  window = [UIApplication sharedApplication].keyWindow;
    
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示"
                              message:
                              @"您的帐号在别的设备上登录，"
                              @"您被迫下线！"
                              delegate:nil
                              cancelButtonTitle:@"知道了"
                              otherButtonTitles:nil, nil];
        [alert show];
        
        //        RCIM.shared().logout()
        //        UserDefaults.standard.removeObject(forKey: "userPwd")
        //        UserDefaults.standard.removeObject(forKey: "userToken")
        //        UserDefaults.standard.removeObject(forKey: "userId")
        //        UserModel.shared.id = 0
        //        DBTool.shared.removeUserModel()
        [[RCIM sharedRCIM] logout];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userPwd"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userToken"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userId"];
        [UserModel shared].ID = 0;
        [[DBTool shared] removeUserModel];
        
        window.rootViewController = [UIStoryboard storyboardWithName:@"Login" bundle:nil].instantiateInitialViewController;;
    } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
        //        [AFHttpTool getTokenSuccess:^(id response) {
        //            NSString *token = response[@"result"][@"token"];
        //            [[RCIM sharedRCIM] connectWithToken:token
        //                                        success:^(NSString *userId) {
        //
        //                                        } error:^(RCConnectErrorCode status) {
        //
        //                                        } tokenIncorrect:^{
        //
        //                                        }];
        //        }
        //                            failure:^(NSError *err) {
        //
        //                            }];
    }
    
}


- (void)praiseHeart{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(_clapBtn.frame.origin.x , _clapBtn.frame.origin.y - 49, 35, 35);
    imageView.image = [UIImage imageNamed:@"heart"];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.clipsToBounds = YES;
    [self.view addSubview:imageView];
    
    
    CGFloat startX = round(random() % 200);
    CGFloat scale = round(random() % 2) + 1.0;
    CGFloat speed = 1 / round(random() % 900) + 0.6;
    int imageName = round(random() % 7);
    NSLog(@"%.2f - %.2f -- %d",startX,scale,imageName);
    
    [UIView beginAnimations:nil context:(__bridge void *_Nullable)(imageView)];
    [UIView setAnimationDuration:7 * speed];
    
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"heart%d.png",imageName]];
    imageView.frame = CGRectMake(kBounds.width - startX, -100, 35 * scale, 35 * scale);
    
    [UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}


- (void)praiseGift{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(_flowerBtn.frame.origin.x , _flowerBtn.frame.origin.y - 49, 35, 35);
    imageView.image = [UIImage imageNamed:@"gift"];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.clipsToBounds = YES;
    [self.view addSubview:imageView];
    
    
    CGFloat startX = round(random() % 200);
    CGFloat scale = round(random() % 2) + 1.0;
    CGFloat speed = 1 / round(random() % 900) + 0.6;
    int imageName = round(random() % 2);
    NSLog(@"%.2f - %.2f -- %d",startX,scale,imageName);
    
    [UIView beginAnimations:nil context:(__bridge void *_Nullable)(imageView)];
    [UIView setAnimationDuration:7 * speed];
    
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gift%d.png",imageName]];
    imageView.frame = CGRectMake(kBounds.width - startX, -100, 35 * scale, 35 * scale);
    
    [UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}


- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    
    UIImageView *imageView = (__bridge UIImageView *)(context);
    [imageView removeFromSuperview];
}

@end
