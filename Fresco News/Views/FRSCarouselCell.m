//
//  FRSCarouselCell.m
//  Fresco
//
//  Created by Philip Bernstein on 6/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//
#import "FRSCarouselCell.h"
@implementation FRSCarouselCell
-(void)awakeFromNib {
    [super awakeFromNib];
    self.didUnmute = NO;
}
#pragma mark - Asset Initialization
-(void)loadImage:(PHAsset *)asset {
    
    //    if (self.asset != nil) {
    //        return;
    //    }
    
    [self removePlayers];
    
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:imageView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.resizeMode = PHImageRequestOptionsResizeModeNone;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.version = PHImageRequestOptionsVersionOriginal;
            
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                imageView.image = [UIImage imageWithData:imageData];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                
                [self constrainSubview:imageView ToBottomOfParentView:self];
            }];
            
        });
    }
}
-(void)loadVideo:(PHAsset *)asset {
    
    //    if (self.asset != nil) {
    //        return;
    //    }
    
    [self removePlayers];
    [self playPlayer];
    
    if (!videoView) {
        videoView = [[FRSPlayer alloc] init];
        [[PHImageManager defaultManager]
         requestAVAssetForVideo:asset
         options:nil
         resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
             
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
                 
                 //self.asset = asset;
                 
                 UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlayer)];
                 [self addGestureRecognizer:tap];
                 
                 //[self configureMuteIcon];
                 [self bringSubviewToFront:self.muteImageView];
             });
         }];
    }
}
#pragma mark - Player
-(void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    [playerItem seekToTime:kCMTimeZero];
}
-(void)tapPlayer {
    
    if (videoView.rate != 0) {
        //if (!self.didUnmute) {
        //    if (videoView.volume == 0) {
        //        videoView.volume = 1;
        //        self.muteImageView.alpha = 0;
        //        self.didUnmute = YES;
        //        return;
        //    }
        //}
        
        [self pausePlayer];
    } else {
        [self playPlayer];
    }
}
-(void)pausePlayer {
    [videoView pause];
}
-(void)playPlayer {
    [videoView play];
    if (!self.didUnmute) {
        //videoView.volume = 0.0;
        //self.muteImageView.alpha = 1;
    }
}
-(void)removePlayers {
    imageView = nil;
    [playerLayer removeFromSuperlayer];
    [videoView pause];
    
    playerLayer = nil;
    videoView = nil;
}
#pragma mark - Mute Icon
-(void)configureMuteIcon {
    if (!self.muteImageView) {
        self.muteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mute"]];
        self.muteImageView.alpha = 1;
        self.muteImageView.frame = CGRectMake(16, self.frame.size.height - 24 - 16, 24, 24);
        [self addSubview:self.muteImageView];
        [self bringSubviewToFront:self.muteImageView];
    }
}
#pragma mark - Constraints
-(void)constrainSubview:(UIView *)subView ToBottomOfParentView:(UIView *)parentView {
    
    NSLog(@"SUBVIEW: %@", subView);
    NSLog(@"PARENTVIEW: %@", parentView);
    
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Trailing
    NSLayoutConstraint *trailing = [NSLayoutConstraint
                                    constraintWithItem:subView
                                    attribute:NSLayoutAttributeTrailing
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:parentView
                                    attribute:NSLayoutAttributeTrailing
                                    multiplier:1
                                    constant:0];
    
    //Leading
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:subView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:parentView
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1
                                   constant:0];
    
    //Bottom
    NSLayoutConstraint *bottom = [NSLayoutConstraint
                                  constraintWithItem:subView
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:parentView
                                  attribute:NSLayoutAttributeBottom
                                  multiplier:1
                                  constant:0];
    
    
    //top
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:subView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:parentView
                               attribute:NSLayoutAttributeTop
                               multiplier:1
                               constant:0];
    
    [parentView addConstraint:trailing];
    [parentView addConstraint:leading];
    [parentView addConstraint:bottom];
    [parentView addConstraint:top];
    
}
-(void)constrainLayer:(AVPlayerLayer *)subView ToBottomOfParentView:(UIView *)parentView {
    
    NSLog(@"SUBVIEW: %@", subView);
    NSLog(@"PARENTVIEW: %@", parentView);
    
    //    subView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Trailing
    NSLayoutConstraint *trailing = [NSLayoutConstraint
                                    constraintWithItem:subView
                                    attribute:NSLayoutAttributeTrailing
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:parentView
                                    attribute:NSLayoutAttributeTrailing
                                    multiplier:1
                                    constant:0];
    
    //Leading
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:subView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:parentView
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1
                                   constant:0];
    
    //Bottom
    NSLayoutConstraint *bottom = [NSLayoutConstraint
                                  constraintWithItem:subView
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:parentView
                                  attribute:NSLayoutAttributeBottom
                                  multiplier:1
                                  constant:0];
    
    
    //top
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:subView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:parentView
                               attribute:NSLayoutAttributeTop
                               multiplier:1
                               constant:0];
    
    
    [parentView addConstraint:trailing];
    [parentView addConstraint:leading];
    [parentView addConstraint:bottom];
    [parentView addConstraint:top];
    
    
}
-(void)layoutSubviews {
    [super layoutSubviews];
    if (playerLayer) {
        //        [self pausePlayer];
        playerLayer.frame = self.bounds;
    }
}
@end
