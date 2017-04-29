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

@interface FRSGalleryMediaVideoCollectionViewCell (Player)
- (void)removePlayerTimeObserver;
- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)playerItemDidReachEnd:(NSNotification *)notification ;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;
@end

@interface FRSGalleryMediaVideoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bufferIndicator;

@property (strong, nonatomic) FRSPost *post;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@end


static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerBufferObservationContext = &AVPlayerDemoPlaybackViewControllerBufferObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;

@implementation FRSGalleryMediaVideoCollectionViewCell

-(void)prepareForReuse {
    [super prepareForReuse];
    NSLog(@"Rev prepare the video player to be reusable here.");
    [self.imageView sd_cancelCurrentImageLoad];
    self.imageView.image = nil;
//    [self.mPlaybackView setPlayer:nil];
    self.post = nil;
    [self hideBuffer];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self setPlayer:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self addGestureRecognizer:tap];
    
}

-(void)showBuffer {
    NSLog(@"rev showing buffer.");
    self.bufferIndicator.hidden = NO;
    [self.bufferIndicator startAnimating];
}

-(void)hideBuffer {
    NSLog(@"rev hiding buffer.");
    self.bufferIndicator.hidden = YES;
    [self.bufferIndicator stopAnimating];
}

-(void)loadPost:(FRSPost *)post {
    NSLog(@"rev rev load video post: %@", post.uid);
    self.post = post;
    
    [self configureMuteIconDisplay:YES];
    
//    if(![[self urlOfCurrentlyPlayingInPlayer:_mPlayer] isEqualToString:self.post.videoUrl]){
//        // player already has the correct url. so no need to change the url/asset. just let it play.
//        [self.mPlaybackView setPlayer:nil];
//    }
    [self loadImage];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSGalleryMediaVideoCollectionViewCellLoadedPost" object:nil];

}

- (void)loadImage {
    
    //remove this after testing
//    return;
    
//    dispatch_async(dispatch_get_main_queue(), ^{
    if(!self.post.imageUrl) return;
    
    if(self.isPlaying) {
        NSLog(@"Rev This cell is playing video so not loading the image for this video cell");
        return;
    }

    NSLog(@"rev rev load imageView for video post: %@",self.post.uid);

    [self.imageView sd_setImageWithURL:[NSURL
                                        URLResizedFromURLString:self.post.imageUrl
                                        width:([UIScreen mainScreen].bounds.size.width * [[UIScreen mainScreen] scale])
                                        ]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 self.imageView.alpha = 0.0;
                                 [UIView animateWithDuration:0.3 animations:^{
                                     self.imageView.alpha = 1.0;
                                 } completion:^(BOOL finished) {
                                     
                                 }];
                             }];
    
    //});
    
}


- (void)playerItemDidReachEnd:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self.mPlayer play];
    });
}


#pragma mark -
#pragma mark Movie controller methods

#pragma mark
#pragma mark Button Action Methods

- (void)play
{
    dispatch_async( dispatch_get_main_queue(),
                   ^{
                       
                       NSLog(@"Rev video video play play: %@ \nin Cell: %@", _mPlayer, self);
                       
                       if(![[self urlOfCurrentlyPlayingInPlayer:_mPlayer] isEqualToString:self.post.videoUrl]){
                           // player already has the correct url. so no need to change the url/asset. just let it play.
                           [self setURL:[NSURL URLWithString:self.post.videoUrl]];
                       }
                       else {
                           //remove image.
                           [self removeImage];
                       
                           /* If we are at the end of the movie, we must seek to the beginning first
                            before starting playback. */
                           if (YES == seekToZeroBeforePlay)
                           {
                               seekToZeroBeforePlay = NO;
                               [self.mPlayer seekToTime:kCMTimeZero];
                           }
                           
                           [self.mPlayer play];
                           
                           NSLog(@"Mute every video that starts playing.");
                           [self mute:YES];
                       }
                   });
    
}

- (void)pause
{
    NSLog(@"Rev video video pause pause");
    [self bringSubviewToFront:self.imageView];
    [self.mPlayer pause];
    
    //    [self showPlayButton];
}


//-(void)tap {
//    NSLog(@"Rev video video mute mute pause pause");
////    [self.mPlayer pause];
//
//    self.mPlayer.muted = !self.mPlayer.muted;
//
//}
//
#pragma mark - Mute

-(void)mute:(BOOL)mute {
    self.mPlayer.muted = mute;
}

-(void)restart {
    
}

-(void)tapped {
    if([self isPlaying]) {
        NSLog(@"Rev new video mute Unmute");
        
        self.mPlayer.muted = !self.mPlayer.muted;
        [self configureMuteIconDisplay:self.mPlayer.muted];
    }
}

-(void)configureMuteIconDisplay:(BOOL)display {
    if([self.delegate respondsToSelector:@selector(mediaShouldShowMuteIcon:)]) {
        [self.delegate mediaShouldShowMuteIcon:display];
    }
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


#pragma mark Asset URL

- (void)setURL:(NSURL*)URL
{
    if (mURL != URL)
    {
        mURL = [URL copy];
        
        /*
         Create an asset for inspection of a resource referenced by a given URL.
         Load the values for the asset key "playable".
         */
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mURL options:nil];
        
        NSArray *requestedKeys = @[@"playable"];
        
        /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
//        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
//         ^{
//             dispatch_async( dispatch_get_main_queue(),
//                            ^{
                                /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                                [self prepareToPlayAsset:asset withKeys:requestedKeys];
//                            });
//         }];
    }
}

