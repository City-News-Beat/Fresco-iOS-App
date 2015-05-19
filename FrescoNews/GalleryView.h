//
//  GalleryView.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class FRSGallery;

@interface GalleryView : UIView

@property (weak, nonatomic) IBOutlet UICollectionView *collectionPosts;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *labelCaption;

@property (weak, nonatomic) FRSGallery *gallery;

/*
** Shared Video Player of Controller
*/

@property (nonatomic, strong) AVPlayer *sharedPlayer;

/*
** Shared Video Layer of Controller
*/

@property (nonatomic, strong) AVPlayerLayer *sharedLayer;


@end
