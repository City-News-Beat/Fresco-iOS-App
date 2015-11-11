//
//  GalleryView.m
//  FrescoNews
//
//  Created by Fresco News on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//


#import "GalleryView.h"
#import "FRSGallery.h"
#import "FRSPost.h"
#import "FRSImage.h"
#import "PostCollectionViewCell.h"
#import "GalleriesViewController.h"
#import "FRSPhotoBrowserView.h"

@import Photos;

static CGFloat const kImageInitialScaleAmt = 0.9f;
static CGFloat const kImageFinalScaleAmt = 0.98f;
static CGFloat const kImageInitialYTranslation = 10.f;

@interface GalleryView () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

/**
 *  Index of cell that is currently playing a video
 */

@property (nonatomic) NSIndexPath *playingIndex;

@property (nonatomic, strong) FRSPhotoBrowserView *photoBrowserView;

@end

@implementation GalleryView

- (void)awakeFromNib
{
    self.collectionPosts.scrollsToTop = NO;
    self.pageControl.numberOfPages = 0;
}

#pragma mark - Gallery Methods

- (void)setGallery:(FRSGallery *)gallery shouldBeginPlaying:(BOOL)begingPlaying withDynamicAspectRatio:(BOOL)dynamicAspectRatio
{
    _gallery = gallery;
    
    if([self.gallery.posts count] == 1)
        self.pageControl.hidden = YES;
    else
        self.pageControl.numberOfPages = [self.gallery.posts count];
    
    [self.collectionPosts reloadData];
    [self.collectionPosts setContentOffset:CGPointZero animated:NO];
    
    if(dynamicAspectRatio)
        [self setAspectRatio];

    if(begingPlaying){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(self.collectionPosts.visibleCells.count){
                
                if(self.collectionPosts.visibleCells[0] != nil){
                    
                    PostCollectionViewCell *postCell = (PostCollectionViewCell *) self.collectionPosts.visibleCells[0];
                    
                    //If the cell has a video
                    if([postCell.post isVideo]){
                        
                        if(postCell.post.video) {
                            [self setUpPlayerWithUrl:postCell.post.video cell:postCell];
                        }
                        else if (postCell.post.image.asset.mediaType == PHAssetMediaTypeVideo){
                            
                            [[PHImageManager defaultManager] requestAVAssetForVideo:postCell.post.image.asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                
                                [self setUpPlayerWithUrl:((AVURLAsset *)asset).URL cell:postCell];
                                
                            }];
                        }
                    }
                }
            }
        });
    }
}

- (void)setAspectRatio
{
    if ([self.gallery.posts count]) {
        
        FRSPost *post = [self.gallery.posts firstObject];
        
        //370 / height ---- post.image.width / post.image.height
        
        CGFloat height = 0;

        if (post.image.height > 0 && post.image.width > 0) {
            
            //Calculate the aspect ratio from the image height / width, using proportions
            height = ([[UIScreen mainScreen] bounds].size.width * [post.image.height floatValue]) /  [post.image.width floatValue];

        }
        
        if(height > 0 && height < 400){
        
            if (self.collectionPosts.constraints)
                [self.collectionPosts removeConstraints:self.collectionPosts.constraints];
            
            [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[posts(%f)]", height]
                                                                               options:0
                                                                               metrics:nil
                                                                                 views: @{@"posts":self.collectionPosts}]];

            [self.collectionPosts updateConstraints];
            
        }
        else{
        
            if (self.collectionPosts.constraints)
                [self.collectionPosts removeConstraints:self.collectionPosts.constraints];
            
            [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[posts(400)]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views: @{@"posts":self.collectionPosts}]];
            
            [self.collectionPosts updateConstraints];
        
        }
    }
}

#pragma mark - AVPlayer

