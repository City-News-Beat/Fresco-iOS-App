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
#define TEXTVIEW_TOP_PAD 12

@interface FRSGalleryView() <UIScrollViewDelegate, FRSContentActionBarDelegate, UITextViewDelegate>
@property (nonatomic, retain) UIView *topLine;
@property (nonatomic, retain) UIView *bottomLine;
@property (nonatomic, retain) UIView *borderLine;
@property BOOL playerHasFocus;
@end

@implementation FRSGalleryView

/*
/
 / Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)loadGallery:(FRSGallery *)gallery {
    
    for (FRSPlayer *player in self.players) {
        if ([player respondsToSelector:@selector(pause)]) {
            [player.container removeFromSuperview];
            [player pause];
            [player replaceCurrentItemWithPlayerItem:Nil];
        }
    }
    
    self.players = [[NSMutableArray alloc] init];
    
    [self breakDownPlayer:self.playerLayer];
    
    self.clipsToBounds = NO;
    self.gallery = gallery;
    self.orderedPosts = [gallery.posts allObjects];
        
    [self adjustHeight];

    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, [self imageViewHeight]);
    self.scrollView.contentSize = CGSizeMake(self.gallery.posts.count * self.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.clipsToBounds = YES;
    [self updateLabels];
    
    self.pageControl.numberOfPages = self.gallery.posts.count;
    [self.pageControl setCurrentPage:0];
    self.pageControl.frame = CGRectMake(self.scrollView.frame.size.width - 20 - (self.gallery.posts.count * 8) , self.scrollView.frame.size.height - 15 - 8, self.pageControl.frame.size.width, 8);
    
   // self.pageControl.frame = CGRectMake(0, self.scrollView.frame.size.height - 15, self.pageControl.frame.size.width, 8);

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
    self.nameLabel.frame = CGRectMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y, self.frame.size.width, 20);
    
    [self.actionBar setOriginWithPoint:CGPointMake(0, self.captionLabel.frame.origin.y + self.captionLabel.frame.size.height)];
    [self.borderLine.superview bringSubviewToFront:self.borderLine];

    [self updateScrollView];
}

-(void)updateScrollView {
    if (self.scrollView.contentOffset.x >= 0) {
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:NO];
        [self scrollViewDidScroll:self.scrollView];
    }
    
    for (UIImageView *imageView in self.imageViews) {
        [imageView removeFromSuperview];
    }
    
    [self configureImageViews];
}

-(void)handleActionButtonTapped {
    // idk why dan made this method life is a mystery
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
        self.orderedPosts = [self.gallery.posts allObjects];
        self.players = [[NSMutableArray alloc] init];
        [self configureUI];
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
    [self addSubview:self.scrollView];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerTap:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.cancelsTouchesInView = FALSE;
    [self addGestureRecognizer:tapGesture];
}

-(void)configureImageViews{
    
    self.imageViews = [NSMutableArray new];
    
        for (NSInteger i = 0; i < self.gallery.posts.count; i++){
            
            FRSPost *post = self.orderedPosts[i];
            
            NSInteger xOrigin = i * self.frame.size.width;
            FRSScrollViewImageView *imageView = [[FRSScrollViewImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.frame.size.width, [self imageViewHeight])];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.backgroundColor = [UIColor whiteColor];
            imageView.clipsToBounds = YES;
            imageView.indexInScrollView = i;
            
            [self.imageViews addObject:imageView];
            
                if (i==0) {
                    [imageView hnk_setImageFromURL:[NSURL URLWithString:post.imageUrl]];

                if (post.videoUrl != Nil) {
                    // video
                    // set up FRSPlayer
                    // add AVPlayerLayer
                    NSLog(@"TOP LEVEL PLAYER");
                    [self setupPlayerForPost:post];
                }
            }
                
            imageView.userInteractionEnabled = YES;
            [self.scrollView addSubview:imageView];
    }
    
    if (self.imageViews.count > 1) {
        UIImageView *nextImage = self.imageViews[1];
        FRSPost *nextPost = self.orderedPosts[1];
        [nextImage hnk_setImageFromURL:[NSURL URLWithString:nextPost.imageUrl] placeholder:nil];
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

-(void)setupPlayerForPost:(FRSPost *)post {
    
    FRSPlayer *videoPlayer = [FRSPlayer playerWithURL:[NSURL URLWithString:post.videoUrl]];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:videoPlayer];
    videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    [self.players addObject:videoPlayer];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(playerItemDidReachEnd:)
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                object:[videoPlayer currentItem]];
        
    NSInteger postIndex = [self.orderedPosts indexOfObject:post];
    UIImageView *imageView  = self.imageViews[0];
        
    playerLayer.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * postIndex, 0, [UIScreen mainScreen].bounds.size.width, imageView.frame.size.height);
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    playerLayer.backgroundColor = [UIColor clearColor].CGColor;
        
    UIView *container = [[UIView alloc] initWithFrame:self.playerLayer.frame];
    container.backgroundColor = [UIColor clearColor];
   
    videoPlayer.container = container;
    playerLayer.frame = CGRectMake(0, 0, playerLayer.frame.size.width, playerLayer.frame.size.height);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [container.layer addSublayer:playerLayer];
        [self.scrollView addSubview:container];
        [self.scrollView bringSubviewToFront:container];
        
        if (self.delegate) {
            [self.delegate playerWillPlay:self.videoPlayer];
        }
    });
}

-(void)playerTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    
    if (point.y > self.scrollView.frame.size.height) {
        return;
    }
    
    NSInteger page = (self.scrollView.contentOffset.x + self.frame.size.width/2)/self.scrollView.frame.size.width;
    FRSPlayer *player;
    
    if (self.players.count > 0) {
        player = self.players[page];
    }
    
    if (![player respondsToSelector:@selector(play)]) {
        [self handlePhotoTap:page];
        return;
    }
    
    if (player.rate == 0.0) {
        [player play];
    }
    else {
        [player pause];
    }
}

-(void)handlePhotoTap:(NSInteger)index {
    
}

-(void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.videoPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.videoPlayer play];
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
        self.nameLabel.frame = CGRectMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y, self.frame.size.width, 20);
    
    [self addShadowToLabel:self.nameLabel];
    
    [self addSubview:self.nameLabel];
    
    if (post.creator.profileImage != [NSNull null] && [[post.creator.profileImage class] isSubclassOfClass:[NSString class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.profileIV hnk_setImageFromURL:[NSURL URLWithString:post.creator.profileImage]];
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
    
//    [self.nameLabel sizeToFit];
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
        });
        
    } else {
        [self.nameLabel setOriginWithPoint:CGPointMake(20, self.nameLabel.frame.origin.y)];
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
    shadow.shadowColor = [UIColor frescoLightTextColor];
    shadow.shadowOffset = CGSizeMake(0, 1);
    shadow.shadowBlurRadius = 1.5;
    [attString addAttribute:NSShadowAttributeName value:shadow range:range];
    
    label.attributedText = attString;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GalleryContentBarActionTapped" object:nil userInfo:@{@"gallery_id" : self.gallery.uid}];
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

    NSInteger page = (scrollView.contentOffset.x + self.frame.size.width/2)/self.scrollView.frame.size.width;
    if (page < 0) {
        return;
    }
    
    UIImageView *imageView;
    FRSPost *post;
    imageView = (self.imageViews.count > page) ? self.imageViews[page] : Nil;
    post = (self.orderedPosts.count > page) ? self.orderedPosts[page] : Nil;


    [imageView hnk_setImageFromURL:[NSURL URLWithString:post.imageUrl] placeholder:nil];
    
    if (self.imageViews.count > page+1 && self.orderedPosts.count > page+1) {
        UIImageView *nextImage = self.imageViews[page+1];
        FRSPost *nextPost = self.orderedPosts[page+1];
        [nextImage hnk_setImageFromURL:[NSURL URLWithString:nextPost.imageUrl] placeholder:nil];
    }
    
    self.adjustedPage = page;
    
    if (page >= self.gallery.posts.count) {
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
    
    if (self.players.count > page) {
    
    if (post.videoUrl != Nil && self.players.count < page) {
        [self setupPlayerForPost:post];
        [self.videoPlayer play];
    }
    else if (self.players.count > page && self.imageViews.count > page) {
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
        else {
            [self.players addObject:imageView];
        }
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
    
    //Profile picture doesn't fade on scroll
    
    FRSPost *adjustedPost = self.orderedPosts[self.adjustedPage];
    if (adjustedPost.creator.profileImage != [NSNull null] && [[adjustedPost.creator.profileImage class] isSubclassOfClass:[NSString class]]) {
        [self.profileIV hnk_setImageFromURL:[NSURL URLWithString:adjustedPost.creator.profileImage]];
        self.profileIV.alpha = 1;
    } else {
        [self.nameLabel setOriginWithPoint:CGPointMake(20, self.nameLabel.frame.origin.y)];
        self.profileIV.alpha = 0;
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

-(void)galleryTapped{    
    
//    self.parallaxImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];

    
//    FRSScrollViewImageView *image = [[FRSScrollViewImageView alloc] initWithFrame:self.parallaxImage.frame];
//    UIImage *currentImage = [UIImage new];
//    image = [self.imageViews objectAtIndex:self.currentPage];
//    [self.parallaxImage setImage:image];
    
//    UIImage *imageView = self.imageViews[self.currentPage];
//    self.parallaxImage.image = imageView;
    
//    self.parallaxImage.image = self.imageViews.firstObject;
    
    
    
//    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
//    self.container.backgroundColor = [UIColor blackColor];
//    [self.window addSubview:self.container];
//    
//    
//    self.parallaxImage.alpha = 0;
//    self.userInteractionEnabled = NO;
//    self.parallaxImage.backgroundColor = [UIColor redColor];
//    [self.window addSubview:self.parallaxImage];
//    
//    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissParallax)];
//    [self.window addGestureRecognizer:tap];
    
    
//    [self presentParallax];
//    [OEParallax createParallaxFromView:self.parallaxImage withMaxX:100 withMinX:-100 withMaxY:100 withMinY:-100];
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
    [self.videoPlayer play];
}

-(void)pause {
    for (AVPlayer *player in self.players) {
        if ([player respondsToSelector:@selector(pause)]) {
            [player pause];
        }
    }
}

@end
