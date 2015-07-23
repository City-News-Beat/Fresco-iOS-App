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
#import "FRSPhotoBrowserView.h"

static CGFloat const kImageInitialScaleAmt = 0.9f;
static CGFloat const kImageFinalScaleAmt = 0.98f;
static CGFloat const kImageInitialYTranslation = 10.f;

@interface GalleryView () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

/*
** Index of cell that is currently playing a video
*/

@property (nonatomic) NSIndexPath *playingIndex;

@property (nonatomic, strong) FRSPhotoBrowserView *photoBrowserView;

@end

@implementation GalleryView

+ (AVPlayer *)sharedPlayer
{
    static AVPlayer *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[AVPlayer alloc] init];
    });
    return player;
}

+ (AVPlayerLayer *)sharedLayer
{
    static AVPlayerLayer *layer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        layer = [[AVPlayerLayer alloc] init];
    });
    return layer;
}


- (void)awakeFromNib
{
    self.collectionPosts.scrollsToTop = NO;
    self.collectionPosts.dataSource = self;
    self.collectionPosts.delegate = self;
    self.pageControl.numberOfPages = 0;
}

- (void)setGallery:(FRSGallery *)gallery
{
    [self setGallery:gallery isInList:NO];
}

// "list" is e.g. a table view
- (void)setGallery:(FRSGallery *)gallery isInList:(BOOL)inList
{
    _gallery = gallery;
    
    self.labelCaption.text = self.gallery.caption;
    self.labelCaption.numberOfLines = 6;
    
    if([self.gallery.posts count] == 1)
        self.pageControl.hidden = YES;
    else
        self.pageControl.numberOfPages = [self.gallery.posts count];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionPosts reloadData];
        [self.collectionPosts layoutIfNeeded];
    });
    
    if(!inList){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(self.collectionPosts.visibleCells.count){
        
                if(self.collectionPosts.visibleCells[0] != nil){
                    
                    PostCollectionViewCell *postCell = (PostCollectionViewCell *) self.collectionPosts.visibleCells[0];
                
                    //If the cell has a video
                    if([postCell.post isVideo]){
                
                        [self setUpPlayerWithUrl:postCell.post.video cell:postCell];
                
                    }
                
                    //If the cell doesn't have a video
                    else{
                
                        //If the Player is actually playing
                        if([self sharedPlayer] != nil){
                
                            //Stop the player
                
                            [[self sharedPlayer] pause];
                            
                            [[self sharedLayer] removeFromSuperlayer];
                            
                        }
                        
                    }
                    
                }
                
            }

        });
            
    }
    
    [self setAspectRatio];
    
}

- (void)setAspectRatio
{
    if ([self.gallery.posts count]) {
        
        FRSPost *post = [self.gallery.posts firstObject];
        
        CGFloat aspectRatio;
        if (post.image) {
            aspectRatio = [post.image.width floatValue] / [post.image.height floatValue];
            if (aspectRatio < 1.0f || !post.image.height /* shouldn't happen... */) {
                aspectRatio = 1.0f;
            }
        }
        else {
            aspectRatio = 600/800;
        }
        
        if (self.collectionPosts.constraints)
            [self.collectionPosts removeConstraints:self.collectionPosts.constraints];
        
        // make the aspect ratio 4:3
        [self.collectionPosts addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionPosts
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.collectionPosts
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:aspectRatio
                                                                          constant:0]];
        [self updateConstraints];
    }
}

#pragma mark - AVPlayer

/*
** Set up video player in passed PostCollectionViewCell
*/

