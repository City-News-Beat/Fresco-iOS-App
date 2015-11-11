//
//  GalleryView.h
//  FrescoNews
//
//  Created by Fresco News on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;
@import AVFoundation;

@class FRSGallery, PostCollectionViewCell;

@interface GalleryView : UIView

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionPosts;

@property (weak, nonatomic) FRSGallery *gallery;


/**
 *  Sets gallery for galelry view
 *
 *  @param gallery       FRSGallery for view
 *  @param begingPlaying If the gallery view should beging playing on presentation
 */

- (void)setGallery:(FRSGallery *)gallery shouldBeginPlaying:(BOOL)begingPlaying withDynamicAspectRatio:(BOOL)dynamicAspectRatio;

/**
 *  Shared Video Player of Controller
 */

@property (nonatomic, strong) AVPlayer *sharedPlayer;

/**
 *  Shared Video Layer of Controller
 */

@property (nonatomic, strong) AVPlayerLayer *sharedLayer;

/**
 *  Shared Player Item of Controller
 */

@property (nonatomic, strong) AVPlayerItem *sharedItem;

- (void)setAspectRatio;


/**
 *  Cleans up video player, and stops playing
 */

- (void)cleanUpVideoPlayer;

/**
 *  Set up video player in passed PostCollectionViewCell
 *
 *  @param url      URL of the video
 *  @param postCell Cell to play in
 */

- (void)setUpPlayerWithUrl:(NSURL *)url cell:(PostCollectionViewCell *)postCell;

@end
