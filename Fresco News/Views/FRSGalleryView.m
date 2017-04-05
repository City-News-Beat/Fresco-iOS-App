//
//  FRSGalleryView.m
//  Fresco
//
//  Created by Daniel Sun on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSGalleryView.h"
#import "FRSGallery.h"
#import "FRSPost.h"
#import "UIColor+Fresco.h"
#import "UIView+Helpers.h"
#import "UIFont+Fresco.h"
#import "NSURL+Fresco.h"
#import "FRSDateFormatter.h"
#import "FRSScrollViewImageView.h"
#import <Haneke/Haneke.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "OEParallax.h"
#import "FRSUser+CoreDataProperties.h"
#import "FRSProfileViewController.h"
#import "FRSAlertView.h"
#import "FRSDualUserListViewController.h"
#import "FRSUserManager.h"
#import "FRSGalleryDetailView.h"
#import "FRSGalleryManager.h"
#import "FRSActionBar.h"

#define TEXTVIEW_TOP_PAD 12
#define LABEL_HEIGHT 20
#define LABEL_PADDING 8
#define CAPTION_PADDING 24

@interface FRSGalleryView () <UIScrollViewDelegate, UITextViewDelegate, FRSGalleryFooterViewDelegate, FRSActionBarDelegate>
@property (nonatomic, retain) UIView *topLine;
@property (nonatomic, retain) UIView *bottomLine;
@property (nonatomic, retain) UIView *borderLine;
@property (strong, nonatomic) UIImageView *muteImageView;
@property (strong, nonatomic) UIImageView *repostImageView;
@property (strong, nonatomic) UILabel *repostLabel;
@property (strong, nonatomic) NSMutableArray *playerLayers;
@property BOOL playerHasFocus;
@property BOOL isVideo;

@property (strong, nonatomic) FRSActionBar *actionBar;

@end

@implementation FRSGalleryView

- (void)loadGallery:(FRSGallery *)gallery {

    self.gallery = gallery;

    _hasTapped = FALSE;

    for (FRSPlayer *player in self.players) {
        if ([[player class] isSubclassOfClass:[FRSPlayer class]]) {
            [player.currentItem cancelPendingSeeks];
            [player.currentItem.asset cancelLoading];
        }
    }

    for (AVPlayerLayer *layer in self.playerLayers) {
        [layer removeFromSuperlayer];
    }

    for (UIImageView *imageView in self.imageViews) {
        imageView.image = Nil;
    }

    self.players = Nil;
    self.videoPlayer = Nil;
    self.playerLayers = Nil;

    self.gallery = gallery;

    self.players = [[NSMutableArray alloc] init];
    self.playerLayers = [[NSMutableArray alloc] init];

    self.clipsToBounds = NO;
    self.gallery = gallery;
    self.orderedPosts = [gallery.posts allObjects];
    self.orderedPosts = [self.orderedPosts sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:TRUE] ]];

    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, [self imageViewHeight]);
    self.scrollView.contentSize = CGSizeMake(self.gallery.posts.count * self.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.clipsToBounds = YES;
    [self.actionBar updateSocialButtonsFromButton:nil];

    self.pageControl.numberOfPages = self.gallery.posts.count;
    [self.pageControl setCurrentPage:0];
    [self.pageControl sizeToFit];

    self.pageControl.frame = CGRectMake(self.frame.size.width - ((self.gallery.posts.count) * 16) - 16, self.scrollView.frame.size.height - 15 - 8, (self.gallery.posts.count) * 16, 8);

    [self updateUser];

    self.topLine.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, 0.5);
    self.bottomLine.frame = CGRectMake(0, self.scrollView.frame.size.height - 0.5, self.scrollView.frame.size.width, 0.5);
    self.clockIV.center = self.pageControl.center;

    self.clockIV.frame = CGRectMake(21, self.clockIV.frame.origin.y, 16, 16);
    [self.locationIV setOriginWithPoint:CGPointMake(self.locationIV.frame.origin.x, self.clockIV.frame.origin.y - self.locationIV.frame.size.height - 6)];

    // RIGHT HUR
    [self.profileIV setOriginWithPoint:CGPointMake(self.profileIV.frame.origin.x, self.locationIV.frame.origin.y - self.profileIV.frame.size.height - 6)];
    [self.profileIV setContentMode:UIViewContentModeScaleAspectFill];

    self.captionLabel.text = self.gallery.caption;

    if ([self.delegate shouldHaveTextLimit]) {
        self.captionLabel.numberOfLines = 6;
    } else {
        self.captionLabel.numberOfLines = 0;
    }

    [self.captionLabel sizeToFit];

    [self.captionLabel setFrame:CGRectMake(16, [self imageViewHeight] + TEXTVIEW_TOP_PAD, self.scrollView.frame.size.width - 32, self.captionLabel.frame.size.height)];

    self.timeLabel.center = self.clockIV.center;
    [self.timeLabel setOriginWithPoint:CGPointMake(self.clockIV.frame.origin.x + self.clockIV.frame.size.width + 13, self.timeLabel.frame.origin.y)];
    CGRect timeFrame = self.timeLabel.frame;
    timeFrame.size.width = 100;
    self.timeLabel.frame = timeFrame;
    self.locationLabel.center = self.locationIV.center;
    [self.locationLabel setOriginWithPoint:CGPointMake(self.timeLabel.frame.origin.x, self.locationLabel.frame.origin.y)];

    self.nameLabel.center = self.profileIV.center;
    [self.nameLabel setOriginWithPoint:CGPointMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y)];
    self.nameLabel.frame = CGRectMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y, self.frame.size.width, 30);
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y, self.frame.size.width, 30);


    [self updateScrollView];
    [self adjustHeight];

    if ([self.gallery valueForKey:@"reposted_by"] != nil && ![[self.gallery valueForKey:@"reposted_by"] isEqualToString:@""]) {
        [self configureRepostWithName:[self.gallery valueForKey:@"reposted_by"]];
    }


    [self configureActionBar];
}

