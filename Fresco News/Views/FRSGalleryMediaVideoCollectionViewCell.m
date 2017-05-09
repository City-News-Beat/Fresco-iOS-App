//
//  FRSGalleryMediaVideoCollectionViewCell.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 4/13/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryMediaVideoCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "NSURL+Fresco.h"
#import "FRSPost.h"

@interface FRSGalleryMediaVideoCollectionViewCell (Player)
- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)playerItemDidReachEnd:(NSNotification *)notification;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
- (void)removeObserversForPlayerItem;
@end

@interface FRSGalleryMediaVideoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *bufferIndicator;

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
    NSLog(@"prepare the video player to be reusable here.");
    [self.imageView sd_cancelCurrentImageLoad];
    self.imageView.image = nil;
    self.imageView.alpha = 1.0;
    [self.mPlaybackView setPlayer:nil];
    self.post = nil;
    [self hideBufferIndicator];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    // Configure Buffer
    [self configureBufferIndicator];
    
    [self setPlayer:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self addGestureRecognizer:tap];
    
}

#pragma mark Buffer

- (void)configureBufferIndicator {
    self.bufferIndicator = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.bufferIndicator.frame = CGRectMake(16, 16, 20, 20);
    self.bufferIndicator.tintColor = [UIColor whiteColor];
    [self.bufferIndicator setPullProgress:90];
    
    self.bufferIndicator.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bufferIndicator.layer.shadowOffset = CGSizeMake(0, 2);
    self.bufferIndicator.layer.shadowOpacity = 0.15;
    self.bufferIndicator.layer.shadowRadius = 1.5;
    self.bufferIndicator.layer.shouldRasterize = YES;
    self.bufferIndicator.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

-(void)showBufferIndicator {
    NSLog(@"showing buffer.");
    self.bufferIndicator.frame = CGRectMake(16, 16, 20, 20);
    [self addSubview:self.bufferIndicator];
    [self.bufferIndicator startAnimating];
}

-(void)hideBufferIndicator {
    NSLog(@"hiding buffer.");
    [self.bufferIndicator removeFromSuperview];
    [self.bufferIndicator stopLoading];
}

#pragma mark Load Info

-(void)loadPost:(FRSPost *)post {
    NSLog(@"rev load video post: %@", post.uid);
    self.post = post;
    
    [self configureMuteIconDisplay:YES];
    
    [self loadImage];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FRSGalleryMediaVideoCollectionViewCellLoadedPost object:nil];
    
}

- (void)loadImage {
    
    if(!self.post.imageUrl) return;
    
    if(self.isPlaying) {
        NSLog(@"This cell is playing video so not loading the image for this video cell");
        return;
    }
    
    NSLog(@"rev load imageView for video post: %@",self.post.uid);
    
    [self.imageView sd_setImageWithURL:[NSURL
                                        URLResizedFromURLString:self.post.imageUrl
                                        width:([UIScreen mainScreen].bounds.size.width * [[UIScreen mainScreen] scale])
                                        ]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 
                                 if(![self isPlaying])
                                     self.imageView.alpha = 1.0;

                             }];
    
    
}

#pragma mark Key Action Methods

- (void)play
{
    //We can remove the dispatch block if Profile VC and Story VC also calls play/pause from the main thread.
    __weak typeof(self) weakSelf = self;

    dispatch_async( dispatch_get_main_queue(),
                   ^{
                       
                       NSLog(@"video video play play: %@ \nin Cell: %@", _mPlayer, weakSelf);
                       
                       if(![[weakSelf urlOfCurrentPlayer:_mPlayer] isEqualToString:weakSelf.post.videoUrl]) {
                           //Player needs to change its URL. can show buffer now.
                           [weakSelf showBufferIndicator];
                           [weakSelf setURL:[NSURL URLWithString:weakSelf.post.videoUrl]];
                       }
                       else {
                           // player already has the correct url. so no need to change the url/asset. just let it play.
                           //remove image.
                           [weakSelf removeImage];
                           
                           [weakSelf hideBufferIndicator];
                           
                           if(!weakSelf.mPlaybackView.player) {
                               [weakSelf.mPlaybackView setPlayer:_mPlayer];
                           }
                           /* If we are at the end of the movie, we must seek to the beginning first
                            before starting playback. */
                           if (YES == seekToZeroBeforePlay)
                           {
                               seekToZeroBeforePlay = NO;
                               [weakSelf.mPlayer seekToTime:kCMTimeZero];
                           }
                           
                           [weakSelf.mPlayer play];
                           
                           NSLog(@"Mute every video that starts playing.");
                           [weakSelf mute:YES];
                       }
                   });
    
}

