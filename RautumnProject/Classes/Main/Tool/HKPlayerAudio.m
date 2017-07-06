//
//  HKPlayerAudio.m
//  RautumnProject
//
//  Created by xilaida on 2017/5/26.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

#import "HKPlayerAudio.h"

@interface HKPlayerAudio ()



@end

@implementation HKPlayerAudio

- (instancetype)init {
    self = [super init];
    if (self) {
       self.audioPlayer = [[PLAudioPlayer alloc] init];
        self.audioPlayer.isNeedConvert=YES;
    }
    return self;
}

-(void)endPlay{
    [_audioPlayer stopPlay];
    
    if (self.aFilePath && self.aFilePath.length != 0) {
       [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:self.aFilePath] error:nil];
    }
}

- (void)startPlayWithUrlString:(NSString *)urlString updateMeters:(void(^)(NSInteger))timeBlock success:(void(^)(void))success failed:(void(^)(NSError *))failed{
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    //    NSLog(@"%@", data);
    //设置保存文件夹
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //设置保存路径和生成文件名
    
//    NSString *filePath = [NSString stringWithFormat:@"%@/audioAac.aac",docDirPath];
//    if ([urlString hasSuffix:@".amr"]) {
//        
//       filePath = [NSString stringWithFormat:@"%@/audioAmr.amr",docDirPath];
//    }
    NSString *filePath = [NSString stringWithFormat:@"%@/audioAmr.amr",docDirPath];
    self.aFilePath = filePath;
    
    //保存
    if ([data writeToFile:filePath atomically:YES]) {
        NSLog(@"succeed = %@", filePath);
        [self.audioPlayer startPlayAudioFile:filePath
                           updateMeters:^(NSInteger meters){
                               
                               NSLog(@"sssss");
                               if (meters >= 0) {
                                 timeBlock(meters);
                               }
                               
                           }
                                success:^{
                                    // 停止UI的播放
                                    //
                                    NSLog(@"播放成功");
                                    success();
                                    
                                } failed:^(NSError *error) {
                                    // 停止UI的播放
                                    failed(error);
                                    
                                    NSLog(@"播放失败");
                                } ];
    }else{
        NSLog(@"faild");
    }
}

- (void)startPlay {
    [self.audioPlayer startPlay];
}
- (void)pausePlay {
    [self.audioPlayer pausePlay];
}

@end
