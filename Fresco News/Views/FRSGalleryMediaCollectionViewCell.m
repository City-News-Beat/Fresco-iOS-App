//
//  FRSGalleryMediaCollectionViewCell.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 4/10/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryMediaCollectionViewCell.h"
#import <Haneke/Haneke.h>
#import "NSURL+Fresco.h"
#import "FRSPost.h"
#import "FRSPlayer.h"

@interface FRSGalleryMediaCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) FRSPost *post;
@property (strong, nonatomic) FRSPlayer *videoPlayer;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@end

@implementation FRSGalleryMediaCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)loadPost:(FRSPost *)post {
    __weak FRSGalleryMediaCollectionViewCell *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.imageView.image = nil;
        weakSelf.userInteractionEnabled = YES;
        weakSelf.post = post;
        
        [weakSelf play];
    });

}

- (void)loadImage {
    self.imageView.image = nil;
    if(!self.post.imageUrl) return;
        
    [self.imageView
     hnk_setImageFromURL:[NSURL
                          URLResizedFromURLString:self.post.imageUrl
                          width:([UIScreen mainScreen].bounds.size.width * [[UIScreen mainScreen] scale])
                          ]
     ];
}

- (FRSPlayer *)setupPlayerForPost:(FRSPost *)post play:(BOOL)play {

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    FRSPlayer *videoPlayer;
    
    if (!play) {
        videoPlayer = [[FRSPlayer alloc] init];
    } else {
        videoPlayer = [FRSPlayer playerWithURL:[NSURL URLWithString:post.videoUrl]];
    }
    
    videoPlayer.hasEstablished = play;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:videoPlayer];
        videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[videoPlayer currentItem]];
        
        
        playerLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.frame.size.height);
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        playerLayer.backgroundColor = [UIColor clearColor].CGColor;
        playerLayer.opaque = FALSE;
        
        UIView *container = [[UIView alloc] initWithFrame:playerLayer.frame];
        container.backgroundColor = [UIColor clearColor];
        
        videoPlayer.container = container;
        playerLayer.frame = CGRectMake(0, 0, playerLayer.frame.size.width, playerLayer.frame.size.height);
        
        if (play) {
            [container.layer insertSublayer:playerLayer atIndex:1000];
        }
        
        self.playerLayer = playerLayer;
        
        [self addSubview:container];
        [self bringSubviewToFront:container];
        
        container.userInteractionEnabled = YES;
//        [self configureMuteIcon];
    });
    
    videoPlayer.muted = TRUE;
    videoPlayer.wasMuted = FALSE;
    
    return videoPlayer;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.videoPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.videoPlayer play];
}

-(void)cleanupForVideo {
    if ([[self.videoPlayer class] isSubclassOfClass:[FRSPlayer class]]) {
        [self.videoPlayer.currentItem cancelPendingSeeks];
        [self.videoPlayer.currentItem.asset cancelLoading];
    }
    self.videoPlayer = nil;
    
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
}

-(void)play {
    __weak FRSGalleryMediaCollectionViewCell *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //cleanup
        [weakSelf cleanupForVideo];
        
        //video
        if (weakSelf.post.videoUrl) {
            weakSelf.imageView.image = nil;
            FRSPlayer *player = [weakSelf setupPlayerForPost:weakSelf.post play:TRUE];
            player.muted = FALSE;
            weakSelf.videoPlayer = player;
            [weakSelf.videoPlayer play];
        }
        else {
            
        }
        
    });
}

-(void)pause {
    
}

@end