-(void)removeImage {
    NSLog(@"Rev removing image from video cell.");
    self.imageView.alpha = 1.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.imageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (NSURL*)URL
{
    return mURL;
}

- (void)dealloc
{
    [self removePlayerTimeObserver];
    
    [self.mPlayer removeObserver:self forKeyPath:@"rate"];
    [_mPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    
    [self.mPlayer pause];
}


@end



@implementation FRSGalleryMediaVideoCollectionViewCell (Player)

#pragma mark Player Item

- (BOOL)isPlaying
{
    return [self.mPlayer rate] != 0.f;
}

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    /* After the movie has played to its end time, seek back to time zero
     to play it again. */
    seekToZeroBeforePlay = YES;
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [self.mPlayer currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}


/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
    if (mTimeObserver)
    {
        [self.mPlayer removeTimeObserver:mTimeObserver];
        mTimeObserver = nil;
    }
}


#pragma mark -
#pragma mark Loading the Asset Keys Asynchronously

#pragma mark -
#pragma mark Error Handling - Preparing Assets for Playback Failed

/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 **
 **  1) values of asset keys did not load successfully,
 **  2) the asset keys did load successfully, but the asset is not
 **     playable
 **  3) the item did not become ready to play.
 ** ----------------------------------------------------------- */

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    //    [self syncScrubber];
    //    [self disableScrubber];
    //    [self disablePlayerButtons];
    
    /* Display the error. */
    NSLog(@"error::: %@", [error localizedDescription]);
    
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
    //                                                        message:[error localizedFailureReason]
    //                                                       delegate:nil
    //                                              cancelButtonTitle:@"OK"
    //                                              otherButtonTitles:nil];
    //    [alertView show];
}


#pragma mark Prepare to play asset, URL

/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    }
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    /* At this point we're ready to set up for playback of the asset. */
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.mPlayerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [self.mPlayerItem removeObserver:self forKeyPath:@"status"];
        [self.mPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.mPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [self.mPlayerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.mPlayerItem];
    }
    
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.mPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.mPlayerItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];

    /* Add observers for playerItem for setting up loader */
    [self.mPlayerItem addObserver:self
                       forKeyPath:@"playbackBufferEmpty"
                          options:NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerBufferObservationContext];

    [self.mPlayerItem addObserver:self
                       forKeyPath:@"playbackLikelyToKeepUp"
                          options:NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerBufferObservationContext];

    [self.mPlayerItem addObserver:self
                       forKeyPath:@"playbackBufferFull"
                          options:NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerBufferObservationContext];

    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.mPlayerItem];
    
    seekToZeroBeforePlay = NO;
    
    /* Create new player, if we don't already have one. */
    if (!self.mPlayer)
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlayer:[FRSPlayer playerWithPlayerItem:self.mPlayerItem]];
        
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [self.player addObserver:self
                      forKeyPath:@"currentItem"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self
                      forKeyPath:@"rate"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.mPlayerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur
         
         If needed, configure player item here (example: adding outputs, setting text style rules,
         selecting media options) before associating it with a player
         */
        [self.mPlayer replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        
        //        [self syncPlayPauseButtons];
    }
    
    //    [self.mScrubber setValue:0.0];
}

#pragma mark - Asset Key Value Observing

#pragma mark Key Value Observer for player rate, currentItem, player item status

/* ---------------------------------------------------------
 **  Called when the value at the specified key path relative
 **  to the given object has changed.
 **  Adjust the movie play and pause button controls when the
 **  player item "status" value changes. Update the movie
 **  scrubber control when the player item is ready to play.
 **  Adjust the movie scrubber control when the player item
 **  "rate" value changes. For updates of the player
 **  "currentItem" property, set the AVPlayer for which the
 **  player layer displays visual output.
 **  NOTE: this method is invoked on the main queue.
 ** ------------------------------------------------------- */

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* AVPlayerItem "status" property value observer. */
    if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext)
    {
        //        [self syncPlayPauseButtons];
        
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerItemStatusUnknown:
            {
                [self removePlayerTimeObserver];
                //                [self syncScrubber];
                
                //                [self disableScrubber];
                //                [self disablePlayerButtons];
            }
                break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                //                [self initScrubberTimer];
                
                //                [self enableScrubber];
                //                [self enablePlayerButtons];
                NSLog(@"Rev Ready to play item.....");
                if(self.imageView.alpha == 1.0) {
                    [self play];
                }
            }
                break;
                
            case AVPlayerItemStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
    }
    /* AVPlayer "rate" property value observer. */
    else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext)
    {
        //        [self syncPlayPauseButtons];
    }
    /* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
    else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
            //            [self disablePlayerButtons];
            //            [self disableScrubber];
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [self.mPlaybackView setPlayer:_mPlayer];
            
            //            [self setViewDisplayName];
            
            /* Specifies that the player should preserve the video’s aspect ratio and
             fit the video within the layer’s bounds. */
            [self.mPlaybackView setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
            
            //            [self syncPlayPauseButtons];
            
            NSLog(@"Rev set new player complete..... can send image to back");
            //remove image.
//            [self removeImage];
        }
    }
    else if (context == AVPlayerDemoPlaybackViewControllerBufferObservationContext) {
        if ([object isKindOfClass:[AVPlayerItem class]]) {
            if ([path isEqualToString:@"playbackBufferEmpty"]) {
                // Show loader
                [self showBuffer];
            }
            else if ([path isEqualToString:@"playbackLikelyToKeepUp"]) {
                // Hide loader
                [self hideBuffer];
            }
            else if ([path isEqualToString:@"playbackBufferFull"]) {
                // Hide loader
                [self hideBuffer];
            }
        }
        
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}



@end