- (void)updateUser {
    FRSPost *firstPost = (FRSPost *)[self.orderedPosts firstObject];

    if (firstPost.creator.profileImage != Nil && ![firstPost.creator.profileImage isEqual:[NSNull null]] && [[firstPost.creator.profileImage class] isSubclassOfClass:[NSString class]] && ![firstPost.creator.profileImage containsString:@".avatar"] && [NSURL URLWithString:firstPost.creator.profileImage].absoluteString.length > 1) {
        NSString *smallAvatar = [firstPost.creator.profileImage stringByReplacingOccurrencesOfString:@"/images" withString:@"/images/200"];
        [self.profileIV hnk_setImageFromURL:[NSURL URLWithString:smallAvatar]];

        [self.nameLabel setOriginWithPoint:CGPointMake(20, self.nameLabel.frame.origin.y)];
    } else {
        [self.profileIV setImage:Nil];
        [self.nameLabel setOriginWithPoint:CGPointMake(0, self.nameLabel.frame.origin.y)];
    }
}

- (void)updateScrollView {
    if (self.scrollView.contentOffset.x >= 0) {
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:NO];
        [self scrollViewDidScroll:self.scrollView];
    }

    for (UIImageView *imageView in self.imageViews) {
        [imageView setImage:Nil];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      [self configureImageViews];
    });
}

- (instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery delegate:(id<FRSGalleryViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        self.gallery = gallery;
        NSMutableArray *posts = [[NSMutableArray alloc] init];

        for (FRSPost *post in self.gallery.posts) {
            [posts addObject:post];
        }

        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES];
        [posts sortUsingDescriptors:[NSArray arrayWithObject:sort]];

        self.orderedPosts = posts;
        self.orderedPosts = [self.orderedPosts sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:FALSE] ]];

        [self configureUI];
    }
    return self;
}

- (void)configureWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery delegate:(id<FRSGalleryViewDelegate>)delegate {
    [self setFrame:frame];

    self.delegate = delegate;
    self.gallery = gallery;
    NSMutableArray *posts = [[NSMutableArray alloc] init];

    for (FRSPost *post in self.gallery.posts) {
        [posts addObject:post];
    }

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES];
    [posts sortUsingDescriptors:[NSArray arrayWithObject:sort]];

    self.orderedPosts = posts;
    self.orderedPosts = [self.orderedPosts sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:FALSE] ]];

    [self configureUI];
    [self.actionBar updateSocialButtonsFromButton:nil]; // Called in the expanded VC
}

- (void)contentTap:(UITapGestureRecognizer *)sender {
    //NSLog(@"TAP");
}

- (void)configureUI {
    self.backgroundColor = [UIColor frescoBackgroundColorLight];

    [self configureScrollView]; //
    dispatch_async(dispatch_get_main_queue(), ^{
      [self configureImageViews];
    });
    // these three will be wrapped in carousel
    [self configurePageControl]; //

    [self configureGalleryInfo]; // this will stay similar

    [self configureCaptionLabel]; // this will stay similar

    [self configureActionBar]; // this will stay similar

    
    // check if highlighted_at is <= now and if it's not null
    if ([self.gallery.highlightedDate compare:[NSDate date]] && [[self.delegate class] isEqual:[FRSGalleryDetailView class]]) {
        if (![self.gallery.creator.uid isEqualToString:@""] && [self.gallery.creator.uid length] > 0) {
            [self configureBaseMetaData];
        }
    }

    [self adjustHeight]; // this will stay similar, but called every time we change our represented gallery
}

- (void)configureScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [self imageViewHeight])];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.gallery.posts.count * self.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.delaysContentTouches = FALSE;
    [self addSubview:self.scrollView];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerTap:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.cancelsTouchesInView = FALSE;
    [self addGestureRecognizer:tapGesture];
}

