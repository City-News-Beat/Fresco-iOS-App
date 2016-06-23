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

-(instancetype)initWithOrigin:(CGPoint)origin delegate:(id<FRSContentActionBarDelegate>)delegate{
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
-(void)handleHeartAmount:(NSInteger)amount {
    
    if (amount == 0) {
        self.likeLabel.text = @"0";
    }
    
    self.likeLabel.text = [NSString stringWithFormat:@"%lu", (long)amount];
}

-(void)configureActionButton{
    
    UILabel *temp = [[UILabel alloc] init];
    temp.font = [UIFont notaBoldWithSize:15];
    temp.text = [self.delegate titleForActionButton];
    [temp sizeToFit];
    
    self.actionButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 1, temp.frame.size.width, self.frame.size.height)];
    [self.actionButton setTitleColor:[self.delegate colorForActionButton] forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[[self.delegate colorForActionButton] colorWithAlphaComponent:0.7]  forState:UIControlStateHighlighted];
    [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [self.actionButton setTitle:[self.delegate titleForActionButton] forState:UIControlStateNormal];
    [self.actionButton addTarget:self action:@selector(handleActionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.actionButton];
}

-(void)configureShareButton{
    self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 6 - 44, 1, 44, 42)];
    [self.shareButton setImage:[UIImage imageNamed:@"share-icon-dark"] forState:UIControlStateNormal];
    [self addSubview:self.shareButton];
    [self.shareButton addTarget:self action:@selector(handleShareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

-(void)handleShareButtonTapped {
    [self.delegate contentActionBarDidShare:self];
}

-(void)configureRepostSection{
    self.repostLabel = [[UILabel alloc] init];
    self.repostLabel.font = [UIFont notaBoldWithSize:15];
    self.repostLabel.text = @"30";
    self.repostLabel.textColor = [UIColor frescoMediumTextColor];
    
    if (self.repostButton.imageView.image == [UIImage imageNamed:@"repost-icon-green"]) {
        self.repostLabel.textColor = [UIColor frescoGreenColor];
    }
    
    [self.repostLabel sizeToFit];
    
    self.repostLabel.frame = CGRectMake(self.shareButton.frame.origin.x - 6 - self.repostLabel.frame.size.width, 0, self.repostLabel.frame.size.width, self.frame.size.height);
    [self addSubview:self.repostLabel];
    
    self.repostButton = [[UIButton alloc] initWithFrame:CGRectMake(self.repostLabel.frame.origin.x - 36.5, 0, 36.5, self.frame.size.height)];
    [self.repostButton setImage:[UIImage imageNamed:@"repost-icon-gray"]  forState:UIControlStateNormal];
    [self.repostButton setImage:[UIImage imageNamed:@"repost-icon-green"] forState:UIControlStateSelected];
    [self.repostButton setImage:[UIImage imageNamed:@"repost-icon-green"] forState:UIControlStateHighlighted];
    [self.repostButton addTarget:self action:@selector(handleRepostTapped)     forControlEvents:UIControlEventTouchUpInside];
    [self.repostButton addTarget:self action:@selector(handleButtonSelected:)  forControlEvents:UIControlEventTouchDown];
    [self.repostButton addTarget:self action:@selector(handleButtonSelected:)  forControlEvents:UIControlEventTouchDragEnter];
    [self.repostButton addTarget:self action:@selector(handleButtonDrag:)      forControlEvents:UIControlEventTouchDragExit];
    [self addSubview:self.repostButton];
}

-(void)configureLikeSection{
    
    self.likeLabel = [[UILabel alloc] init];
    self.likeLabel.textColor = [UIColor frescoMediumTextColor];
    self.likeLabel.font = [UIFont notaBoldWithSize:15];

    if (self.likeButton.imageView.image == [UIImage imageNamed:@"like-heart-filled"]) {
        self.likeLabel.textColor = [UIColor frescoRedHeartColor];
    }
    
    self.likeLabel.frame = CGRectMake(self.frame.size.width - (16 + self.shareButton.frame.size.width + 16 + self.repostLabel.frame.size.width + 6 + self.repostButton.frame.size.width), 0, 100, 44);

    [self addSubview:self.likeLabel];
    
    self.likeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.likeLabel.frame.origin.x - 36, 0, 36, self.frame.size.height)];
    [self.likeButton setImage:[UIImage imageNamed:@"liked-heart"]        forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"liked-heart-filled"] forState:UIControlStateSelected];
    [self.likeButton setImage:[UIImage imageNamed:@"liked-heart-filled"] forState:UIControlStateHighlighted];
    self.likeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.likeButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.likeButton addTarget:self action:@selector(handleLikeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.likeButton addTarget:self action:@selector(handleButtonSelected:)  forControlEvents:UIControlEventTouchDown];
    [self.likeButton addTarget:self action:@selector(handleButtonSelected:)  forControlEvents:UIControlEventTouchDragEnter];
    [self.likeButton addTarget:self action:@selector(handleButtonDrag:)      forControlEvents:UIControlEventTouchDragExit];
    [self addSubview:self.likeButton];
}

