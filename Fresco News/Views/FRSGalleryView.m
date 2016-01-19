//
//  FRSGalleryView.m
//  Fresco
//
//  Created by Daniel Sun on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSGalleryView.h"

//models
#import "FRSGallery.h"
#import "FRSPost.h"

//helper classes and categories
#import "UIColor+Fresco.h"
#import "UIView+Helpers.h"
#import "UIFont+Fresco.h"
#import "FRSDateFormatter.h"

#import "FRSScrollViewImageView.h"

//views
#import "FRSContentActionsBar.h"

#import <Haneke/Haneke.h>

#define TEXTVIEW_TOP_PAD 12


@interface FRSGalleryView() <UIScrollViewDelegate, FRSContentActionBarDelegate, UITextViewDelegate>

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

@end

@implementation FRSGalleryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery delegate:(id <FRSGalleryViewDelegate>)delegate{
    self = [super initWithFrame:frame];
    if (self){
        self.delegate = delegate;
        self.gallery = gallery;
        self.orderedPosts = [self.gallery.posts allObjects];
        
        [self configureUI];
    }
    return self;
}

-(void)configureUI{
    
    self.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    [self configureScrollView];
    [self configureImageViews];
    [self configurePageControl];
    
    [self configureGalleryInfo];
    
    [self configureCaptionLabel];

    [self configureActionsBar];
    
    [self adjustHeight];
}

-(void)configureScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [self imageViewHeight])];
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.gallery.posts.count * self.frame.size.width, self.scrollView.frame.size.height);
    [self addSubview:self.scrollView];
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
        
        if (i==0)
            [imageView hnk_setImageFromURL:[NSURL URLWithString:post.imageUrl]];
        
        [self.scrollView addSubview:imageView];
    }
    
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 0.5)];
    topLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
    [self addSubview:topLine];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.size.height - 0.5, self.scrollView.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
    [self addSubview:line];
}

-(void)configurePageControl{
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = self.gallery.posts.count;
    self.pageControl.currentPage = 0;
    
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.7];
    
    [self.pageControl sizeToFit];
    [self.pageControl setFrame:CGRectMake(self.scrollView.frame.size.width - 16 - self.pageControl.frame.size.width, self.scrollView.frame.size.height - 15 - 8, self.pageControl.frame.size.width, 8)];
    
    self.pageControl.hidesForSinglePage = YES;
    
    [self addSubview:self.pageControl];
}

-(void)configureGalleryInfo{
    [self configureTimeLine];
    [self configureLocationLine];
    [self configureUserLine];
}

-(void)configureTimeLine{
    self.clockIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    self.clockIV.image = [UIImage imageNamed:@"gallery-clock"];
    self.clockIV.contentMode = UIViewContentModeCenter;
    self.clockIV.center = self.pageControl.center;
    [self.clockIV setFrame:CGRectMake(21, self.clockIV.frame.origin.y, 16, 16)];
    [self.clockIV addFixedShadow];

    [self addSubview:self.clockIV];
    
    self.timeLabel = [self galleryInfoLabelWithText:[FRSDateFormatter dateStringGalleryFormatFromDate:self.gallery.createdDate] fontSize:13];
    self.timeLabel.center = self.clockIV.center;
    [self.timeLabel setOriginWithPoint:CGPointMake(self.clockIV.frame.origin.x + self.clockIV.frame.size.width + 13, self.timeLabel.frame.origin.y)];
    
    [self addSubview:self.timeLabel];
}

-(void)configureLocationLine{
    self.locationIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    self.locationIV.image = [UIImage imageNamed:@"gallery-pin"];
    self.locationIV.contentMode = UIViewContentModeCenter;
    self.locationIV.center = self.clockIV.center;
    [self.locationIV setOriginWithPoint:CGPointMake(self.locationIV.frame.origin.x, self.clockIV.frame.origin.y - self.locationIV.frame.size.height - 6)];
    [self.locationIV addFixedShadow];
    [self addSubview:self.locationIV];
    
    FRSPost *post = [[self.gallery.posts allObjects] firstObject];
    
    self.locationLabel = [self galleryInfoLabelWithText:post.address fontSize:13];
    self.locationLabel.center = self.locationIV.center;
    [self.locationLabel setOriginWithPoint:CGPointMake(self.timeLabel.frame.origin.x, self.locationLabel.frame.origin.y)];
    
    [self addSubview:self.locationLabel];
}

-(void)configureUserLine{
    self.profileIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    self.profileIV.center = self.locationIV.center;
    [self.profileIV setOriginWithPoint:CGPointMake(self.profileIV.frame.origin.x, self.locationIV.frame.origin.y - self.profileIV.frame.size.height - 6)];
    self.profileIV.image = [UIImage imageNamed:@"profile-icon-light"];
    [self.profileIV addFixedShadow];
    
    [self addSubview:self.profileIV];
    
    self.nameLabel = [self galleryInfoLabelWithText:@"Daniel Sun" fontSize:17];
    self.nameLabel.center = self.profileIV.center;
    [self.nameLabel setOriginWithPoint:CGPointMake(self.timeLabel.frame.origin.x, self.nameLabel.frame.origin.y)];
    
    [self addSubview:self.nameLabel];
}

-(UILabel *)galleryInfoLabelWithText:(NSString *)text fontSize:(NSInteger)fontSize{
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.font = fontSize == 13 ? [UIFont notaRegularWithSize:13] : [UIFont notaMediumWithSize:17];
    [label addFixedShadow];
    [label sizeToFit];

    return label;
}

-(void)configureCaptionLabel{
    self.captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, self.scrollView.frame.size.height, self.scrollView.frame.size.width - 32, 0)];
    self.captionLabel.textColor = [UIColor frescoDarkTextColor];
    self.captionLabel.font = [UIFont systemFontOfSize:15 weight:-1];
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
    if ([self.delegate shouldHaveActionBar]) height -= TEXTVIEW_TOP_PAD;
    
    [self setSizeWithSize:CGSizeMake(self.frame.size.width, height)];
    [self addSubview:[UIView lineAtPoint:CGPointMake(0, self.frame.size.height)]];
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

#pragma mark ScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //We add half a screen's width so that the image loading occurs half way through the scroll.
    NSInteger page = (scrollView.contentOffset.x + self.frame.size.width/2)/self.scrollView.frame.size.width;
    
    
    if (page >= self.gallery.posts.count) return;
    
    FRSScrollViewImageView *imageView = self.imageViews[page];
    FRSPost *post = self.orderedPosts[page];
    
    [imageView hnk_setImageFromURL:[NSURL URLWithString:post.imageUrl] placeholder:nil];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page = scrollView.contentOffset.x / self.scrollView.frame.size.width;
    self.pageControl.currentPage = page;
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



@end
