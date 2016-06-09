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
#import "FRSDateFormatter.h"
#import "FRSScrollViewImageView.h"
#import <Haneke/Haneke.h>
#import "OEParallax.h"
#import "FRSUser+CoreDataProperties.h"
#import "FRSProfileViewController.h"
//#import "FRSUserProfileViewController.h"


#define TEXTVIEW_TOP_PAD 12

@interface FRSGalleryView() <UIScrollViewDelegate, FRSContentActionBarDelegate, UITextViewDelegate>
@property (nonatomic, retain) UIView *topLine;
@property (nonatomic, retain) UIView *bottomLine;
@property (nonatomic, retain) UIView *borderLine;
@property (strong, nonatomic) UIImageView *muteImageView;
@property (strong, nonatomic) UIImageView *repostImageView;
@property (strong, nonatomic) UILabel *repostLabel;
@property BOOL playerHasFocus;
@property BOOL isVideo;
@end

@implementation FRSGalleryView


-(void)loadGallery:(FRSGallery *)gallery {
    
    if ([self.gallery.uid isEqualToString:gallery.uid]) {
        return;
    }
    
    for (FRSPlayer *player in self.players) {
        if ([player respondsToSelector:@selector(pause)]) {
            [player.container removeFromSuperview];
            [player pause];
            [player replaceCurrentItemWithPlayerItem:Nil];
        }
    }
    
    self.players = [[NSMutableArray alloc] init];
    
    self.clipsToBounds = NO;
    self.gallery = gallery;
    self.orderedPosts = [gallery.posts allObjects];
    self.orderedPosts = [self.orderedPosts sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:FALSE]]];
    
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, [self imageViewHeight]);
    self.scrollView.contentSize = CGSizeMake(self.gallery.posts.count * self.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.clipsToBounds = YES;
    [self updateLabels];
    
    self.pageControl.numberOfPages = self.gallery.posts.count;
    [self.pageControl setCurrentPage:0];
    [self.pageControl sizeToFit];
    
    self.pageControl.frame = CGRectMake(self.frame.size.width - ((self.gallery.posts.count) *16) - 16, self.scrollView.frame.size.height - 15 - 8, (self.gallery.posts.count) *16, 8);
    

    self.topLine.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, 0.5);
    self.bottomLine.frame = CGRectMake(0, self.scrollView.frame.size.height - 0.5, self.scrollView.frame.size.width, 0.5);
    self.clockIV.center = self.pageControl.center;
    
    self.clockIV.frame = CGRectMake(21, self.clockIV.frame.origin.y, 16, 16);
    [self.locationIV setOriginWithPoint:CGPointMake(self.locationIV.frame.origin.x, self.clockIV.frame.origin.y - self.locationIV.frame.size.height - 6)];
    [self.profileIV setOriginWithPoint:CGPointMake(self.profileIV.frame.origin.x, self.locationIV.frame.origin.y - self.profileIV.frame.size.height - 6)];
    self.captionLabel.text = self.gallery.caption;
    
    if ([self.delegate shouldHaveTextLimit]){
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

    
    [self.actionBar setOriginWithPoint:CGPointMake(0, self.captionLabel.frame.origin.y + self.captionLabel.frame.size.height)];
    [self.borderLine.superview bringSubviewToFront:self.borderLine];

    [self updateScrollView];
    [self updateSocial];
    [self adjustHeight];
    
    if (self.gallery.repostedBy != nil && ![self.gallery.repostedBy isEqualToString:@""]) {
        [self configureRepostWithName:self.gallery.repostedBy];
    }
}

-(void)updateSocial {
    NSNumber *numLikes = [self.gallery valueForKey:@"likes"];
    BOOL isLiked = [[self.gallery valueForKey:@"liked"] boolValue];
    
    NSNumber *numReposts = [self.gallery valueForKey:@"reposts"];
    BOOL isReposted = FALSE;[[self.gallery valueForKey:@"reposted"] boolValue];
    
   // NSString *repostedBy = [self.gallery valueForKey:@"repostedBy"];
    
    [self.actionBar handleHeartState:isLiked];
    [self.actionBar handleHeartAmount:[numLikes intValue]];
    [self.actionBar handleRepostState:!isReposted];
    [self.actionBar handleRepostAmount:[numReposts intValue]];
}