- (void)configureImageViews {
    self.players = [[NSMutableArray alloc] init];
    self.imageViews = [NSMutableArray new];

    [self.nameLabel sizeToFit];

    for (NSInteger i = 0; i < self.gallery.posts.count; i++) {

        FRSPost *post = self.orderedPosts[i];

        NSInteger xOrigin = i * self.frame.size.width;
        FRSScrollViewImageView *imageView = [[FRSScrollViewImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.frame.size.width, [self imageViewHeight])];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.clipsToBounds = YES;
        imageView.indexInScrollView = i;

        [self.imageViews addObject:imageView];
        [self.scrollView addSubview:imageView];

        if (i == 0) {
            [self loadImage:post.imageUrl forImageView:imageView];

            if (post.videoUrl != Nil) {
                // videof
                // set up FRSPlayer
                // add AVPlayerLayer
                dispatch_async(dispatch_get_main_queue(), ^{
                  [self.players addObject:[self setupPlayerForPost:post play:FALSE]];

                  if ([self.players[0] respondsToSelector:@selector(container)]) {
                      [self.scrollView bringSubviewToFront:[self.players[0] container]];
                  }
                });
                [self configureMuteIcon];
            } else {
                [self.players addObject:imageView];
            }
        }

        imageView.userInteractionEnabled = YES;
    }

    if (!self.topLine) {
        self.topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 0.5)];
        self.topLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:self.topLine];

        self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.size.height - 0.5, self.scrollView.frame.size.width, 0.5)];
        self.bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:self.bottomLine];
    }
}

- (void)removeFromSuperview {

    for (FRSPlayer *player in self.players) {
        if ([[player class] isSubclassOfClass:[FRSPlayer class]]) {
            [player.currentItem cancelPendingSeeks];
            [player.currentItem.asset cancelLoading];
        }
    }

    for (AVPlayerLayer *layer in self.playerLayers) {
        [layer removeFromSuperlayer];
    }

    for (UIImageView *imageView in self.imageViews) {
        imageView.image = Nil;
    }

    self.players = Nil;
    self.videoPlayer = Nil;
    self.playerLayers = Nil;

    [super removeFromSuperview];
}

- (void)dealloc {
    for (FRSPlayer *player in self.players) {
        if ([[player class] isSubclassOfClass:[FRSPlayer class]]) {
            [player.currentItem cancelPendingSeeks];
            [player.currentItem.asset cancelLoading];
        }
    }

    self.players = Nil;
    self.videoPlayer = Nil;
}

- (FRSPlayer *)setupPlayerForPost:(FRSPost *)post play:(BOOL)play {
    if (!_playerLayers) {
        _playerLayers = [[NSMutableArray alloc] init];
    }

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

    FRSPlayer *videoPlayer;

    if (!play) {
        videoPlayer = [[FRSPlayer alloc] init];
    } else {
        videoPlayer = [FRSPlayer playerWithURL:[NSURL URLWithString:post.videoUrl]];
    }

    videoPlayer.hasEstablished = play;

    dispatch_async(dispatch_get_main_queue(), ^{
      AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:videoPlayer];
      videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(playerItemDidReachEnd:)
                                                   name:AVPlayerItemDidPlayToEndTimeNotification
                                                 object:[videoPlayer currentItem]];

      NSInteger postIndex = [self.orderedPosts indexOfObject:post];

      playerLayer.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * postIndex, 0, [UIScreen mainScreen].bounds.size.width, self.scrollView.frame.size.height);
      playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
      playerLayer.backgroundColor = [UIColor clearColor].CGColor;
      playerLayer.opaque = FALSE;

      UIView *container = [[UIView alloc] initWithFrame:playerLayer.frame];
      container.backgroundColor = [UIColor clearColor];

      videoPlayer.container = container;
      playerLayer.frame = CGRectMake(0, 0, playerLayer.frame.size.width, playerLayer.frame.size.height);
      [_playerLayers addObject:playerLayer];

      if (play) {
          [container.layer insertSublayer:playerLayer atIndex:1000];
      }

      [self.scrollView addSubview:container];
      [self.scrollView bringSubviewToFront:container];

      [self configureMuteIcon];
    });

    videoPlayer.muted = TRUE;
    videoPlayer.wasMuted = FALSE;

    __weak typeof(self) weakSelf = self;

    videoPlayer.playBlock = ^(BOOL playing, FRSPlayer *player) {
      [weakSelf handlePlay:playing player:player];
    };

    return videoPlayer;
}

- (void)handlePlay:(BOOL)play player:(FRSPlayer *)player {
    //    if (play) {
    //        for (FRSPlayer *potential in self.players) {
    //            if (potential != player && [[potential class] isSubclassOfClass:[FRSPlayer class]]) {
    //                [potential pause];
    //            }
    //        }
    //
    //        if (self.delegate) {
    //            [self.delegate playerWillPlay:player];
    //        }
    //    }
}

- (void)playerTap:(UITapGestureRecognizer *)tap {
    CGPoint location = [tap locationInView:self];

    if (location.y > _scrollView.frame.size.height) {
        return;
    }

    NSInteger page = (self.scrollView.contentOffset.x + self.frame.size.width / 2) / self.scrollView.frame.size.width;
    FRSPlayer *player = self.players[page];

    if (![[player class] isSubclassOfClass:[FRSPlayer class]]) {
        return;
    }

    player.muted = FALSE;

    if (self.muteImageView.alpha == 1 && player.rate == 0.0) {
        self.muteImageView.alpha = 0;
        [player play];
        return;
    }

    if (player.muted) {
        player.muted = FALSE;
        [player play];
        return;
    } else if (self.muteImageView.alpha == 1) {
        self.muteImageView.alpha = 0;
        return;
    }

    if (player.rate == 0.0) {
        [player play];
    } else {
        [player pause];
        _hasTapped = TRUE;
    }
}