-(void)handleRepostTapped {
    
    CGFloat repost = [self.repostLabel.text floatValue];
    
    if([[self.repostButton imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"repost-icon-green"]]) {
        [self.repostButton setImage:[UIImage imageNamed:@"repost-icon-gray"] forState:UIControlStateNormal];
        self.repostLabel.textColor = [UIColor frescoMediumTextColor];
        repost--;
        
    } else {
        [self.repostButton setImage:[UIImage imageNamed:@"repost-icon-green"] forState:UIControlStateNormal];
        self.repostLabel.textColor = [UIColor frescoGreenColor];
        repost++;
    }
    
    self.repostLabel.text = [NSString stringWithFormat:@"%.0f", repost];
    if (self.delegate) {
        [self.delegate handleRepost:self];
    }
    [self bounceButton:self.repostButton];
}

-(void)handleLikeButtonTapped {
    
    CGFloat likes = [self.likeLabel.text floatValue];
    
    if( [[self.likeButton imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"liked-heart"]]) {
        [self.likeButton setImage:[UIImage imageNamed:@"liked-heart-filled"] forState:UIControlStateNormal];
        self.likeLabel.textColor = [UIColor frescoRedHeartColor];
        likes++;

    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"liked-heart"] forState:UIControlStateNormal];
        self.likeLabel.textColor = [UIColor frescoMediumTextColor];
        likes--;
    }
    
    self.likeLabel.text = [NSString stringWithFormat:@"%.0f", likes];
    
    [self bounceButton:self.likeButton];
    
    if (self.delegate) {
        [self.delegate handleLike:self];
    }
}

-(void)handleHeartState:(BOOL)state {
    if(state) {
        [self.likeButton setImage:[UIImage imageNamed:@"liked-heart-filled"] forState:UIControlStateNormal];
        self.likeLabel.textColor = [UIColor frescoRedHeartColor];

    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"liked-heart"] forState:UIControlStateNormal];
        self.likeLabel.textColor = [UIColor frescoMediumTextColor];
    }
}

-(void)handleRepostState:(BOOL)state {
    if(state) {
        [self.repostButton setImage:[UIImage imageNamed:@"repost-icon-gray"] forState:UIControlStateNormal];
    } else {
        [self.repostButton setImage:[UIImage imageNamed:@"repost-icon-green"] forState:UIControlStateNormal];
    }
}

-(void)handleActionButtonTapped{
    [self.delegate contentActionBarDidSelectActionButton:self];
}

-(void)actionButtonTitleNeedsUpdate{
    [self.actionButton setTitle:[self.delegate titleForActionButton] forState:UIControlStateNormal];
    [self.actionButton sizeToFit];
    [self.actionButton setSizeWithSize:CGSizeMake(self.actionButton.frame.size.width, self.frame.size.height)];
}


-(void)handleButtonSelected:(UIButton*)button{
    [UIView animateWithDuration:0.15 delay:0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
        
        button.transform = CGAffineTransformMakeScale(1.1, 1.1);
        
    } completion:nil];
}

-(void)handleButtonDrag:(UIButton*)button{
    [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
        
        button.transform = CGAffineTransformMakeScale(1, 1);
        
    } completion:nil];
}


-(void)bounceButton:(UIButton *)button{
    [UIView animateWithDuration:0.125 delay:0.0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        
        button.transform = CGAffineTransformMakeScale(1.15, 1.15);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.125 delay:0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
            
            button.transform = CGAffineTransformMakeScale(0.95, 0.95);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.125 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                
                button.transform = CGAffineTransformMakeScale(1, 1);
                
            } completion:nil];
        }];
    }];
}

-(void)handleRepostAmount:(NSInteger)amount {
    if (amount == 0) {
        self.repostLabel.text = @"0";
    }
    
    self.repostLabel.text = [NSString stringWithFormat:@"%lu", (long)amount];
}

@end