- (void)setUpPlayerWithUrl:(NSURL *)url cell:(PostCollectionViewCell *)postCell
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        //update UI in main thread.
        //Start animating the indicator
        postCell.photoIndicatorView.color = [UIColor whiteColor];
        [postCell.photoIndicatorView startAnimating];
        [UIView animateWithDuration:1.0 animations:^{
            postCell.photoIndicatorView.alpha = 1.0f;
        }];
        
    });
    
    //Cleans up the video player if playing
    [self cleanUpVideoPlayer];
    
    NSLog(@"Video Started");
    
    self.sharedPlayer = [AVPlayer playerWithURL:url];
    
    //Set up the AVPlayerItem
    [self.sharedPlayer.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    self.sharedLayer = [AVPlayerLayer playerLayerWithPlayer:self.sharedPlayer];
    
    self.sharedLayer.videoGravity  = AVLayerVideoGravityResizeAspectFill;
    
    self.sharedLayer.frame = postCell.imageView.bounds;
    
    [postCell.imageView.layer addSublayer:self.sharedLayer];
    
    self.sharedPlayer.muted = YES;
    
    self.sharedPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    //Bring play/pause button to front, so it can be visible on click
    [postCell bringSubviewToFront:postCell.playPause];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.sharedPlayer currentItem]];
    
    self.playingIndex = [self.collectionPosts indexPathForCell:postCell];
    
}

/*
** Notification listener for status of AVPlayerItem
*/

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    //Check if we have the right notif for the AVPlayer
    if ([keyPath isEqualToString:@"status"]) {
        
        //DISABLE THE UIACTIVITY INDICATOR HERE
        if (self.sharedPlayer.currentItem.status == AVPlayerStatusReadyToPlay) {
            
            [self removeObserverForPlayer];

            //Get the collection view cell of the playing item
            PostCollectionViewCell *postCell = (PostCollectionViewCell *)[self.collectionPosts cellForItemAtIndexPath:self.playingIndex];
            
            postCell.playingVideo = YES;
            
            [self.sharedPlayer play];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:1.0 animations:^{
                    
                    postCell.photoIndicatorView.alpha = 0.0f;
                    
                } completion:^(BOOL finished){
                    
                    [postCell.photoIndicatorView stopAnimating];
                    postCell.photoIndicatorView.hidden = YES;
                    
                }];
                
            });
            
        }
    }
}

/**
 *  Notification listener for when video reaches the end (tells it to repeat in a loop)
 *
 *  @param notification <#notification description#>
 */

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    [(AVPlayerItem *)[notification object] seekToTime:kCMTimeZero];
    
}


/**
 *  Cleans up notificaiton observer on the AVPlayers item
 */

- (void)removeObserverForPlayer{

    @try{
        [self.sharedPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    }
    @catch(id anException){
    
    }
   
}

- (void)cleanUpVideoPlayer{
    
    //Check if the player is actually playing
    if(self.sharedPlayer != nil){
        
        [self.sharedLayer removeFromSuperlayer];
        [self.sharedPlayer pause];
        
        @try{
            [self removeObserverForPlayer];
        }
        @catch (id anException){
        
        }
    }

}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.gallery.posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PostCollectionViewCell identifier] forIndexPath:indexPath];
    
    [cell setPost:[self.gallery.posts objectAtIndex:indexPath.item]];
        
    return cell;
}



