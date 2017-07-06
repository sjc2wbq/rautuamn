//
//  RCVideoMessageCell.m
//  RautumnProject
//
//  Created by 陈雷 on 2017/3/7.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

#import "RCVideoMessageCell.h"
#import "RCVideoMessage.h"
#import <MediaPlayer/MediaPlayer.h>
#import <SDWebImage/UIImageView+WebCache.h>
@interface RCVideoMessageCell()
@property(nonatomic,strong)UIImageView *bubbleImage;
@end
@implementation RCVideoMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height = 130.f;
    __messagecontentview_height += extraHeight;
    
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

- (NSDictionary *)attributeDictionary {
    if (self.messageDirection == MessageDirection_SEND) {
        return @{
                 @(NSTextCheckingTypeLink) : @{NSForegroundColorAttributeName : [UIColor blueColor]},
                 @(NSTextCheckingTypePhoneNumber) : @{NSForegroundColorAttributeName : [UIColor blueColor]}
                 };
    } else {
        return @{
                 @(NSTextCheckingTypeLink) : @{NSForegroundColorAttributeName : [UIColor blueColor]},
                 @(NSTextCheckingTypePhoneNumber) : @{NSForegroundColorAttributeName : [UIColor blueColor]}
                 };
    }
    return nil;
}

- (NSDictionary *)highlightedAttributeDictionary {
    return [self attributeDictionary];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
     
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}
- (void)initialize {
    
    self.bubbleImage = [[UIImageView alloc] init];
    self.bubbleImage.contentMode = UIViewContentModeScaleToFill;
    [self.messageContentView addSubview:self.bubbleImage];

    
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    


    self.videoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.videoImageView.clipsToBounds = YES;
    self.videoImageView.layer.masksToBounds = YES;
    [self.bubbleImage removeFromSuperview];
    self.videoImageView.layer.mask = self.bubbleImage.layer;
    self.videoImageView.backgroundColor = [UIColor blackColor];
    
    self.videoPlayImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.videoPlayImageView.backgroundColor = [UIColor clearColor];
    self.videoPlayImageView.contentMode = UIViewContentModeCenter;
    [self.videoPlayImageView setImage:[UIImage imageNamed:@"video_icon_play"]];

    
    [self.bubbleBackgroundView addSubview:self.videoImageView];
    [self.bubbleBackgroundView addSubview:self.videoPlayImageView];
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapd:)];
    [self.bubbleBackgroundView addGestureRecognizer:tap];
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    
    [self setAutoLayout];
}
- (void)setAutoLayout {
    RCVideoMessage *_videoMessage = (RCVideoMessage *)self.model.content;
    if (_videoMessage.thumbnailImage) {
        self.videoImageView.image = _videoMessage.thumbnailImage;
    }else{
        [self.videoImageView sd_setImageWithURL:[NSURL URLWithString:_videoMessage.imageUri] placeholderImage:nil];
    }

    CGSize __textSize ;
    __textSize = CGSizeMake(ceilf(150), ceilf(100));
    CGSize __labelSize = CGSizeMake(__textSize.width + 5, __textSize.height + 5);
    
    CGFloat __bubbleWidth = __labelSize.width + 15 + 20 < 50 ? 50 : (__labelSize.width + 15 + 20);
    CGFloat __bubbleHeight = __labelSize.height + 5 + 5 < 35 ? 35 : (__labelSize.height + 5 + 5);
    
    CGSize __bubbleSize = CGSizeMake(__bubbleWidth, __bubbleHeight);
    
    CGRect messageContentViewRect = self.messageContentView.frame;
    
    if (MessageDirection_RECEIVE == self.messageDirection) {
        messageContentViewRect.size.width = __bubbleSize.width;
        self.messageContentView.frame = messageContentViewRect;
        
        self.bubbleBackgroundView.frame = CGRectMake(0, 0, __bubbleSize.width, __bubbleSize.height);
        self.videoImageView.frame=self.bubbleBackgroundView.frame;
        self.videoPlayImageView.frame=self.bubbleBackgroundView.frame;
        //        self.textLabel.frame = CGRectMake(20, 5, __labelSize.width, __labelSize.height);
        self.bubbleBackgroundView.image = [self imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
        UIImage *image = self.bubbleBackgroundView.image;
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,
                                                                                    image.size.height * 0.2, image.size.width * 0.2)];
    } else {
        messageContentViewRect.size.width = __bubbleSize.width;
        messageContentViewRect.origin.x =
        self.baseContentView.bounds.size.width -
        (messageContentViewRect.size.width + 10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        self.messageContentView.frame = messageContentViewRect;
        
        self.bubbleBackgroundView.frame = CGRectMake(0, 0, __bubbleSize.width, __bubbleSize.height);
        self.videoImageView.frame=self.bubbleBackgroundView.frame;
        self.videoPlayImageView.frame=self.bubbleBackgroundView.frame;
        //        self.textLabel.frame = CGRectMake(15, 5, __labelSize.width, __labelSize.height);
        
        self.bubbleBackgroundView.image = [self imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
        UIImage *image = self.bubbleBackgroundView.image;
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2,
                                                                                        image.size.height * 0.2, image.size.width * 0.8)];
        

    }
    self.bubbleImage.image =  self.bubbleBackgroundView.image;

    self.bubbleImage.frame = self.videoImageView.frame;

}
- (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName {
    UIImage *image = nil;
    NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:bundleName];
    NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];
    image = [[UIImage alloc] initWithContentsOfFile:image_path];
    
    return image;
}

- (void)tapd:(id)sender {
    [self.delegate didTapMessageCell:self.model];
}
- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        //DebugLog(@”long press end”);
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.bubbleBackgroundView];
    }
}


@end
