//
//  HKPlayerAudio.h
//  RautumnProject
//
//  Created by xilaida on 2017/5/26.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLAudioPlayer.h"

@interface HKPlayerAudio : NSObject

@property (nonatomic, strong) PLAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSString *aFilePath;

-(void)endPlay;
- (void)startPlayWithUrlString:(NSString *)urlString updateMeters:(void(^)(NSInteger))timeBlock success:(void(^)(void))success failed:(void(^)(NSError *))failed;

- (void)startPlay;
- (void)pausePlay;

@end