- (void)handlePhotoTap:(NSInteger)index {
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.videoPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.videoPlayer play];
}

- (void)configureMuteIcon {
    NSInteger page = (self.scrollView.contentOffset.x + self.frame.size.width / 2) / self.scrollView.frame.size.width;
    if (!self.muteImageView) {
        self.muteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mute"]];
        self.muteImageView.alpha = 0;
        [self.scrollView addSubview:self.muteImageView];
    }

    if ([self currentPageIsVideo]) {

        FRSPlayer *player = self.players[page];

        if (player.muted == FALSE) {
            return;
        }

        self.muteImageView.alpha = 1;
        self.muteImageView.frame = CGRectMake(((page + 1) * self.frame.size.width) - 24 - 16, 16, 24, 24);
        [self.scrollView bringSubviewToFront:self.muteImageView];
    }
}

- (BOOL)currentPageIsVideo {
    NSInteger page = (self.scrollView.contentOffset.x + self.frame.size.width / 2) / self.scrollView.frame.size.width;
    return (self.players.count > page && [self.players[page] respondsToSelector:@selector(pause)]);
}

- (BOOL)pageIsVideo:(NSInteger)page {
    return (self.players.count > page && [self.players[page] respondsToSelector:@selector(pause)]);
}
- (void)configurePageControl {
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = self.gallery.posts.count;
    self.pageControl.currentPage = 0;
    self.pageControl.userInteractionEnabled = NO;

    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.7];

    [self.pageControl sizeToFit];
    [self.pageControl setFrame:CGRectMake(self.scrollView.frame.size.width - 16 - self.pageControl.frame.size.width, self.scrollView.frame.size.height - 15 - 8, self.pageControl.frame.size.width, 8)];

    self.pageControl.hidesForSinglePage = YES;

    [self addSubview:self.pageControl];
}

- (void)configureGalleryInfo {
    [self configureTimeLine];
    [self configureLocationLine];
    [self configureUserLine];
    [self updateLabels];
}

- (void)configureRepostWithName:(NSString *)name {

    if (self.repostLabel == nil) {
        self.repostImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"repost-icon-white"]];
        self.repostImageView.frame = CGRectMake(16, 12, 24, 24);
        [self addSubview:self.repostImageView];

        self.repostLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 17, self.frame.size.width - 48 - 16, 17)];
        self.repostLabel.text = [name uppercaseString];
        self.repostLabel.font = [UIFont notaBoldWithSize:15];
        self.repostLabel.textColor = [UIColor whiteColor];
        [self addShadowToLabel:self.repostLabel];
        [self addSubview:self.repostLabel];

        UIButton *repostSegueButton = [[UIButton alloc] initWithFrame:CGRectMake(self.repostLabel.frame.origin.x - 60, self.repostLabel.frame.origin.y - 15, self.repostLabel.frame.size.width, self.repostLabel.frame.size.height + 30)];
        [repostSegueButton addTarget:self action:@selector(segueToSourceUser) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:repostSegueButton];
    }
}

- (void)configureTimeLine {
    self.clockIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    self.clockIV.image = [UIImage imageNamed:@"gallery-clock"];
    self.clockIV.contentMode = UIViewContentModeCenter;
    self.clockIV.center = self.pageControl.center;
    [self.clockIV setFrame:CGRectMake(21, self.clockIV.frame.origin.y, 16, 16)];

    [self addSubview:self.clockIV];

    FRSPost *post = [[self.gallery.posts allObjects] firstObject];

    self.timeLabel = [self galleryInfoLabelWithText:[FRSDateFormatter dateStringGalleryFormatFromDate:post.createdDate] fontSize:13];
    self.timeLabel.center = self.clockIV.center;
    [self.timeLabel setOriginWithPoint:CGPointMake(self.clockIV.frame.origin.x + self.clockIV.frame.size.width + 13, self.timeLabel.frame.origin.y)];

    self.timeLabel.clipsToBounds = NO;
    self.timeLabel.layer.masksToBounds = NO;

    [self addShadowToLabel:self.timeLabel];

    [self addSubview:self.timeLabel];
}

- (void)configureLocationLine {
    self.locationIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    self.locationIV.image = [UIImage imageNamed:@"gallery-pin"];
    self.locationIV.contentMode = UIViewContentModeCenter;
    self.locationIV.center = self.clockIV.center;
    [self.locationIV setOriginWithPoint:CGPointMake(self.locationIV.frame.origin.x, self.clockIV.frame.origin.y - self.locationIV.frame.size.height - 6)];
    [self addSubview:self.locationIV];

    FRSPost *post = [[self.gallery.posts allObjects] firstObject];

    self.locationLabel = [self galleryInfoLabelWithText:post.address fontSize:13];
    self.locationLabel.center = self.locationIV.center;
    [self.locationLabel setOriginWithPoint:CGPointMake(self.timeLabel.frame.origin.x, self.locationLabel.frame.origin.y)];
    self.locationLabel.clipsToBounds = NO;
    self.locationLabel.layer.masksToBounds = NO;

    [self addShadowToLabel:self.locationLabel];
    [self addSubview:self.locationLabel];
}

