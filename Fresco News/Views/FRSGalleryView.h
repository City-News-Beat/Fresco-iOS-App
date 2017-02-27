//
//  FRSGalleryView.h
//  Fresco
//
//  Created by Daniel Sun on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabel+Custom.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FRSPlayer.h"
#import "FRSGalleryFooterView.h"
#import "FRSActionBar.h"

@class FRSGallery;

@protocol FRSGalleryViewDelegate <NSObject>
- (BOOL)shouldHaveActionBar;
- (BOOL)shouldHaveTextLimit;
- (void)playerWillPlay:(FRSPlayer *)player;
@property (weak, nonatomic) UINavigationController *navigationController;
@end

@interface FRSGalleryView : UIView

@property (weak, nonatomic) NSObject<FRSGalleryViewDelegate> *delegate;
@property (nonatomic) BOOL hasTapped;

@property (strong, nonatomic) FRSGallery *gallery;
@property (strong, nonatomic) ShareSheetBlock shareBlock;
@property (strong, nonatomic) ShareSheetBlock readMoreBlock;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) FRSActionBar *actionBar;
@property (strong, nonatomic) UILabel *captionLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *profileIV;
@property (strong, nonatomic) UIImageView *locationIV;
@property (strong, nonatomic) UIImageView *clockIV;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) NSArray *orderedPosts;
@property (nonatomic) NSInteger adjustedPage;
@property (strong, nonatomic) UIImageView *parallaxImage;
@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) FRSPlayer *videoPlayer;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic, retain) NSMutableArray *players;
@property (strong, nonatomic) FRSGalleryFooterView *galleryFooterView;

- (void)playerTap:(UITapGestureRecognizer *)tap;
- (instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery delegate:(id<FRSGalleryViewDelegate>)delegate;
- (void)configureWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery delegate:(id<FRSGalleryViewDelegate>)delegate;
- (void)loadGallery:(FRSGallery *)gallery;
- (void)play;
- (void)pause;
- (void)offScreen;
- (void)adjustHeight;

@end