-(void)updateScrollView {
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

-(void)handleActionButtonTapped {
    // idk why dan made this method life is a mystery
    
    if (self.readMoreBlock) {
        self.readMoreBlock(Nil);
    }
}

-(void)contentActionbarDidSelectShareButton:(id)sender {
    // show actions sheet
    self.shareBlock(@[[@"https://fresconews.com/gallery/" stringByAppendingString:self.gallery.uid]]);
    
}

-(instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery delegate:(id <FRSGalleryViewDelegate>)delegate{
    self = [super initWithFrame:frame];
    if (self){
        self.delegate = delegate;
        self.gallery = gallery;
        NSMutableArray *posts = [[NSMutableArray alloc] init];
        
        for (FRSPost *post in self.gallery.posts) {
            [posts addObject:post];
        }
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES];
        [posts sortUsingDescriptors:[NSArray arrayWithObject:sort]];
        
        self.orderedPosts = posts;
        self.orderedPosts = [self.orderedPosts sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:FALSE]]];

        [self configureUI];
        [self updateSocial];
    }
    return self;
}

-(void)contentTap:(UITapGestureRecognizer *)sender {
    NSLog(@"TAP");
}

-(void)configureUI{
    self.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    [self configureScrollView]; //
    [self configureImageViews]; // these three will be wrapped in carousel
    [self configurePageControl];//
    
    [self configureGalleryInfo]; // this will stay similar
    
    [self configureCaptionLabel]; // this will stay similar

    [self configureActionsBar]; // this will stay similar
    
    [self adjustHeight]; // this will stay similar, but called every time we change our represented gallery
}

-(void)configureScrollView{
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

-(void)configureImageViews{
    self.players = [[NSMutableArray alloc] init];
    self.imageViews = [NSMutableArray new];
    
    [self.nameLabel sizeToFit];
    
    for (NSInteger i = 0; i < self.gallery.posts.count; i++){
            
        FRSPost *post = self.orderedPosts[i];
            
        NSInteger xOrigin = i * self.frame.size.width;
        FRSScrollViewImageView *imageView = [[FRSScrollViewImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.frame.size.width, [self imageViewHeight])];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.clipsToBounds = YES;
        imageView.indexInScrollView = i;
            
        [self.imageViews addObject:imageView];
        [self.scrollView addSubview:imageView];

            if (i==0) {
                [imageView hnk_setImageFromURL:[NSURL URLWithString:post.imageUrl]];

                if (post.videoUrl != Nil) {
                    // videof
                    // set up FRSPlayer
                    // add AVPlayerLayer
                    NSLog(@"TOP LEVEL PLAYER");
                    [self.players addObject:[self setupPlayerForPost:post]];
                    [self.scrollView bringSubviewToFront:[self.players[0] container]];
                    [self configureMuteIcon];
                }
                else {
                    [self.players addObject:imageView];
                }
            }
           
            imageView.userInteractionEnabled = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.imageViews.count > 1) {
            UIImageView *nextImage = self.imageViews[1];
            FRSPost *nextPost = self.orderedPosts[1];
            [nextImage hnk_setImageFromURL:[NSURL URLWithString:nextPost.imageUrl] placeholder:nil];
        }
    });

    if (!self.topLine) {
        self.topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 0.5)];
        self.topLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:self.topLine];
        
        self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.size.height - 0.5, self.scrollView.frame.size.width, 0.5)];
        self.bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:self.bottomLine];
    }
}

-(FRSPlayer *)setupPlayerForPost:(FRSPost *)post {
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryAmbient error:nil];

    FRSPlayer *videoPlayer = [FRSPlayer playerWithURL:[NSURL URLWithString:post.videoUrl]];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        
        UIView *container = [[UIView alloc] initWithFrame:playerLayer.frame];
        container.backgroundColor = [UIColor clearColor];
        
        videoPlayer.container = container;
        playerLayer.frame = CGRectMake(0, 0, playerLayer.frame.size.width, playerLayer.frame.size.height);
       
        dispatch_async(dispatch_get_main_queue(), ^{
            [container.layer insertSublayer:playerLayer atIndex:1000];
            [self.scrollView addSubview:container];
            [self.scrollView bringSubviewToFront:container];
            [self configureMuteIcon];
        });
        
        videoPlayer.muted = TRUE;
        videoPlayer.wasMuted = FALSE;
    });
    
    __weak typeof(self) weakSelf = self;
    
    videoPlayer.playBlock = ^(BOOL playing, FRSPlayer *player) {
        [weakSelf handlePlay:playing player:player];
    };
    
    return videoPlayer;
}

