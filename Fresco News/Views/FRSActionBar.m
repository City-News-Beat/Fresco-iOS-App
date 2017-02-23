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
}

-(void)configureActionButton {
    [self.actionButton setTitle:[self.delegate titleForActionButton] forState:UIControlStateNormal];
}



#pragma mark - Public

-(void)updateTitle {
    [self.actionButton setTitle:[self.delegate titleForActionButton] forState:UIControlStateNormal];
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



@end















