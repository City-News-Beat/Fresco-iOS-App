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
#import "FRSStory.h"

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

@property (strong, nonatomic) UIView *topContainer;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *caption;

@property (strong, nonatomic) NSMutableArray *imageViews;



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
    
    [self configureTopContainer];
    [self configureTitleLabel];
    [self configureCaption];
    [self configureActionsBar];
}

-(void)configureTopContainer{
    
    NSInteger height = IS_IPHONE_5 ? 192 : 240;
    
    self.topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, height)];
    self.topContainer.backgroundColor = [UIColor blueColor];
    [self addSubview:self.topContainer];
}

-(void)configureTitleLabel{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 32, 0)];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.text = self.story.title;
    self.titleLabel.font = [UIFont notaBoldWithSize:24];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.titleLabel sizeToFit];
    
    [self.titleLabel setOriginWithPoint:CGPointMake(16, self.topContainer.frame.size.height - self.titleLabel.frame.size.height - 12)];
    
    [self.topContainer addSubview:self.titleLabel];
}


-(void)configureCaption{
    self.caption = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.frame.size.width - 32, 0)];
    self.caption.numberOfLines = 6;
    self.caption.textColor = [UIColor frescoDarkTextColor];
    self.caption.font = [UIFont systemFontOfSize:15 weight:-1];
    self.caption.text = self.story.caption;
    
    [self.caption sizeToFit];
    
    [self.caption setFrame:CGRectMake(16, self.topContainer.frame.size.height + 11, self.frame.size.width - 32, self.caption.frame.size.height)];
    
    [self addSubview:self.caption];
}

-(void)configureActionsBar{
    
    self.actionBar = [[FRSContentActionsBar alloc] initWithOrigin:CGPointMake(0, self.caption.frame.origin.y + self.caption.frame.size.height) delegate:self];
    [self addSubview:self.actionBar];
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






