#pragma mark - UICollectionViewDelegate


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.bounds.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PostCollectionViewCell *cell = (PostCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    //If the cell has a video
    if(cell.post.isVideo && cell.playingVideo){
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            //Check if the player is muted, then set it to play audio
            if(self.sharedPlayer.muted){
                
                self.sharedPlayer.muted = NO;
                
                [UIView animateWithDuration:.5 animations:^{
                    cell.mutedImage.alpha = 0.0f;
                }];
                
            }
            //Check if the player is playing
            else if(self.sharedPlayer.rate > 0){
                
                [self.sharedPlayer pause];
                cell.playPause.image = [UIImage imageNamed:@"pause"];
                cell.playPause.transform = CGAffineTransformMakeScale(1, 1);
                [cell bringSubviewToFront:cell.playPause];
                
                cell.playPause.alpha = 1.0f;
                
                [UIView animateWithDuration:.5 animations:^{
                    cell.playPause.alpha = 0.0f;
                    cell.playPause.transform = CGAffineTransformMakeScale(2, 2);
                }];
                
            }
            //If it's not playing
            else{
                
                [self.sharedPlayer play];
                if(cell.mutedImage.alpha == 1.0f)
                    cell.playPause.alpha = 0.0f;
                cell.playPause.image = [UIImage imageNamed:@"play"];
                cell.playPause.transform = CGAffineTransformMakeScale(1, 1);
                [cell bringSubviewToFront:cell.playPause];
                
                cell.playPause.alpha = 1.0f;
                
                [UIView animateWithDuration:.5 animations:^{
                    cell.playPause.alpha = 0.0f;
                    cell.playPause.transform = CGAffineTransformMakeScale(2, 2);
                }];
                
            }
            
        });
        
    }
    //Post is a picture, not a video
    else if(!cell.post.isVideo && [cell.post largeImageURL] != nil){
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        
        FRSPhotoBrowserView *browserView = [[FRSPhotoBrowserView alloc] initWithFrame:[window bounds]];
        [self setPhotoBrowserView:browserView];
        
        [[self photoBrowserView] setImages:@[cell.post.largeImageURL] withInitialIndex:0];
        
        [window addSubview:[self photoBrowserView]];
        [[self photoBrowserView] setAlpha:0.f];
        
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"messageSeen"]){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"messageSeen"];
            
            UILabel *textLabelView = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, window.bounds.size.width * 0.8, 100)];
            textLabelView.backgroundColor = [UIColor blackColor];
            textLabelView.alpha = .7f;
            textLabelView.layer.cornerRadius = 7;
            textLabelView.layer.masksToBounds = YES;
            
            textLabelView.text = @"Try tilting your device to reveal more of the photo in full resolution";
            textLabelView.textColor = [UIColor whiteColor];
            textLabelView.textAlignment = NSTextAlignmentCenter;
            textLabelView.numberOfLines = 0;
            
            textLabelView.font = [UIFont fontWithName:HELVETICA_NEUE_THIN size:18];
            
            double delayInSeconds = 3.0; // number of seconds to wait
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [UIView animateWithDuration:0.5
                                      delay:1.0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     textLabelView.alpha = 0;
                                 } completion:nil];
            });
            
            [[self photoBrowserView] addSubview:textLabelView];
        }
        
        CGAffineTransform transformation = CGAffineTransformMakeTranslation(0.f, kImageInitialYTranslation);
        transformation = CGAffineTransformScale(transformation, kImageInitialScaleAmt, kImageInitialScaleAmt);
        [[self photoBrowserView] setTransform:transformation];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewShouldDismiss:)];
        [[self photoBrowserView] addGestureRecognizer:tapRecognizer];
        
        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewShouldDismiss:)];
        [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
        [[self photoBrowserView] addGestureRecognizer:swipeRecognizer];
        
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [[self photoBrowserView] setAlpha:1.f];
            [[self photoBrowserView] setTransform:CGAffineTransformIdentity];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            
        } completion:nil];
        
    }
    
}

#pragma mark - Photo View Controller

- (void)photoViewShouldDismiss:(UIGestureRecognizer *)gestureRecognizer
{
    CGAffineTransform transformation = CGAffineTransformMakeTranslation(0.f, kImageInitialYTranslation);
    transformation = CGAffineTransformScale(transformation, kImageFinalScaleAmt, kImageFinalScaleAmt);
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [[self photoBrowserView] setTransform:transformation];
        [[self photoBrowserView] setAlpha:0.f];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
    } completion:^(BOOL finished) {
        [[self photoBrowserView] removeFromSuperview];
        [self setPhotoBrowserView:nil];
    }];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat pageWidth = self.collectionPosts.frame.size.width;
    self.pageControl.currentPage = self.collectionPosts.contentOffset.x / pageWidth;
    
    CGRect visibleRect = (CGRect){.origin = self.collectionPosts.contentOffset, .size = self.collectionPosts.bounds.size};
    
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    
    NSIndexPath *visibleIndexPath = [self.collectionPosts indexPathForItemAtPoint:visiblePoint];
    
    PostCollectionViewCell *postCell = (PostCollectionViewCell *) [self.collectionPosts cellForItemAtIndexPath:visibleIndexPath];
    
    if(self.gallery.galleryID){
    
        NSDictionary *dict = @{
                              @"postIndex" : [NSNumber numberWithInteger:visibleIndexPath.row],
                              @"gallery" : self.gallery.galleryID
                              };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GALLERY_HEADER_UPDATE object:dict];
        
    }
    
    //If the cell has a video
    if([postCell.post isVideo]){
        
        //If a url
        if (postCell.post.video)
            [self setUpPlayerWithUrl:postCell.post.video cell:postCell];
        //If a local asset
        else if (postCell.post.image.asset.mediaType == PHAssetMediaTypeVideo){
            
            [[PHImageManager defaultManager] requestAVAssetForVideo:postCell.post.image.asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                
                [self setUpPlayerWithUrl:((AVURLAsset *)asset).URL cell:postCell];
                
            }];
        }
    }
    //If the cell doesn't have a video
    else{
        
        [self cleanUpVideoPlayer];
        
    }
    
}



@end