-(void)handlePlay:(BOOL)play player:(FRSPlayer *)player {
    if (play) {
        for (FRSPlayer *potential in self.players) {
            if (potential != player && [[potential class] isSubclassOfClass:[FRSPlayer class]]) {
                [potential pause];
            }
        }
        
        if (self.delegate) {
            [self.delegate playerWillPlay:player];
        }
    }
}

-(void)playerTap:(UITapGestureRecognizer *)tap {
    
    NSInteger page = (self.scrollView.contentOffset.x + self.frame.size.width/2)/self.scrollView.frame.size.width;
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
    }
    else if (self.muteImageView.alpha == 1) {
        self.muteImageView.alpha = 0;
        return;
    }
    
    if (player.rate == 0.0) {
        [player play];
    } else {
        [player pause];
    }
    
}

-(void)handlePhotoTap:(NSInteger)index {
    
}

-(void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.videoPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.videoPlayer play];
}

-(void)configureMuteIcon {
    NSInteger page = (self.scrollView.contentOffset.x + self.frame.size.width/2)/self.scrollView.frame.size.width;
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

-(BOOL)currentPageIsVideo {
    NSInteger page = (self.scrollView.contentOffset.x + self.frame.size.width/2)/self.scrollView.frame.size.width;
    return (self.players.count > page && [self.players[page] respondsToSelector:@selector(pause)]);
}

-(BOOL)pageIsVideo:(NSInteger)page {
    return (self.players.count > page && [self.players[page] respondsToSelector:@selector(pause)]);
}
-(void)configurePageControl{
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

-(void)configureGalleryInfo{
//    [self updateLabels];
    [self configureTimeLine];
    [self configureLocationLine];
    [self configureUserLine];
    [self updateLabels];
}

-(void)configureRepostWithName:(NSString *)name {
    
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
    }
}

-(void)configureTimeLine{
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

-(void)configureLocationLine{
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

-(void)configureUserLine {
    self.profileIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    self.profileIV.center = self.locationIV.center;
    [self.profileIV setOriginWithPoint:CGPointMake(self.profileIV.frame.origin.x, self.locationIV.frame.origin.y - self.profileIV.frame.size.height - 6)];
    
    self.profileIV.layer.cornerRadius = 12;
    self.profileIV.clipsToBounds = YES;
    [self addSubview:self.profileIV];
    
    FRSPost *post = [[self.gallery.posts allObjects] firstObject];
    
    self.nameLabel = [self galleryInfoLabelWithText:post.byline fontSize:17];
    self.nameLabel.center = self.profileIV.center;
    [self.nameLabel setOriginWithPoint:CGPointMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y)];
    self.nameLabel.frame = CGRectMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y, self.frame.size.width, 30);
    [self.nameLabel sizeToFit];

    //Set frame again to avoid clipping shadow
    self.nameLabel.frame = CGRectMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y, self.frame.size.width, 30);
    
    [self addShadowToLabel:self.nameLabel];
    
    self.nameLabel.layer.masksToBounds = NO;
    [self addSubview:self.nameLabel];
    
    if (post.creator.profileImage != [NSNull null] && [[post.creator.profileImage class] isSubclassOfClass:[NSString class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //Set user image
            [self.profileIV hnk_setImageFromURL:[NSURL URLWithString:post.creator.profileImage]];
            
            //Add gesture recognizer only if user has a photo
            
            UITapGestureRecognizer *bylineTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segueToUserProfile:)];
            
            [bylineTap setNumberOfTapsRequired:1];
            [self.nameLabel setUserInteractionEnabled:YES];
            [self.nameLabel addGestureRecognizer:bylineTap];
        });
    } else {
        [self.nameLabel setOriginWithPoint:CGPointMake(20, self.nameLabel.frame.origin.y)];
    }
}

