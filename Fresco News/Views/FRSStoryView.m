//
//  FRSStoryView.m
//  Fresco
//
//  Created by Omar Elfanek on 1/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSStoryView.h"

#import "FRSStoryView.h"
#import "FRSPost.h"

#import "UIColor+Fresco.h"
#import "UIView+Helpers.h"
#import "UIFont+Fresco.h"
#import "FRSDateFormatter.h"

#import "FRSScrollViewImageView.h"

#import "FRSContentActionsBar.h"

#import <Haneke/Haneke.h>

#define TEXTVIEW_TOP_PADDING 12


@interface FRSStoryView() <UIScrollViewDelegate, FRSContentActionBarDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) FRSContentActionsBar *actionBar;

@property (strong, nonatomic) UILabel *captionLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) UIImageView *profileIV;
@property (strong, nonatomic) UIImageView *locationIV;
@property (strong, nonatomic) UIImageView *clockIV;

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
    
    self.backgroundColor = [UIColor blueColor];
    
    [self configureScrollView];
    [self configureImageViews];
}

-(void)configureScrollView{
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 241)];
    if (IS_IPHONE_5){
        self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, 193);
    }
    
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
//    self.scrollView.contentSize = CGSizeMake(self.story.posts.count * self.frame.size.width, self.scrollView.frame.size.height);
    [self addSubview:self.scrollView];
}

-(void)configureImageViews{

}

-(void)configureStoryTitle{
    UILabel *storyLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 228, 50)];
    storyLabel.backgroundColor = [UIColor redColor];
    [self addSubview:storyLabel];
}


-(void)configureCaptionLabel{
    self.captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, self.scrollView.frame.size.height, self.scrollView.frame.size.width - 32, 0)];
    self.captionLabel.textColor = [UIColor frescoDarkTextColor];
    self.captionLabel.font = [UIFont systemFontOfSize:15 weight:-1];
//    self.captionLabel.text = self.story.caption;
    self.captionLabel.backgroundColor = [UIColor redColor];
    self.captionLabel.text = @"Caption caption caption caption";
    
    if ([self.delegate shouldHaveTextLimit]){
        self.captionLabel.numberOfLines = 6;
    } else {
        self.captionLabel.numberOfLines = 0;
    }
    
    [self.captionLabel sizeToFit];
    
    [self.captionLabel setFrame:CGRectMake(16, self.scrollView.frame.size.height + TEXTVIEW_TOP_PADDING, self.scrollView.frame.size.width - 32, self.captionLabel.frame.size.height)];
    
    [self addSubview:self.captionLabel];
}

-(void)configureActionsBar{
    
    if (![self.delegate shouldHaveActionBar]) {
        self.actionBar = [[FRSContentActionsBar alloc] initWithFrame:CGRectZero];
    } else {
        self.actionBar = [[FRSContentActionsBar alloc] initWithOrigin:CGPointMake(0, self.captionLabel.frame.origin.y + self.captionLabel.frame.size.height) delegate:self];
    }
}

#pragma mark - Action Bar Deletate

-(NSString *)titleForActionButton{
    return @"READ MORE";
}

-(UIColor *)colorForActionButton{
    return [UIColor frescoBlueColor];
}

-(void)contentActionBarDidSelectActionButton:(FRSContentActionsBar *)actionBar{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"StoryContentBarActionTapped" object:nil userInfo:@{@"story_id" : self.story.uid}];
}

















































@end






