- (void)configureUserLine {
    self.profileIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    self.profileIV.center = self.locationIV.center;
    [self.profileIV setOriginWithPoint:CGPointMake(self.profileIV.frame.origin.x, self.locationIV.frame.origin.y - self.profileIV.frame.size.height - 6)];

    self.profileIV.layer.cornerRadius = 12;
    self.profileIV.clipsToBounds = YES;
    [self addSubview:self.profileIV];

    FRSPost *post = [[self.gallery.posts allObjects] firstObject];

    self.nameLabel = [self galleryInfoLabelWithText:[FRSPost bylineForPost:post] fontSize:17];

    self.nameLabel.center = self.profileIV.center;
    [self.nameLabel setOriginWithPoint:CGPointMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y)];
    self.nameLabel.frame = CGRectMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y, self.frame.size.width, 30);
    [self.nameLabel sizeToFit];

    //Set frame again to avoid clipping shadow
    self.nameLabel.frame = CGRectMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y, self.frame.size.width, 30);

    [self addShadowToLabel:self.nameLabel];

    self.nameLabel.layer.masksToBounds = NO;
    [self addSubview:self.nameLabel];

    if (post.creator.profileImage != Nil && ![post.creator.profileImage isEqual:[NSNull null]] && [[post.creator.profileImage class] isSubclassOfClass:[NSString class]] && ![post.creator.profileImage containsString:@".avatar"] && [NSURL URLWithString:post.creator.profileImage].absoluteString.length > 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
          //Set user image
          NSString *smallAvatar = [post.creator.profileImage stringByReplacingOccurrencesOfString:@"/images" withString:@"/images/200"];
          [self.profileIV hnk_setImageFromURL:[NSURL URLWithString:smallAvatar]];

          UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segueToUserProfile:)];
          [photoTap setNumberOfTapsRequired:1];
          [self.profileIV setUserInteractionEnabled:YES];
          [self.profileIV addGestureRecognizer:photoTap];
        });
    } else {
        [self.nameLabel setOriginWithPoint:CGPointMake(20, self.nameLabel.frame.origin.y)];
    }
    UITapGestureRecognizer *bylineTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segueToUserProfile:)];
    [bylineTap setNumberOfTapsRequired:1];
    [self.nameLabel setUserInteractionEnabled:YES];
    [self.nameLabel addGestureRecognizer:bylineTap];
}

- (void)updateLabels {
    if (self.orderedPosts.count == 0)
        return;

    FRSPost *post = self.orderedPosts[self.adjustedPage];
    
    self.nameLabel.text = [FRSPost bylineForPost:post];

    self.locationLabel.text = post.address;
    
    if ([self.locationLabel.text length] == 0) {
        self.locationLabel.text = @"No Location";
    }
    
    self.timeLabel.text = [FRSDateFormatter dateStringGalleryFormatFromDate:post.createdDate];

    self.nameLabel.numberOfLines = 1;
    [self.nameLabel sizeToFit];
    self.nameLabel.center = self.profileIV.center;
    [self.nameLabel setOriginWithPoint:CGPointMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y)];

    self.locationLabel.center = self.locationIV.center;
    [self.locationLabel setOriginWithPoint:CGPointMake(self.timeLabel.frame.origin.x, self.locationLabel.frame.origin.y)];
    [self.timeLabel sizeToFit];

    self.timeLabel.center = self.clockIV.center;
    [self.timeLabel setOriginWithPoint:CGPointMake(self.clockIV.frame.origin.x + self.clockIV.frame.size.width + 13, self.timeLabel.frame.origin.y)];
    CGRect timeFrame = self.timeLabel.frame;
    timeFrame.size.width = 100;
    self.timeLabel.frame = timeFrame;
    if (post.creator.profileImage != Nil && ![post.creator.profileImage isEqual:[NSNull null]] && [[post.creator.profileImage class] isSubclassOfClass:[NSString class]] && ![post.creator.profileImage containsString:@".avatar"] && [NSURL URLWithString:post.creator.profileImage].absoluteString.length > 1) {

        dispatch_async(dispatch_get_main_queue(), ^{
          NSString *smallAvatar = [post.creator.profileImage stringByReplacingOccurrencesOfString:@"/images" withString:@"/images/200"];
          [self.profileIV hnk_setImageFromURL:[NSURL URLWithString:smallAvatar]];
          UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segueToUserProfile:)];
          [photoTap setNumberOfTapsRequired:1];
          [self.profileIV setUserInteractionEnabled:YES];
          [self.profileIV addGestureRecognizer:photoTap];
        });

    } else {
        [self.nameLabel setOriginWithPoint:CGPointMake(20, self.nameLabel.frame.origin.y)];
    }

    UITapGestureRecognizer *bylineTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segueToUserProfile:)];
    [bylineTap setNumberOfTapsRequired:1];
    [self.nameLabel setUserInteractionEnabled:YES];
    [self.nameLabel addGestureRecognizer:bylineTap];

    [self addShadowToLabel:self.nameLabel];
    [self addShadowToLabel:self.locationLabel];
    [self addShadowToLabel:self.timeLabel];
}