-(void)updateLabels{
    if (self.orderedPosts.count == 0)
        return;
    
    FRSPost *post = self.orderedPosts[self.adjustedPage];
    
    self.nameLabel.text = post.byline;
    self.locationLabel.text = post.address;
    self.timeLabel.text = [FRSDateFormatter dateStringGalleryFormatFromDate:post.createdDate];
    
    self.nameLabel.numberOfLines = 1;
    [self.nameLabel sizeToFit];
    self.nameLabel.center = self.profileIV.center;
    [self.nameLabel setOriginWithPoint:CGPointMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y)];
    
    //[self.locationLabel sizeToFit];
    self.locationLabel.center = self.locationIV.center;
    [self.locationLabel setOriginWithPoint:CGPointMake(self.timeLabel.frame.origin.x, self.locationLabel.frame.origin.y)];
    [self.timeLabel sizeToFit];
    
    self.timeLabel.center = self.clockIV.center;
    [self.timeLabel setOriginWithPoint:CGPointMake(self.clockIV.frame.origin.x + self.clockIV.frame.size.width + 13, self.timeLabel.frame.origin.y)];
    CGRect timeFrame = self.timeLabel.frame;
    timeFrame.size.width = 100;
    self.timeLabel.frame = timeFrame;
    
    if (post.creator.profileImage != [NSNull null] && [[post.creator.profileImage class] isSubclassOfClass:[NSString class]]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.profileIV hnk_setImageFromURL:[NSURL URLWithString:post.creator.profileImage]];
            
            //Add gesture recognizer only if user has a photo
            UITapGestureRecognizer *bylineTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segueToUserProfile:)];
            [bylineTap setNumberOfTapsRequired:1];
            [self.nameLabel setUserInteractionEnabled:YES];
            [self.nameLabel addGestureRecognizer:bylineTap];
        });
        
    } else {
        [self.nameLabel setOriginWithPoint:CGPointMake(20, self.nameLabel.frame.origin.y)];
        [self.nameLabel setUserInteractionEnabled:NO];
    }

    [self addShadowToLabel:self.nameLabel];
    [self addShadowToLabel:self.locationLabel];
    [self addShadowToLabel:self.timeLabel];
}

-(void)addShadowToLabel:(UILabel*)label {
    if (!label.text) {
        return;
    }
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:label.text];
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

-(UILabel *)galleryInfoLabelWithText:(NSString *)text fontSize:(NSInteger)fontSize {
    
    UILabel *label = [UILabel new];
    label.clipsToBounds = NO;
    label.layer.masksToBounds = NO;

    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.font = fontSize == 13 ? [UIFont notaRegularWithSize:13] : [UIFont notaMediumWithSize:17];
    //[label addFixedShadow];
    label.layer.shouldRasterize = TRUE;
    label.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    label.adjustsFontSizeToFitWidth = YES;
    label.numberOfLines = 0;

   // [label sizeToFit];
    CGRect labelFrame = label.frame;
    labelFrame.size.height = 20;
    labelFrame.size.width = [UIScreen mainScreen].bounds.size.width;
    label.frame = labelFrame;
    return label;
}

-(void)removeFromSuperview {
    
    for (UIImageView *imageView in self.imageViews) {
        imageView.image = Nil;
    }
    
    [super removeFromSuperview];
}

-(void)configureCaptionLabel{
    self.captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, self.scrollView.frame.size.height, self.scrollView.frame.size.width - 32, 0)];
    self.captionLabel.textColor = [UIColor frescoDarkTextColor];
    self.captionLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.captionLabel.text = self.gallery.caption;
    
    if ([self.delegate shouldHaveTextLimit]){
        self.captionLabel.numberOfLines = 6;
    } else {
        self.captionLabel.numberOfLines = 0;
    }
    
    [self.captionLabel sizeToFit];
    
    [self.captionLabel setFrame:CGRectMake(16, self.scrollView.frame.size.height + TEXTVIEW_TOP_PAD, self.scrollView.frame.size.width - 32, self.captionLabel.frame.size.height)];
    
    [self addSubview:self.captionLabel];
}

-(void)configureActionsBar{
    
    if (![self.delegate shouldHaveActionBar]) {
        self.actionBar = [[FRSContentActionsBar alloc] initWithFrame:CGRectZero];
    }
    else{
        self.actionBar = [[FRSContentActionsBar alloc] initWithOrigin:CGPointMake(0, self.captionLabel.frame.origin.y + self.captionLabel.frame.size.height) delegate:self];
    }
    
    self.actionBar.delegate = self;
    
    [self addSubview:self.actionBar];
    
}