- (void)pause
{
    //We can remove the dispatch block if Profile VC and Story VC also calls pause from the main thread.
    __weak typeof(self) weakSelf = self;
    dispatch_async( dispatch_get_main_queue(),
                   ^{
                       NSLog(@"video video pause pause");
                       [weakSelf bringSubviewToFront:weakSelf.imageView];
                       [weakSelf.mPlayer pause];
                   });
}

- (void)offScreen {
    [self pause];
}

-(void)mute:(BOOL)mute {
    self.mPlayer.muted = mute;
}

-(void)tapped {
    if([self isPlaying]) {
        NSLog(@"new video mute Unmute");
        
        self.mPlayer.muted = !self.mPlayer.muted;
        [self configureMuteIconDisplay:self.mPlayer.muted];
    }
}

-(void)configureMuteIconDisplay:(BOOL)display {
    if([self.delegate respondsToSelector:@selector(mediaShouldShowMuteIcon:)]) {
        [self.delegate mediaShouldShowMuteIcon:display];
    }
}

-(NSString *)urlOfCurrentPlayer:(AVPlayer *)player{
    // get current asset
    AVAsset *currentPlayerAsset = player.currentItem.asset;
    // make sure the current asset is an AVURLAsset
    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) return nil;
    
    NSString *urlString = [[(AVURLAsset *)currentPlayerAsset URL] absoluteString];
    NSLog(@"urlString of current video player: %@", urlString);
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
        
        [self prepareToPlayAsset:asset withKeys:requestedKeys];
        
    }
}

-(void)removeImage {
    NSLog(@"removing image from video cell.");
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
    //playback view
    self.mPlaybackView.player = nil;
    self.mPlaybackView = nil;
    
    //player
    [self.mPlayer pause];
    [self.mPlayer.currentItem cancelPendingSeeks];
    [self.mPlayer.currentItem.asset cancelLoading];
    [self.mPlayer removeObserver:self forKeyPath:@"rate"];
    [self.mPlayer removeObserver:self forKeyPath:@"currentItem"];
    self.mPlayer = nil;
    
    //player item
    [self removeObserversForPlayerItem];
    self.mPlayerItem = nil;
    
    self.imageView.image = nil;
    self.post = nil;
}

@end

#pragma mark - Player Item

@implementation FRSGalleryMediaVideoCollectionViewCell (Player)

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

/* Get the duration for a AVPlayerItem. */
- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [self.mPlayer currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}

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
    /* Display the error. */
    NSLog(@"Unable to play. The item did not become ready to play. Error::: %@", [error localizedDescription]);
    
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
        [self removeObserversForPlayerItem];
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
        
    }
}

#pragma mark Asset Key Value Observing

//Key Value Observer for player rate, currentItem, player item status

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

            }
                break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                NSLog(@"Ready to play item.....");
                if(self.imageView.alpha == 1) {
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

        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [self.mPlaybackView setPlayer:_mPlayer];
            
            /* Specifies that the player should preserve the video’s aspect ratio and
             fit the video within the layer’s bounds. */
            [self.mPlaybackView setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
        }
    }
    else if (context == AVPlayerDemoPlaybackViewControllerBufferObservationContext) {
        if ([object isKindOfClass:[AVPlayerItem class]]) {
            if ([path isEqualToString:@"playbackBufferEmpty"]) {
                // Show loader
                [self showBufferIndicator];
            }
            else if ([path isEqualToString:@"playbackLikelyToKeepUp"]) {
                // Hide loader
                [self hideBufferIndicator];
            }
            else if ([path isEqualToString:@"playbackBufferFull"]) {
                // Hide loader
                [self hideBufferIndicator];
            }
        }
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}

- (void)removeObserversForPlayerItem {
    [self.mPlayerItem removeObserver:self forKeyPath:@"status"];
    [self.mPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.mPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.mPlayerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.mPlayerItem];
}

@end
