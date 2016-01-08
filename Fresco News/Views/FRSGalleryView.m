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
#import "FRSScrollViewImageView.h"

//views
#import "FRSContentActionsBar.h"


@interface FRSGalleryView() <UIScrollViewDelegate, FRSContentActionsBarDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) FRSContentActionsBar *actionBar;

@property (strong, nonatomic) UITextView *textView;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) UIImageView *profileIV;
@property (strong, nonatomic) UIImageView *locationIV;
@property (strong, nonatomic) UIImageView *clockIV;

@property (strong, nonatomic) UIPageControl *pageControl;

@end

@implementation FRSGalleryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery dataSource:(id <FRSGalleryViewDataSource>)dataSource{
    self = [super initWithFrame:frame];
    if (self){
        self.dataSource = dataSource;
        self.gallery = gallery;
        
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
    
    [self configureTextView];
    [self configureActionsBar];
}

-(void)configureScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [self.dataSource heightForImageView])];
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(5 * self.frame.size.width, self.scrollView.frame.size.height);
    [self addSubview:self.scrollView];
    
}

-(void)configureImageViews{
    for (NSInteger i = 0; i < self.gallery.posts.count; i++){
        NSInteger xOrigin = i * self.frame.size.width;
        FRSScrollViewImageView *imageView = [[FRSScrollViewImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.frame.size.width, [self.dataSource heightForImageView])];
        imageView.image = [UIImage imageNamed:@"temp-big"];
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.indexInScrollView = i;
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
    self.pageControl.numberOfPages = 5;
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
//    [self.clockIV addShadowWithColor:[UIColor frescoShadowColor] radius:1 offset:CGSizeMake(1, 1)];
    [self addSubview:self.clockIV];
    
    self.timeLabel = [self galleryInfoLabelWithText:@"2:45 PM" fontSize:13];
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
//    [self.locationIV addShadowWithColor:[UIColor frescoShadowColor] radius:1 offset:CGSizeMake(1, 1)];
    [self addSubview:self.locationIV];
    
    self.locationLabel = [self galleryInfoLabelWithText:@"New York, USA" fontSize:13];
    self.locationLabel.center = self.locationIV.center;
    [self.locationLabel setOriginWithPoint:CGPointMake(self.timeLabel.frame.origin.x, self.locationLabel.frame.origin.y)];
    
    [self addSubview:self.locationLabel];
}

-(void)configureUserLine{
    self.profileIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    self.profileIV.center = self.locationIV.center;
    [self.profileIV setOriginWithPoint:CGPointMake(self.profileIV.frame.origin.x, self.locationIV.frame.origin.y - self.profileIV.frame.size.height - 6)];
    self.profileIV.image = [UIImage imageNamed:@"tab-bar-profile"];
    
//    [self.profileIV addShadowWithColor:[UIColor frescoShadowColor] radius:1 offset:CGSizeMake(1, 1)];
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
    [label sizeToFit];
//    [label addShadowWithColor:[UIColor frescoShadowColor] radius:1 offset:CGSizeMake(1, 1)];
    return label;
}

-(void)configureTextView{
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.size.height, self.scrollView.frame.size.width, self.frame.size.height - self.scrollView.frame.size.height - 44)];
    self.textView.textContainerInset = UIEdgeInsetsMake(12, 16, 0, 16);
    self.textView.textColor = [UIColor frescoDarkTextColor];
    self.textView.editable = NO;
    self.textView.scrollEnabled = NO;
    self.textView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.textView.font = [UIFont systemFontOfSize:15 weight:-1];
    self.textView.text = @"It was a humorously perilous business for both of us. For, before we proceed further, it must be said that the monkey-rope was fast at both ends; fast to Queequeg's broad canvas belt, and fast to my narrow leather one. So that for better or for worse, we two, for the time, were wedded; and should poor Queequeg sink to rise...";
    self.textView.delegate = self;
    [self addSubview:self.textView];
}

-(void)configureActionsBar{
    self.actionBar = [[FRSContentActionsBar alloc] initWithOrigin:CGPointMake(0, self.textView.frame.origin.y + self.textView.frame.size.height) delegate:self];
    [self addSubview:self.actionBar];
    
    [self.actionBar addSubview:[UIView lineAtPoint:CGPointMake(0, self.actionBar.frame.size.height - 0.5)]];
}

#pragma mark - Action Bar Delegate
-(NSString *)titleForActionButton{
    return @"READ MORE";
}

-(UIColor *)colorForActionButton{
    return [UIColor frescoBlueColor];
}

-(void)didTapActionButton{
    
}

#pragma mark ScrollView Delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page = scrollView.contentOffset.x / self.scrollView.frame.size.width;
    self.pageControl.currentPage = page;
}




@end