-(void)adjustHeight{
    NSInteger height = [self imageViewHeight] + self.captionLabel.frame.size.height + TEXTVIEW_TOP_PAD * 2 + self.actionBar.frame.size.height;
    
    if ([self.delegate shouldHaveActionBar]) {
        height -= TEXTVIEW_TOP_PAD;
    }
    
    [self setSizeWithSize:CGSizeMake(self.frame.size.width, height)];
    
    if (!self.borderLine) {
        self.borderLine = [UIView lineAtPoint:CGPointMake(0, self.frame.size.height)];
        [self addSubview:self.borderLine];
    }
    else {
        self.borderLine.frame = CGRectMake(0, self.frame.size.height, self.borderLine.frame.size.width, self.borderLine.frame.size.height);
    }
    
    [self bringSubviewToFront:self.borderLine];
}




#pragma mark - Action Bar Delegate
-(NSString *)titleForActionButton{
    return @"READ MORE";
}

-(UIColor *)colorForActionButton{
    return [UIColor frescoBlueColor];
}

-(void)contentActionBarDidSelectActionButton:(FRSContentActionsBar *)actionBar{

    if (self.readMoreBlock) {
        self.readMoreBlock(Nil);
    }
}

-(void)contentActionBarDidShare:(FRSContentActionsBar *)actionbar {
    FRSPost *post = self.orderedPosts[0];
    NSString *sharedContent = [@"https://fresconews.com/gallery/" stringByAppendingString:self.gallery.uid];
    
    sharedContent = [NSString stringWithFormat:@"Check out this gallery from %@: %@", [[post.address componentsSeparatedByString:@","] firstObject], sharedContent];
    self.shareBlock(@[sharedContent]);
}

#pragma mark ScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //We add half a screen's width so that the image loading occurs half way through the scroll.

    if (!self.players) {
        self.players = [[NSMutableArray alloc] init];
    }
    
    NSInteger page = (scrollView.contentOffset.x + self.frame.size.width/2)/self.scrollView.frame.size.width;
    if (page < 0) {
        return;
    }
    
    UIImageView *imageView;
    FRSPost *post;
    imageView = (self.imageViews.count > page) ? self.imageViews[page] : Nil;
    post = (self.orderedPosts.count > page) ? self.orderedPosts[page] : Nil;
    
    [imageView hnk_setImageFromURL:[NSURL URLWithString:post.imageUrl] placeholder:nil];
    [self handlePlay:TRUE player:Nil];
    
    if (self.players.count <= page) {
        if (post.videoUrl != Nil && page >= self.players.count) {
            FRSPlayer *player = [self setupPlayerForPost:post];
            [self.players addObject:player];
            [self.videoPlayer play];
            
        }
        else if (post.videoUrl == Nil || [post.videoUrl isEqual:[NSNull null]] || !post.videoUrl) {
            [self.players addObject:imageView];
        }
        else if (self.players.count > page && [self.players[page] respondsToSelector:@selector(play)]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                FRSPlayer *player = (FRSPlayer *)self.players[page];
                if ([player respondsToSelector:@selector(play)] && player.rate == 0.0 && player != self.videoPlayer) {
                    self.videoPlayer = player;
                    [player play];
                    
                }
                else if ([player respondsToSelector:@selector(play)] && player.rate != 0.0) {
                    [player pause];
                }
            });
        }
    }
    
    if (self.imageViews.count > page+1 && self.orderedPosts.count > page+1) {
        UIImageView *nextImage = self.imageViews[page+1];
        FRSPost *nextPost = self.orderedPosts[page+1];
        [nextImage hnk_setImageFromURL:[NSURL URLWithString:nextPost.imageUrl] placeholder:nil];
    }
    
    self.adjustedPage = page;
    
    if (page >= self.gallery.posts.count) {
        return;
    }
    
    if (page >= self.players.count) {
        return;
    }
    
    if (page != self.pageControl.currentPage){
        [self updateLabels];
        [self.videoPlayer pause];
    }
    
    if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > ((self.gallery.posts.count -1) * self.scrollView.frame.size.width)) return;
    
    if (self.imageViews.count == 0 || self.imageViews.count < page || self.orderedPosts.count < page) {
        return;
    }
    
    
    NSInteger halfScroll = scrollView.frame.size.width/4;
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
        
    if (percentCompleted > 3) percentCompleted -= 2;
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
    
    //Profile picture doesn't fade on scroll
    
    FRSPost *adjustedPost = self.orderedPosts[self.adjustedPage];
    if (adjustedPost.creator.profileImage != [NSNull null] && [[adjustedPost.creator.profileImage class] isSubclassOfClass:[NSString class]]) {
        [self.profileIV hnk_setImageFromURL:[NSURL URLWithString:adjustedPost.creator.profileImage]];
        self.profileIV.alpha = 1;
    } else {
        [self.nameLabel setOriginWithPoint:CGPointMake(20, self.nameLabel.frame.origin.y)];
        self.profileIV.alpha = 0;
    }
    
    if (adjustedPost.videoUrl == nil) {
        self.muteImageView.alpha = 0;
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == self.videoPlayer && [keyPath isEqualToString:@"status"]) {
        
        if (self.videoPlayer.status == AVPlayerStatusReadyToPlay) {
            
        }
        else if (self.videoPlayer.status == AVPlayerStatusFailed) {
            
        }
    }
}

