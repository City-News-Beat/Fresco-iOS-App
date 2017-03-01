//
//  FRSActionBar.m
//  Fresco
//
//  Created by Omar Elfanek on 2/23/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSActionBar.h"
#import "FRSGalleryView.h"
#import "UIView+Helpers.h"

@interface FRSActionBar ()

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel  *likeLabel;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UILabel  *repostLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@end

@implementation FRSActionBar

#define HEIGHT 44

- (instancetype)initWithOrigin:(CGPoint)origin delegate:(id<FRSActionBarDelegate>)delegate {
    self = [super init];

    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        
        self.frame = CGRectMake(origin.x, origin.y, [UIScreen mainScreen].bounds.size.width, HEIGHT);
        self.delegate = delegate;
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        
        [self configureUI];
        
        
    }
    return self;
}



#pragma mark - Private

-(void)configureUI {
    [self configureActionButton];
    [self configureSocialButtons];
    [self configureLabels];
}

-(void)configureActionButton {
    [self.actionButton setTitle:[self.delegate titleForActionButton] forState:UIControlStateNormal];
}

-(void)configureLabels {
    self.likeLabel.userInteractionEnabled = YES;
    self.repostLabel.userInteractionEnabled = YES;
}

-(void)configureSocialButtons {
    
    [self configureSocialButton:self.likeButton withImageName:@"liked-heart" selectedImageName:@"liked-heart-filled" tapAction:@selector(handleLikeButtonTapped) selectedAction:@selector(handleButtonSelected:) dragAction:@selector(handleButtonDrag:)];
    
    [self configureSocialButton:self.repostButton withImageName:@"repost-icon-gray" selectedImageName:@"repost-icon-green" tapAction:@selector(handleRepostButtonTapped) selectedAction:@selector(handleButtonSelected:) dragAction:@selector(handleButtonDrag:)];
}

-(void)configureSocialButton:(UIButton *)button withImageName:(NSString *)image selectedImageName:(NSString *)selectedImage tapAction:(SEL)tapAction selectedAction:(SEL)selectedAction dragAction:(SEL)dragAction {
    
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateHighlighted];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.contentMode = UIViewContentModeScaleAspectFit;
    [button addTarget:self action:tapAction forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:selectedAction forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:selectedAction forControlEvents:UIControlEventTouchDragEnter];
    [button addTarget:self action:dragAction forControlEvents:UIControlEventTouchDragExit];
    [self addSubview:button];
}

- (void)handleLikeButtonTapped {
    [self handleSocialStateForButton:self.likeButton];
}

-(void)handleRepostButtonTapped {
    [self handleSocialStateForButton:self.repostButton];
}

-(void)handleSocialStateForButton:(UIButton *)button {
    
    BOOL isLikeButton = [button isEqual:self.likeButton] ? YES : NO;

    NSInteger count;
    UIButton *socialButton;
    UILabel  *socialLabel;
    NSString *defaultImageName;
    NSString *selectedImageName;
    UIColor  *color;
    
    if (isLikeButton) {
        count = [self.likeLabel.text integerValue];
        socialButton = self.likeButton;
        socialLabel  = self.likeLabel;
        defaultImageName  = @"liked-heart";
        selectedImageName = @"liked-heart-filled";
        color = [UIColor frescoRedColor];
        
    } else {
        count = [self.repostLabel.text integerValue];
        socialButton = self.repostButton;
        socialLabel  = self.repostLabel;
        defaultImageName  = @"repost-icon-gray";
        selectedImageName = @"repost-icon-green";
        color = [UIColor frescoGreenColor];
    }
    
    if ([[socialButton imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:defaultImageName]]) {
        [socialButton setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateNormal];
        socialLabel.textColor = color;
        count++;
        
    } else {
        [socialButton setImage:[UIImage imageNamed:defaultImageName] forState:UIControlStateNormal];
        socialLabel.textColor = [UIColor frescoMediumTextColor];
        count--;
    }
    
    socialLabel.text = [NSString stringWithFormat:@"%ld", count];
    [self bounceButton:button];
}

- (void)handleButtonSelected:(UIButton *)button {
//    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        button.transform = CGAffineTransformMakeScale(1.1, 1.1);
//    } completion:nil];
}

- (void)handleButtonDrag:(UIButton *)button {
//    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        button.transform = CGAffineTransformMakeScale(1, 1);
//    } completion:nil];
}

- (void)bounceButton:(UIButton *)button {
//    [UIView animateWithDuration:0.125 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        button.transform = CGAffineTransformMakeScale(1.15, 1.15);
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.125 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            button.transform = CGAffineTransformMakeScale(0.95, 0.95);
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.125 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                button.transform = CGAffineTransformMakeScale(1, 1);
//            } completion:nil];
//        }];
//    }];
}



#pragma mark - Public

-(void)updateTitle {
    [UIView setAnimationsEnabled:NO];
    [self.actionButton setTitle:[self.delegate titleForActionButton] forState:UIControlStateNormal];
    [self.actionButton layoutIfNeeded]; // This disables the default fade animation when setting a system button title.
    [UIView setAnimationsEnabled:YES];
}


- (void)setCurrentUser:(BOOL)isAuth {
    if (isAuth) {
        self.repostButton.userInteractionEnabled = NO;
    } else {
        self.repostButton.userInteractionEnabled = YES;
    }
}



#pragma mark - Delegate

- (IBAction)actionButtonTapped:(id)sender {
    [self.delegate handleActionButtonTapped:self];
}

- (IBAction)likeTapped:(id)sender {
    [self.delegate handleLike:self];
}

- (IBAction)likeLabelTapped:(id)sender {
    [self.delegate handleLikeLabelTapped:self];
}

- (IBAction)repostTapped:(id)sender {
    [self.delegate handleRepost:self];
}

- (IBAction)repostLabelTapped:(id)sender {
    [self.delegate handleRepostLabelTapped:self];
}

- (IBAction)shareTapped:(id)sender {
    [self.delegate handleShare:self];
}

-(void)handleHeartState:(BOOL)enabled {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (enabled && ![self.likeLabel.text isEqualToString:@"0"]) {
            [self.likeButton setImage:[UIImage imageNamed:@"liked-heart-filled"] forState:UIControlStateNormal];
            self.likeLabel.textColor = [UIColor frescoRedColor];
            
        } else {
            [self.likeButton setImage:[UIImage imageNamed:@"liked-heart"] forState:UIControlStateNormal];
            self.likeLabel.textColor = [UIColor frescoMediumTextColor];
        }
    });
}

-(void)handleHeartAmount:(NSInteger)amount {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (amount >= 0) {
            self.likeLabel.text = [NSString stringWithFormat:@"%lu", (long)amount];
        } else {
            self.likeLabel.text = @"0";
        }
    });
}

-(void)handleRepostState:(BOOL)enabled {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (enabled && ![self.repostLabel.text isEqualToString:@"0"]) {
            [self.repostButton setImage:[UIImage imageNamed:@"repost-icon-green"] forState:UIControlStateNormal];
            self.repostLabel.textColor = [UIColor frescoGreenColor];
        } else {
            [self.repostButton setImage:[UIImage imageNamed:@"repost-icon-gray"] forState:UIControlStateNormal];
            self.repostLabel.textColor = [UIColor frescoMediumTextColor];
        }
    });
}

-(void)handleRepostAmount:(NSInteger)amount {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (amount >= 0) {
            self.repostLabel.text = [NSString stringWithFormat:@"%lu", (long)amount];
        } else {
            self.repostLabel.text = @"0";
        }
    });
}

@end