- (void)setUpPlayerWithUrl:(NSURL *)url cell:(PostCollectionViewCell *)postCell
{
    
    [postCell.videoIndicatorView startAnimating];
    
    [UIView animateWithDuration:1.0 animations:^{
        postCell.videoIndicatorView.alpha = 1.0f;
    }];
    
    [[self sharedPlayer] pause];
    
    [[self sharedLayer] removeFromSuperlayer];
    
    self.sharedPlayer = [AVPlayer playerWithURL:url];
    
    self.sharedPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    self.sharedLayer = [AVPlayerLayer playerLayerWithPlayer:self.sharedPlayer];
    
    self.sharedLayer.videoGravity  = AVLayerVideoGravityResizeAspectFill;
    
    self.sharedLayer.frame = postCell.imageView.bounds;
    
    [self.sharedPlayer setMuted:NO];
    
    [self.sharedPlayer play];
    
    self.sharedPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;

    [postCell.imageView.layer addSublayer:self.sharedLayer];
    
    [postCell bringSubviewToFront:postCell.playPause];
    
    if (self.sharedPlayer.rate > 0 && !self.sharedPlayer.error) {
        
        // player is playing
        [UIView animateWithDuration:1.0 animations:^{
            postCell.videoIndicatorView.alpha = 0.0f;
        } completion:^(BOOL finished){
            [postCell.videoIndicatorView stopAnimating];
            postCell.videoIndicatorView.hidden = YES;
        }];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.sharedPlayer currentItem]];
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    [(AVPlayerItem *)[notification object] seekToTime:kCMTimeZero];
    
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
    
    cell.backgroundColor = [UIColor colorWithHex:[VariableStore sharedInstance].colorBackground];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [doubleTapGesture setNumberOfTouchesRequired:1];
    
    [cell addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processSingleTap:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [singleTapGesture setNumberOfTouchesRequired:1];
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    [cell addGestureRecognizer:singleTapGesture];

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

#pragma mark - UITapGesture Functions

- (void)processSingleTap:(UITapGestureRecognizer *)sender {
   
    PostCollectionViewCell *cell = (PostCollectionViewCell *)sender.view;

    //If the cell has a video
    if(cell.post.isVideo && !cell.processingVideo){
        
        if(self.sharedPlayer.rate > 0){
            
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
        else{
            
            [self.sharedPlayer play];
            cell.playPause.image = [UIImage imageNamed:@"play"];
            cell.playPause.transform = CGAffineTransformMakeScale(1, 1);
            [cell bringSubviewToFront:cell.playPause];
            
            cell.playPause.alpha = 1.0f;
            
            [UIView animateWithDuration:.5 animations:^{
                cell.playPause.alpha = 0.0f;
                cell.playPause.transform = CGAffineTransformMakeScale(2, 2);
            }];
            
        }
        
        
    }
    
}

- (void)processDoubleTap:(UITapGestureRecognizer *)sender {
    
    PostCollectionViewCell *cell = (PostCollectionViewCell *)sender.view;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    FRSPhotoBrowserView *browserView = [[FRSPhotoBrowserView alloc] initWithFrame:[window bounds]];
    [self setPhotoBrowserView:browserView];
    
    [[self photoBrowserView] setImages:@[cell.post.largeImageURL] withInitialIndex:0];
    
    [window addSubview:[self photoBrowserView]];
    [[self photoBrowserView] setAlpha:0.f];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"messageSeen"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"messageSeen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UILabel *textLabelView = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, window.bounds.size.width * 0.8, 100)];
        textLabelView.backgroundColor = [UIColor blackColor];
        textLabelView.alpha = .7f;
        textLabelView.layer.cornerRadius = 7;
        textLabelView.layer.masksToBounds = YES;
        
        textLabelView.text = @"Try tilting your device to reveal more of the photo in full resolution";
        textLabelView.textColor = [UIColor whiteColor];
        textLabelView.textAlignment = NSTextAlignmentCenter;
        textLabelView.numberOfLines = 0;
        
        textLabelView.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18];
        
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionPosts.frame.size.width;
    self.pageControl.currentPage = self.collectionPosts.contentOffset.x / pageWidth;
    
    CGRect visibleRect = (CGRect){.origin = self.collectionPosts.contentOffset, .size = self.collectionPosts.bounds.size};
    
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    
    NSIndexPath *visibleIndexPath = [self.collectionPosts indexPathForItemAtPoint:visiblePoint];
    
    PostCollectionViewCell *postCell = (PostCollectionViewCell *) [self.collectionPosts cellForItemAtIndexPath:visibleIndexPath];
    
    //If the cell has a video
    if([postCell.post isVideo]){
        
        [self setUpPlayerWithUrl:postCell.post.video cell:postCell];
    }
    //If the cell doesn't have a video
    else{
        
        //If the Player is actually playing
        if([self sharedPlayer] != nil){
            
            //Stop the player
            
            [[self sharedPlayer] pause];
            
            [[self sharedLayer] removeFromSuperlayer];
            
        }
        
    }
    
}



@end
