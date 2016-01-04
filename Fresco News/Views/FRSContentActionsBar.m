//
//  FRSContentActionsBar.m
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSContentActionsBar.h"

#import "UIFont+Fresco.h"
#import "UIColor+Fresco.h"
#import "UIView+Helpers.h"


@interface FRSContentActionsBar()

@property (strong, nonatomic) UIButton *actionButton;

@property (strong, nonatomic) UIButton *likeButton;

@property (strong ,nonatomic) UILabel *likeLabel;

@property (strong, nonatomic) UIButton *repostButton;

@property (strong, nonatomic) UILabel *repostLabel;

@property (strong, nonatomic) UIButton *shareButton;

@end

@implementation FRSContentActionsBar

-(instancetype)initWithOrigin:(CGPoint)origin delegate:(id<FRSContentActionsBarDelegate>)delegate{
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, [UIScreen mainScreen].bounds.size.width, 44)];
    if (self){
        
        self.delegate = delegate;
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        
        [self configureActionButton];
        
        [self configureShareButton];
        [self configureRepostSection];
        [self configureLikeSection];
    }
    return self;
}

-(void)configureActionButton{
    
    self.actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 1, 108, self.frame.size.height)];
    [self.actionButton setTitleColor:[self.delegate colorForActionButton] forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[[self.delegate colorForActionButton] colorWithAlphaComponent:0.7]  forState:UIControlStateHighlighted];
    [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [self.actionButton setTitle:[self.delegate titleForActionButton] forState:UIControlStateNormal];
    [self.actionButton addTarget:self.delegate action:@selector(didTapActionButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.actionButton];
}

-(void)configureShareButton{
    self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 6 - 44, 1, 44, 42)];
    [self.shareButton setImage:[UIImage imageNamed:@"share-icon"] forState:UIControlStateNormal];
    [self addSubview:self.shareButton];
}

-(void)configureRepostSection{
    self.repostLabel = [[UILabel alloc] init];
    self.repostLabel.text = @"30";
    self.repostLabel.font = [UIFont notaBoldWithSize:15];
    self.repostLabel.textColor = [UIColor frescoGreenColor];
    [self.repostLabel sizeToFit];
    
    self.repostLabel.frame = CGRectMake(self.shareButton.frame.origin.x - 6 - self.repostLabel.frame.size.width, 0, self.repostLabel.frame.size.width, self.frame.size.height);
    [self addSubview:self.repostLabel];
    
    self.repostButton = [[UIButton alloc] initWithFrame:CGRectMake(self.repostLabel.frame.origin.x - 36.5, 0, 36.5, self.frame.size.height)];
    [self.repostButton setImage:[UIImage imageNamed:@"repost-icon-gray"] forState:UIControlStateNormal];
    [self.repostButton setImage:[UIImage imageNamed:@"repost-icon-green"] forState:UIControlStateSelected];
    [self.repostButton setImage:[UIImage imageNamed:@"repost-icon-green"] forState:UIControlStateHighlighted];
    [self.repostButton addTarget:self action:@selector(handleRepostTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.repostButton];
    
}

-(void)configureLikeSection{
    
    self.likeLabel = [[UILabel alloc] init];
    self.likeLabel.text = @"141";
    self.likeLabel.textColor = [UIColor frescoRedHeartColor];
    self.likeLabel.font = [UIFont notaBoldWithSize:15];
    [self.likeLabel sizeToFit];
    
    self.likeLabel.frame = CGRectMake(self.repostButton.frame.origin.x - 6 - self.likeLabel.frame.size.width, 0, self.likeLabel.frame.size.width, self.frame.size.height);
    [self addSubview:self.likeLabel];
    
    
    self.likeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.likeLabel.frame.origin.x - 36, 0, 36, self.frame.size.height)];
    [self.likeButton setImage:[UIImage imageNamed:@"liked-heart"] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"liked-heart-filled"] forState:UIControlStateSelected];
    [self.likeButton setImage:[UIImage imageNamed:@"liked-heart-filled"] forState:UIControlStateHighlighted];
    self.likeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.likeButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.likeButton addTarget:self action:@selector(handleLikeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.likeButton];
}

-(void)handleRepostTapped{
    
}

-(void)handleLikeButtonTapped{
    
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
