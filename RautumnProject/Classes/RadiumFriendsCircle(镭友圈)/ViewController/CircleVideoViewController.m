//
//  CircleVideoViewController.m
//  RautumnProject
//
//  Created by 陈雷 on 2017/3/1.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

#import "CircleVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
//#import <Masonry/Masonry.h>
//#import <ZFDownload/ZFDownloadManager.h>
#import "ZFPlayer.h"
@interface CircleVideoViewController () <ZFPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (strong, nonatomic) ZFPlayerView *playerView;
/** 离开页面时候是否在播放 */
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) ZFPlayerModel *playerModel;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation CircleVideoViewController
- (void)dealloc {
    NSLog(@"%@释放了",self.class);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    // pop回来时候是否自动播放
    if (self.navigationController.viewControllers.count == 2 && self.playerView && self.isPlaying) {
        self.isPlaying = NO;
        [self.playerView play];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    // push出下一级页面时候暂停
    if (self.navigationController.viewControllers.count == 3 && self.playerView && !self.playerView.isPauseByUser)
    {
        self.isPlaying = YES;
        [self.playerView pause];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     self.playerFatherView = [[UIView alloc] init];
     [self.view addSubview:self.playerFatherView];
     [self.playerFatherView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.mas_equalTo(20);
     make.leading.trailing.mas_equalTo(0);
     // 这里宽高比16：9,可自定义宽高比
     make.height.mas_equalTo(self.playerFatherView.mas_width).multipliedBy(9.0f/16.0f);
     }];
     */
    // 自动播放，默认不自动播放
    [self.playerView autoPlayTheVideo];
}

// 返回值要必须为NO
- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - ZFPlayerDelegate

- (void)zf_playerBackAction {
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)zf_playerDownload:(NSString *)url {

    UIAlertController * vc =  [UIAlertController alertControllerWithTitle:@"确定要删除此视频吗?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [vc addAction:[UIAlertAction actionWithTitle:@"删除"  style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteVideoNotifation" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消"  style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:vc animated:YES completion:nil];
    
}

#pragma mark - Getter

- (ZFPlayerModel *)playerModel {
    if (!_playerModel) {
        _playerModel                  = [[ZFPlayerModel alloc] init];
        //        _playerModel.title            = @"这里设置视频标题";
        _playerModel.videoURL         = self.videoUrl;
        _playerModel.placeholderImage = [UIImage imageNamed:@"loading_bgView1"];
        _playerModel.fatherView       = self.videoContainerView;
    }
    return _playerModel;
}
- (ZFPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[ZFPlayerView alloc] init];
        
        /*****************************************************************************************
         *   // 指定控制层(可自定义)
         *   // ZFPlayerControlView *controlView = [[ZFPlayerControlView alloc] init];
         *   // 设置控制层和播放模型
         *   // 控制层传nil，默认使用ZFPlayerControlView(如自定义可传自定义的控制层)
         *   // 等效于 [_playerView playerModel:self.playerModel];
         ******************************************************************************************/
        [_playerView playerControlView:nil playerModel:self.playerModel];
        
        // 设置代理
        _playerView.zf_delegate = self;
        
        //（可选设置）可以设置视频的填充模式，内部设置默认（ZFPlayerLayerGravityResizeAspect：等比例填充，直到一个维度到达区域边界）
        // self.playerView.playerLayerGravity = ZFPlayerLayerGravityResizeAspect;
        
        // 打开下载功能（默认没有这个功能）
        _playerView.hasDownload    = YES;
        
        // 打开预览图
        self.playerView.hasPreviewView = YES;
        
    }
    return _playerView;
}


@end