- (void)addShadowToLabel:(UILabel *)label {
    if (!label.text) {
        return;
    }

    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:label.text];
    NSRange range = NSMakeRange(0, [attString length]);

    [attString addAttribute:NSFontAttributeName value:label.font range:range];
    [attString addAttribute:NSForegroundColorAttributeName value:label.textColor range:range];

    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithWhite:0 alpha:0.2];
    shadow.shadowOffset = CGSizeMake(0, 1.5);
    shadow.shadowBlurRadius = 2;
    [attString addAttribute:NSShadowAttributeName value:shadow range:range];

    label.attributedText = attString;

    label.clipsToBounds = NO;
    label.layer.masksToBounds = NO;
}

- (UILabel *)galleryInfoLabelWithText:(NSString *)text fontSize:(NSInteger)fontSize {

    UILabel *label = [UILabel new];
    label.clipsToBounds = NO;
    label.layer.masksToBounds = NO;

    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.font = fontSize == 13 ? [UIFont notaRegularWithSize:13] : [UIFont notaMediumWithSize:17];
    label.layer.shouldRasterize = TRUE;
    label.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    label.adjustsFontSizeToFitWidth = YES;
    label.numberOfLines = 1;

    CGRect labelFrame = label.frame;
    labelFrame.size.height = 20;
    labelFrame.size.width = [UIScreen mainScreen].bounds.size.width;
    label.frame = labelFrame;
    return label;
}

- (void)configureCaptionLabel {
    self.captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, self.scrollView.frame.size.height, self.scrollView.frame.size.width - 32, 0)];
    self.captionLabel.textColor = [UIColor frescoDarkTextColor];
    self.captionLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.captionLabel.text = self.gallery.caption;

    if ([self.delegate shouldHaveTextLimit]) {
        self.captionLabel.numberOfLines = 6;
    } else {
        self.captionLabel.numberOfLines = 0;
    }

    [self.captionLabel sizeToFit];

    [self.captionLabel setFrame:CGRectMake(16, self.scrollView.frame.size.height + TEXTVIEW_TOP_PAD, self.scrollView.frame.size.width - 32, self.captionLabel.frame.size.height)];

    [self addSubview:self.captionLabel];
}

- (void)adjustHeight {
    NSInteger height = [self imageViewHeight] + self.captionLabel.frame.size.height + TEXTVIEW_TOP_PAD * 2 + self.actionBar.frame.size.height;

    if (self.galleryFooterView) {
        height += self.galleryFooterView.frame.size.height + CAPTION_PADDING;
    }

    if ([self.delegate shouldHaveActionBar]) {
        height -= TEXTVIEW_TOP_PAD;
    }

    [self setSizeWithSize:CGSizeMake(self.frame.size.width, height)];
}

#pragma mark ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // We add half a screen's width so that the image loading occurs half way through the scroll.
    [self pause];

    if (!self.players) {
        self.players = [[NSMutableArray alloc] init];
    }

    NSInteger page = (scrollView.contentOffset.x + self.frame.size.width / 2) / self.scrollView.frame.size.width;

    if (page < 0) {
        return;
    }

    UIImageView *imageView;
    FRSPost *post;
    imageView = (self.imageViews.count > page) ? self.imageViews[page] : Nil;
    post = (self.orderedPosts.count > page) ? self.orderedPosts[page] : Nil;

    [self loadImage:post.imageUrl forImageView:imageView];
    [self handlePlay:TRUE player:Nil];

    if (self.players.count <= page) {
        if (post.videoUrl != Nil && page >= self.players.count) {
            FRSPlayer *player = [self setupPlayerForPost:post play:TRUE];
            [self.players addObject:player];
            [self.videoPlayer play];
        } else if (post.videoUrl == Nil || [post.videoUrl isEqual:[NSNull null]] || !post.videoUrl) {
            if (self.players && imageView) {
                [self.players addObject:imageView];
            }
        } else if (self.players.count > page && [self.players[page] respondsToSelector:@selector(play)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
              FRSPlayer *player = (FRSPlayer *)self.players[page];
              if ([player respondsToSelector:@selector(play)] && player.rate == 0.0 && player != self.videoPlayer) {
                  self.videoPlayer = player;
                  [player play];
              } else if ([player respondsToSelector:@selector(play)] && player.rate != 0.0) {
                  [player pause];
              }
            });
        }
    }

    if (self.imageViews.count > page + 1 && self.orderedPosts.count > page + 1) {

        UIImageView *nextImage = self.imageViews[page + 1];
        FRSPost *nextPost = self.orderedPosts[page + 1];

        if (nextPost.videoUrl == Nil) {
            [self loadImage:nextPost.imageUrl forImageView:nextImage];
        }
    }

    self.adjustedPage = page;

    if (page >= self.gallery.posts.count) {
        return;
    }

    if (page >= self.players.count) {
        return;
    }

    if (page != self.pageControl.currentPage) {
        [self.videoPlayer pause];
    }
    [self updateLabels];

    if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > ((self.gallery.posts.count - 1) * self.scrollView.frame.size.width))
        return;

    if (self.imageViews.count == 0 || self.imageViews.count < page || self.orderedPosts.count < page) {
        return;
    }

    NSInteger halfScroll = scrollView.frame.size.width / 4;
    CGFloat amtScrolled = scrollView.contentOffset.x - (scrollView.frame.size.width * self.pageControl.currentPage);

    CGFloat percentCompleted = ABS(amtScrolled) / halfScroll;

    if (percentCompleted > 1.0 && percentCompleted < 3.0) {
        self.nameLabel.alpha = 0;
        self.locationLabel.alpha = 0;
        self.timeLabel.alpha = 0;
        self.profileIV.alpha = 0;
        self.locationIV.alpha = 0;
        self.clockIV.alpha = 0;
        self.muteImageView.alpha = 0;
        return;
    }

    if (percentCompleted > 3)
        percentCompleted -= 2;
    CGFloat absAlpha = ABS(1 - percentCompleted);

    self.nameLabel.alpha = absAlpha;
    self.locationLabel.alpha = absAlpha;
    self.timeLabel.alpha = absAlpha;
    self.profileIV.alpha = absAlpha;
    self.locationIV.alpha = absAlpha;
    self.clockIV.alpha = absAlpha;

    FRSPlayer *player = self.players[page];
    if ([[player class] isSubclassOfClass:[FRSPlayer class]] && player.muted) {
        self.muteImageView.alpha = absAlpha;
    }

    self.profileIV.image = Nil;

    FRSPost *adjustedPost = self.orderedPosts[self.adjustedPage];
    if (post.creator.profileImage != Nil && ![post.creator.profileImage isEqual:[NSNull null]] && [[post.creator.profileImage class] isSubclassOfClass:[NSString class]] && ![post.creator.profileImage containsString:@".avatar"] && [NSURL URLWithString:post.creator.profileImage].absoluteString.length > 1) {
        [self.profileIV hnk_setImageFromURL:[NSURL URLWithString:adjustedPost.creator.profileImage]];
    } else {
        [self.nameLabel setOriginWithPoint:CGPointMake(20, self.nameLabel.frame.origin.y)];
    }

    if (adjustedPost.videoUrl == nil) {
        self.muteImageView.alpha = 0;
    }
}

