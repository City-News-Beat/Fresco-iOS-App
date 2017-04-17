//
//  FRSGalleryMediaVideoCollectionViewCell.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 4/13/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryMediaVideoCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSURL+Fresco.h"
#import "FRSPost.h"

@interface FRSGalleryMediaVideoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) FRSPost *post;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@end

@implementation FRSGalleryMediaVideoCollectionViewCell

-(void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self addGestureRecognizer:tap];

}

-(void)loadPost:(FRSPost *)post {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.post = post;

        if([self.post.videoUrl isEqualToString:[self urlOfCurrentlyPlayingInPlayer:self.videoPlayer]]){
            NSLog(@"Rev Already current player has the same url. so no cleanup, no setup for the player. just skip");
            return;
        }
        
        self.userInteractionEnabled = YES;
        
        //cleanup so that its ready for the new content.
        [self cleanupForVideo];
        
        NSLog(@"Rev loadPost for weakSelf..%@", self);
        //video. just setting url to the player
        //every loaded cell will have its own player. so just need to play/pause with the correct cell object.
        
        if (self.post.videoUrl) {
            self.imageView.image = nil;
            [self setupPlayerForPost:self.post play:TRUE];
            NSLog(@"Rev \non cell : %@ : \ncreating player:%@ : \npost is video now..%@", self, self.videoPlayer, post.uid);
            
        }
    
    });

    
    [self loadImage];
}

- (void)loadImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.imageView.image = nil;
        if(!self.post.imageUrl) return;
        
        [self.imageView sd_setImageWithURL:[NSURL
                                            URLResizedFromURLString:self.post.imageUrl
                                            width:([UIScreen mainScreen].bounds.size.width * [[UIScreen mainScreen] scale])
                                            ]
                     placeholderImage:nil];

    });
    
}

- (void)setupPlayerForPost:(FRSPost *)post play:(BOOL)play {
    dispatch_async(dispatch_get_main_queue(), ^{
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
        container.backgroundColor = [UIColor clearColor];
        
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
    });

    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self.videoPlayer play];
    });

}

-(void)cleanupForVideo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Rev cleaning up for post: %@", self.post.uid);
        if ([[self.videoPlayer class] isSubclassOfClass:[FRSPlayer class]]) {
            [self.videoPlayer pause];
            [self.videoPlayer.currentItem cancelPendingSeeks];
            [self.videoPlayer.currentItem.asset cancelLoading];
        }
        self.videoPlayer = nil;
        
        self.playerLayer.player = nil;
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    });

}

-(void)play {
    NSLog(@"Rev video video play play");
    [self urlOfCurrentlyPlayingInPlayer:self.videoPlayer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoPlayer play];
    });
}

-(void)pause {
    NSLog(@"Rev video video pause pause");
    [self urlOfCurrentlyPlayingInPlayer:self.videoPlayer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoPlayer pause];
    });

}

-(void)tap {
    NSLog(@"Rev video video mute mute pause pause");
//    [self.videoPlayer pause];

//    self.videoPlayer.muted = !self.videoPlayer.muted;
    
}

-(void)restart {
    
}

-(void)tapped {
    NSLog(@"Rev new video mute Unmute");

    self.videoPlayer.muted = !self.videoPlayer.muted;
}

-(NSString *)urlOfCurrentlyPlayingInPlayer:(AVPlayer *)player{
    // get current asset
    AVAsset *currentPlayerAsset = player.currentItem.asset;
    // make sure the current asset is an AVURLAsset
    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) return nil;
    // return the string from NSURL
    
    NSString *urlString = [[(AVURLAsset *)currentPlayerAsset URL] absoluteString];
    NSLog(@"Rev urlString of current video player: %@", urlString);
    return urlString;
}


@end
