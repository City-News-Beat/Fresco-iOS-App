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

@interface FRSGalleryMediaCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) FRSPost *post;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@end

@implementation FRSGalleryMediaCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)loadPost:(FRSPost *)post isCasualCall:(BOOL)isCausal{
        if (!isCausal) return;
    
        self.imageView.image = nil;
        self.userInteractionEnabled = YES;
        self.post = post;
        
        //cleanup so that its ready for the new content.
        [self cleanupForVideo];
        
        NSLog(@"loadPost for weakSelf..%@", self);
        //video. just setting url to the player
        //every loaded cell will have its own player. so just need to play/pause with the correct cell object.
        if (self.post.videoUrl) {
            NSLog(@"post is video now..%@", post);
            self.imageView.image = nil;
            if(self.videoPlayer){
                NSLog(@"replaceCurrentItemWithPlayerItem for player: %@", self.videoPlayer);
                [self.videoPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:post.videoUrl]]];
            }
            else {
                [self setupPlayerForPost:self.post play:TRUE];
                NSLog(@"setupPlayerForPost for player: %@", self.videoPlayer);
                
            }
        }
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

- (void)setupPlayerForPost:(FRSPost *)post play:(BOOL)play {
    
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        
        FRSPlayer *videoPlayer;
        
        if (!play) {
            videoPlayer = [[FRSPlayer alloc] init];
        } else {
            videoPlayer = [FRSPlayer playerWithURL:[NSURL URLWithString:post.videoUrl]];
        }
        
        videoPlayer.hasEstablished = play;
        
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
        //TODO: Scroll - finally change to clear color.
        container.backgroundColor = [UIColor orangeColor];
        
        videoPlayer.container = container;
        playerLayer.frame = CGRectMake(0, 0, playerLayer.frame.size.width, playerLayer.frame.size.height);
        
        if (play) {
            [container.layer insertSublayer:playerLayer atIndex:1000];
        }
        
        
        [self addSubview:container];
        [self bringSubviewToFront:container];
        
        container.userInteractionEnabled = YES;
        //        [self configureMuteIcon];
        
        videoPlayer.muted = TRUE;
        videoPlayer.wasMuted = FALSE;
        
        self.playerLayer = playerLayer;
        self.videoPlayer = videoPlayer;
        
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.videoPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.videoPlayer play];
}

-(void)cleanupForVideo {
    NSLog(@"cleaning up for post: %@", self.post.uid);
    if ([[self.videoPlayer class] isSubclassOfClass:[FRSPlayer class]]) {
        [self.videoPlayer pause];
        //        [self.videoPlayer.currentItem cancelPendingSeeks];
        //        [self.videoPlayer.currentItem.asset cancelLoading];
    }
    //    self.videoPlayer = nil;
    //
    //    self.playerLayer.player = nil;
    //    [self.playerLayer removeFromSuperlayer];
    //    self.playerLayer = nil;
}

-(void)play {
    __weak FRSGalleryMediaCollectionViewCell *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //video
        if (weakSelf.post.videoUrl) {
            [weakSelf.videoPlayer play];
        }
        else {
            
        }
        
    });
}

-(void)pause {
    [self.videoPlayer pause];
}

-(void)tap {
    self.videoPlayer.muted = !self.videoPlayer.muted;
    
}

/*
 - (void)playerItemDidReachEnd:(NSNotification *)notification {
 [self.videoPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
 [self.videoPlayer play];
 }
 
 */
@end