- (void)loadImage:(NSString *)url forImageView:(UIImageView *)imageView {
//    [imageView
//        hnk_setImageFromURL:[NSURL
//                             URLResizedFromURLString:url
//                             width:([UIScreen mainScreen].bounds.size.width * [[UIScreen mainScreen] scale])
//                             ]
//     ];
    
    [imageView setImageWithURL:[NSURL
                                URLResizedFromURLString:url
                                width:([UIScreen mainScreen].bounds.size.width * [[UIScreen mainScreen] scale])
                                ]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.videoPlayer && [keyPath isEqualToString:@"status"]) {

        if (self.videoPlayer.status == AVPlayerStatusReadyToPlay) {

        } else if (self.videoPlayer.status == AVPlayerStatusFailed) {
        }
    }
}

- (void)setupPlayer {
    [self.videoPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
}

- (void)breakDownPlayer:(AVPlayerLayer *)layer {
    if (![[layer class] isSubclassOfClass:[AVPlayerLayer class]]) {
        return;
    }

    [layer.player pause];
    [layer.player replaceCurrentItemWithPlayerItem:Nil];
    [layer removeFromSuperlayer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / self.scrollView.frame.size.width;
    self.pageControl.currentPage = page;

    self.currentPage = page;
    if (self.players.count > page) {
        self.videoPlayer = ([self.players[page] respondsToSelector:@selector(play)]) ? self.players[page] : Nil;
        [self.videoPlayer play];
    }

    [self configureMuteIcon];
}

- (NSInteger)imageViewHeight {
    NSInteger totalHeight = 0;

    for (FRSPost *post in self.gallery.posts) {
        NSInteger rawHeight = [post.meta[@"image_height"] integerValue];
        NSInteger rawWidth = [post.meta[@"image_width"] integerValue];

        if (rawHeight == 0 || rawWidth == 0) {
            totalHeight += [UIScreen mainScreen].bounds.size.width;
        } else {
            NSInteger scaledHeight = rawHeight * ([UIScreen mainScreen].bounds.size.width / rawWidth);
            totalHeight += scaledHeight;
        }
    }

    float divider = self.gallery.posts.count;
    if (divider == 0) {
        divider = 1;
    }

    NSInteger averageHeight = totalHeight / divider;

    averageHeight = MIN(averageHeight, [UIScreen mainScreen].bounds.size.width * 4 / 3);

    return averageHeight > 0 ? averageHeight : 280;
}

- (void)segueToSourceUser {
    FRSProfileViewController *userViewController = [[FRSProfileViewController alloc] initWithUser:self.gallery.sourceUser];

    if ([self.gallery.sourceUser uid] != nil) {
        [self.delegate.navigationController pushViewController:userViewController animated:YES];
    }
}

- (void)segueToUserProfile:(FRSUser *)user {

    NSInteger page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;

    if (page >= 0 && page < self.orderedPosts.count) {
        FRSPost *currentPost = self.orderedPosts[page];

        if ([self.gallery.externalSource isEqualToString:@"twitter"]) {
            NSString *twitterString = [NSString stringWithFormat:@"twitter://user?screen_name=%@", self.gallery.externalAccountName];
            NSString *twitterLink = [NSString stringWithFormat:@"https://twitter.com/%@", self.gallery.externalAccountName];
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:twitterString]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterString]];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterLink]];
            }

        } else {
            dispatch_async(dispatch_get_main_queue(), ^{

              FRSProfileViewController *userViewController = [[FRSProfileViewController alloc] initWithUser:(FRSUser *)currentPost.creator];

              if ([currentPost.creator uid] != nil) {
                  [self.delegate.navigationController pushViewController:userViewController animated:YES];
              }
            });
        }
    }
}

