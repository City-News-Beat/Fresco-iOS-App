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

@property (weak, nonatomic) IBOutlet UICollectionView *collectionPosts;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *labelCaption;

@property (weak, nonatomic) IBOutlet UIButton *readmore;

@property (weak, nonatomic) FRSGallery *gallery;

- (void)setGallery:(FRSGallery *)gallery isInList:(BOOL)inList;

/*
** Shared Video Player of Controller
*/

@property (nonatomic, strong) AVPlayer *sharedPlayer;

/*
** Shared Video Layer of Controller
*/

@property (nonatomic, strong) AVPlayerLayer *sharedLayer;


/*
** Shared Player Item of Controller
*/

@property (nonatomic, strong) AVPlayerItem *sharedItem;

- (void)setAspectRatio;

- (void)cleanUpVideoPlayer;

- (void)setUpPlayerWithUrl:(NSURL *)url cell:(PostCollectionViewCell *)postCell;

@end
