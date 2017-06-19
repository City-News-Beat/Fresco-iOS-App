//
//  FRSCarouselCell.m
//  Fresco
//
//  Created by Philip Bernstein on 6/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//
#import "FRSCarouselCell.h"
#import "FRSSnapKit.h"
#import "FRSFileTagManager.h"
#import "FRSCameraConstants.h"
#import "FRSCaptureModeEnumHelper.h"
#import "FRSDateFormatter.h"

#define ASSET_SIZE 500

@interface FRSCarouselCell ()

@property (weak, nonatomic) IBOutlet UIImageView *tagIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation FRSCarouselCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.didUnmute = NO;
    
    [self addShadowToLabel:self.tagNameLabel];
    [self addShadowToLabel:self.timeLabel];
}

#pragma mark - Asset Initialization

- (void)loadImage:(PHAsset *)asset {
    self.asset = asset;
    [self removePlayers];

    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self.contentView addSubview:imageView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[PHImageManager defaultManager]
             requestImageForAsset:asset
             targetSize:CGSizeMake(ASSET_SIZE, ASSET_SIZE)
             contentMode:PHImageContentModeAspectFill
             options:nil
             resultHandler:^(UIImage *result, NSDictionary *info) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     imageView.image = result;
                     imageView.contentMode = UIViewContentModeScaleAspectFill;
                     imageView.clipsToBounds = YES;
                     // We should re implement the stretchy header in the carousel cell at some point.
                     // Good resource to follow https://nrj.io/stretchy-uicollectionview-headers/
                     [FRSSnapKit constrainSubview:imageView ToBottomOfParentView:self WithHeight:imageView.frame.size.height];

                     [self updateTagInfo];
                     
                 });
             }];
        });
    }
    
    
}
- (void)loadVideo:(PHAsset *)asset {
    self.asset = asset;
    [self removePlayers];
    [self playPlayer];
    [self updateTagInfo];
    
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
                 [self.contentView.layer addSublayer:playerLayer];
                 [videoView play];
                 
                 UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlayer)];
                 [self addGestureRecognizer:tap];
                 
                 [self.contentView bringSubviewToFront:self.muteImageView];
                 [self updateTagInfo];
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
        [self.contentView addSubview:self.muteImageView];
        [self.contentView bringSubviewToFront:self.muteImageView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (playerLayer) {
        playerLayer.frame = self.bounds;
    }
}

- (void)updateTagInfo {
    [self.contentView bringSubviewToFront:self.tagIconImageView];
    [self.contentView bringSubviewToFront:self.tagNameLabel];
    [self.contentView bringSubviewToFront:self.timeLabel];
    
    [self configureTagIconImageView];
}

- (void)configureTagIconImageView {
    FRSCaptureMode captureMode = [[FRSFileTagManager sharedInstance] fetchCaptureModeForAsset:self.asset];
    switch (captureMode) {
        case FRSCaptureModeVideoInterview:
            self.tagIconImageView.image = [UIImage imageNamed:@"tag-upload-interview-icon"];
            break;
        case FRSCaptureModeVideoPan:
            self.tagIconImageView.image = [UIImage imageNamed:@"tag-upload-pan-icon"];
            break;
        case FRSCaptureModeVideoWide:
            self.tagIconImageView.image = [UIImage imageNamed:@"tag-upload-wide-icon"];
            break;
        default:
            if (self.asset.mediaType == PHAssetMediaTypeVideo) {
                self.tagIconImageView.image = [UIImage imageNamed:@"tag-upload-video-icon"];
            }
            else {
                self.tagIconImageView.image = [UIImage imageNamed:@"tag-upload-photo-icon"];
            }
            break;
            
    }
    
    self.tagNameLabel.text = [FRSCaptureModeEnumHelper rawValueForCaptureMode:captureMode];
    
    self.timeLabel.text = [FRSDateFormatter localTimeZoneFromDate:self.asset.creationDate];

}

- (void)addShadowToLabel:(UILabel *)label {
    if ([label.text isEqualToString:@""] || !label) {
        return;
    }
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:label.text];
    NSRange range = NSMakeRange(0, [attString length]);
    
    [attString addAttribute:NSFontAttributeName value:label.font range:range];
    [attString addAttribute:NSForegroundColorAttributeName value:label.textColor range:range];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
    shadow.shadowOffset = CGSizeMake(0, 1);
    shadow.shadowBlurRadius = 1.5;
    [attString addAttribute:NSShadowAttributeName value:shadow range:range];
    
    label.attributedText = attString;
}

@end