-(void)setupPlayer {
    [self.videoPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
}

-(void)breakDownPlayer:(AVPlayerLayer *)layer {
    [layer.player pause];
    [layer.player replaceCurrentItemWithPlayerItem:Nil];
    [layer removeFromSuperlayer];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page = scrollView.contentOffset.x / self.scrollView.frame.size.width;
    self.pageControl.currentPage = page;
    
    self.currentPage = page;
    if (self.players.count > page) {
        self.videoPlayer = ([self.players[page] respondsToSelector:@selector(play)]) ? self.players[page] : Nil;
        [self.videoPlayer play];
    }
    
    [self configureMuteIcon];
}

-(NSInteger)imageViewHeight{
    NSInteger totalHeight = 0;
    
    for (FRSPost *post in self.gallery.posts){
        NSInteger rawHeight = [post.meta[@"image_height"] integerValue];
        NSInteger rawWidth = [post.meta[@"image_width"] integerValue];
        
        if (rawHeight == 0 || rawWidth == 0){
            totalHeight += [UIScreen mainScreen].bounds.size.width;
        }
        else {
            NSInteger scaledHeight = rawHeight * ([UIScreen mainScreen].bounds.size.width/rawWidth);
            totalHeight += scaledHeight;
        }
    }
    
    NSInteger averageHeight = totalHeight/self.gallery.posts.count;
    
    averageHeight = MIN(averageHeight, [UIScreen mainScreen].bounds.size.width * 4/3);
    
    return averageHeight;
}

-(void)segueToUserProfile:(FRSUser *)user {
    
    NSInteger page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    if (page >= 0 && page < self.orderedPosts.count) {
        FRSPost *currentPost = self.orderedPosts[page];
        
        
        NSLog(@"currentPost.byline = %@", currentPost.byline);
        
        FRSProfileViewController *userViewController = [[FRSProfileViewController alloc] initWithUser:currentPost.creator];

        [self.delegate.navigationController pushViewController:userViewController animated:YES];
    }
}

-(void)presentParallax{
    
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.container.alpha = 1;
        self.parallaxImage.alpha = 1;
    } completion:nil];
    
    [UIView beginAnimations:@"statusBar" context:nil];
    [UIView setAnimationDuration:0.3];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [UIView commitAnimations];
}

-(void)dismissParallax{
    self.parallaxImage.alpha = 0;

    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.container.alpha = 0;
    } completion:^(BOOL finished) {
        [self.parallaxImage removeFromSuperview];
        self.userInteractionEnabled = YES;
    }];
    
    [UIView beginAnimations:@"statusBar" context:nil];
    [UIView setAnimationDuration:0];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIView commitAnimations];
}

-(void)play {
    NSInteger page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    
    if (self.players.count > page) {
        if ([[self.players[page] class] isSubclassOfClass:[FRSPlayer class]]) {
            [(AVPlayer *)self.players[page] play];
        }
    }
    
//    self.muteImageView.alpha = 0;
}

-(void)pause {
    for (AVPlayer *player in self.players) {
        if ([[player class] isSubclassOfClass:[FRSPlayer class]]) {
            [player pause];
        }
    }
    
//    self.muteImageView.alpha = 1;
}

@end