- (void)play {

    NSInteger page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;

    if (self.players.count > page) {
        if ([[self.players[page] class] isSubclassOfClass:[FRSPlayer class]]) {

            FRSPlayer *player = (FRSPlayer *)self.players[page];

            if ([[player class] isSubclassOfClass:[FRSPlayer class]] && !player.currentItem && _currentPage < self.orderedPosts.count) {

                if (page >= self.orderedPosts.count) {
                    return;
                }

                FRSPost *post = (FRSPost *)self.orderedPosts[page];

                [player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:post.videoUrl]]];

                if (!player.hasEstablished) {

                    dispatch_async(dispatch_get_main_queue(), ^{
                      AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                      player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
                      [[NSNotificationCenter defaultCenter] addObserver:self
                                                               selector:@selector(playerItemDidReachEnd:)
                                                                   name:AVPlayerItemDidPlayToEndTimeNotification
                                                                 object:[player currentItem]];

                      NSInteger postIndex = [self.orderedPosts indexOfObject:post];

                      playerLayer.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * postIndex, 0, [UIScreen mainScreen].bounds.size.width, self.scrollView.frame.size.height);
                      playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                      playerLayer.backgroundColor = [UIColor clearColor].CGColor;
                      playerLayer.opaque = FALSE;
                      [player.container.layer insertSublayer:playerLayer atIndex:10000];

                      if (self.playerLayers.count > page) {
                          [(AVPlayerLayer *)self.playerLayers[page] removeFromSuperlayer];
                      }

                      self.playerLayers[page] = playerLayer;
                    });

                    player.hasEstablished = TRUE;
                }

                if (self.players.count > page) {
                    [(AVPlayer *)self.players[page] play];
                    [(AVPlayer *)self.players[page] performSelector:@selector(play) withObject:Nil afterDelay:.15];
                }
            }
        }
    }
}

- (void)offScreen {
        
    for (FRSPlayer *player in self.players) {
        if ([[player class] isSubclassOfClass:[FRSPlayer class]]) {
            [player.currentItem cancelPendingSeeks];
            [player.currentItem.asset cancelLoading];

            for (CALayer *layer in player.container.layer.sublayers) {
                [layer removeFromSuperlayer];
            }

            player.hasEstablished = FALSE;
        }
    }
}

- (void)pause {
    for (AVPlayer *player in self.players) {
        if ([[player class] isSubclassOfClass:[FRSPlayer class]]) {
            [player pause];
        }
    }
}


#pragma mark - Base Meta Data Configuration

- (void)configureBaseMetaData {
    // Configure the view
    self.galleryFooterView = [[FRSGalleryFooterView alloc] initWithFrame:CGRectMake(0, self.captionLabel.frame.origin.y + self.captionLabel.frame.size.height + CAPTION_PADDING, self.frame.size.width, self.galleryFooterView.calculatedHeight) gallery:self.gallery delegate:self];
    self.galleryFooterView.delegate = self;

    // Set the height of the galleryFooterView after all the labels have been configured and add it to the subview
    [self.galleryFooterView setSizeWithSize:CGSizeMake(self.galleryFooterView.frame.size.width, self.galleryFooterView.calculatedHeight)];

    [self addSubview:self.galleryFooterView];
}

- (void)userAvatarTapped {
    FRSProfileViewController *profile = [[FRSProfileViewController alloc] initWithUser:self.gallery.creator];
    [self.delegate.navigationController pushViewController:profile animated:YES];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}


#pragma mark - Action Bar

- (void)configureActionBar {
    if ([self.delegate shouldHaveActionBar]) {
        CGFloat yPos = self.captionLabel.frame.origin.y + self.captionLabel.frame.size.height;
        if(!self.actionBar) {
            self.actionBar = [[FRSActionBar alloc] initWithOrigin:CGPointMake(0, yPos) delegate:self];
            [self.actionBar configureWithObject:self.gallery];
            self.actionBar.navigationController = self.delegate.navigationController;
            [self addSubview:self.actionBar];

        }else {
            self.actionBar.frame = CGRectMake(self.actionBar.frame.origin.x, yPos, self.actionBar.frame.size.width, self.actionBar.frame.size.height);
            [self.actionBar configureWithObject:self.gallery];
            self.actionBar.navigationController = self.delegate.navigationController;
        }
    }
}

- (void)handleActionButtonTapped:(FRSActionBar *)actionBar {
    if (self.readMoreBlock) {
        self.readMoreBlock(nil);
    }
}

-(void)setTrackedScreen:(FRSTrackedScreen)trackedScreen {
    self.actionBar.trackedScreen = trackedScreen;
}

@end
