//
//  FRSStoryView.m
//  Fresco
//
//  Created by Omar Elfanek on 1/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSStoryView.h"

#import "FRSStoryView.h"
#import "FRSPost.h" // ---------

#import "UIColor+Fresco.h"
#import "UIView+Helpers.h"
#import "UIFont+Fresco.h"
#import "FRSDateFormatter.h" // ---------

#import "FRSScrollViewImageView.h" // ---------

#import "FRSContentActionsBar.h"

#import <Haneke/Haneke.h>

#define TEXTVIEW_TOP_PADDING 12


@interface FRSStoryView() <UIScrollViewDelegate, FRSContentActionsBarDelegate, UITextViewDelegate>

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

@implementation FRSStoryView

-(instancetype)initWithFrame:(CGRect)frame story:(FRSStory *)story delegate:(id<FRSStoryViewDelegate>)delegate{
    self = [super initWithFrame:frame];
    
    if (self){
        self.delegate = delegate;
        self.story = story;
//        self.orderedPosts = [self.story.posts allObjects];
        [self configureUI];
    }
    return self;
}

-(void)configureUI {
    
    self.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    [self configureScrollView];
    
}

-(void)configureScrollView{
//    self.scrollView = [UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [self imageViewHeight]);
}





























































//-(NSInteger)imageViewHeigh


@end






















