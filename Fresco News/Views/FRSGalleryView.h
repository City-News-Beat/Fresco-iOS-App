//
//  FRSGalleryView.h
//  Fresco
//
//  Created by Daniel Sun on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabel+Custom.h"
#import "Fresco.h"
#import "FRSContentActionsBar.h"
#import <AVKit/AVKit.h>

@class FRSGallery;


@protocol FRSGalleryViewDelegate <NSObject>

-(BOOL)shouldHaveActionBar;
-(BOOL)shouldHaveTextLimit;

-(BOOL)playerWillPlay;

@end

@interface FRSGalleryView : UIView

@property (weak, nonatomic) NSObject <FRSGalleryViewDelegate> *delegate;

@property (strong, nonatomic) FRSGallery *gallery;
@property (strong, nonatomic) ShareSheetBlock shareBlock;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) FRSContentActionsBar *actionBar;

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

@property (strong, nonatomic) AVPlayer *videoPlayer;

@property (nonatomic) NSInteger currentPage;
-(instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery delegate:(id <FRSGalleryViewDelegate>)delegate;
-(void)loadGallery:(FRSGallery *)gallery;

//Should probably have a resize method that adjusts the size of the entire view. Still haven't out the best way to do this.

@end
