//
//  FRSCarouselCell.m
//  Fresco
//
//  Created by Philip Bernstein on 6/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//
#import "FRSCarouselCell.h"
#import "FRSSnapKit.h"

@implementation FRSCarouselCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.didUnmute = NO;
}

#pragma mark - Asset Initialization

- (void)loadImage:(PHAsset *)asset {
    [self removePlayers];

    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:imageView];

        dispatch_async(dispatch_get_main_queue(), ^{
          [[PHImageManager defaultManager]
              requestImageForAsset:asset
                        targetSize:CGSizeMake(self.frame.size.width, self.frame.size.height)
                       contentMode:PHImageContentModeAspectFill
                           options:nil
                     resultHandler:^(UIImage *result, NSDictionary *info) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                         imageView.image = result;
                         imageView.contentMode = UIViewContentModeScaleAspectFill;
                         [FRSSnapKit constrainSubview:imageView ToBottomOfParentView:self WithHeight:imageView.frame.size.height];
                       });
                     }];
        });
    }
}
- (void)loadVideo:(PHAsset *)asset {
    [self removePlayers];
    [self playPlayer];

    if (!videoView) {
        videoView = [[FRSPlayer alloc] init];
        [[PHImageManager defaultManager]
            requestAVAssetForVideo:asset
                           options:nil
                     resultHandler:^(AVAsset *_Nullable avAsset, AVAudioMix *_Nullable audioMix, NSDictionary *_Nullable info) {

                       dispatch_async(dispatch_get_main_queue(), ^{
                         if (videoView) {
                             [self removePlayers];
                         }
                         AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:avAsset];
                         videoView = [[FRSPlayer alloc] initWithPlayerItem:playerItem];
                         videoView.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[videoView currentItem]];
                         playerLayer = [AVPlayerLayer playerLayerWithPlayer:videoView];
                         playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                         playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                         [self.layer addSublayer:playerLayer];
                         [videoView play];

                         UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlayer)];
                         [self addGestureRecognizer:tap];

                         [self bringSubviewToFront:self.muteImageView];
                       });
                     }];
    }
}
#pragma mark - Player

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    [playerItem seekToTime:kCMTimeZero];
}

- (void)tapPlayer {
    if (videoView.rate != 0) {
        [self pausePlayer];
    } else {
        [self playPlayer];
    }
}

- (void)pausePlayer {
    [videoView pause];
}

- (void)playPlayer {
    [videoView play];
}

- (void)removePlayers {
    imageView = nil;
    [playerLayer removeFromSuperlayer];
    [videoView pause];

    playerLayer = nil;
    videoView = nil;
}

#pragma mark - Mute Icon

- (void)configureMuteIcon {
    if (!self.muteImageView) {
        self.muteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mute"]];
        self.muteImageView.alpha = 1;
        self.muteImageView.frame = CGRectMake(16, self.frame.size.height - 24 - 16, 24, 24);
        [self addSubview:self.muteImageView];
        [self bringSubviewToFront:self.muteImageView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (playerLayer) {
        playerLayer.frame = self.bounds;
    }
}

@end
