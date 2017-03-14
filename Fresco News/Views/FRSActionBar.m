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
#import "FRSGallery.h"
#import "FRSStory.h"
#import "FRSGalleryExpandedViewController.h"
#import "FRSStoryDetailViewController.h"
#import "FRSGalleryManager.h"
#import "FRSStoryManager.h"
#import "FRSSocialHandler.h"


@interface FRSActionBar ()

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel  *likeLabel;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UILabel  *repostLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) FRSGallery *gallery;
@property (weak, nonatomic) FRSStory *story;

@end

@implementation FRSActionBar

#define HEIGHT 44

#define HEART @"liked-heart"
#define HEART_FILL @"liked-heart-filled"
#define REPOST @"repost-icon-gray"
#define REPOST_FILL @"repost-icon-green"
#define GALLERY_ID @"gallery_id"


- (instancetype)initWithOrigin:(CGPoint)origin delegate:(id<FRSActionBarDelegate>)delegate {
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, [UIScreen mainScreen].bounds.size.width, HEIGHT)];

    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        
        self.frame = CGRectMake(origin.x, origin.y, [UIScreen mainScreen].bounds.size.width, HEIGHT);
        self.delegate = delegate;
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        
    }
    return self;
}

-(void)configureWithObject:(id)object {
    
    if ([object isKindOfClass:[FRSGallery class]]) {
        self.gallery = (FRSGallery *)object;
    } else if ([object isKindOfClass:[FRSStory class]]) {
        self.story = (FRSStory *)object;
    } else {
        NSLog(@"Unable to identify object for action bar: %@", object);
    }
    
    [self configureActionButton];
    [self configureSocialButtons];
    [self updateLabels];
}

#pragma mark - Action Button

-(void)configureActionButton {
    NSString *actionButtonTitle;
    
    if (self.gallery) {
        int comments = [[self.gallery valueForKey:@"comments"] intValue];
        
        if (comments == 1) {
            actionButtonTitle = [NSString stringWithFormat:@"%d COMMENT", comments];
        } else if (comments == 0) {
            actionButtonTitle = @"READ MORE";
        } else {
            actionButtonTitle = [NSString stringWithFormat:@"%d COMMENTS", comments];
        }
        
    } else if (self.story) {
        actionButtonTitle = @"READ MORE";
    }

    [self.actionButton setTitle:actionButtonTitle forState:UIControlStateNormal];

}

-(void)updateTitle {
    [UIView setAnimationsEnabled:NO];
    [self.actionButton setTitle:[self.delegate titleForActionButton] forState:UIControlStateNormal];
    [self.actionButton layoutIfNeeded]; // Disable system animation.
    [UIView setAnimationsEnabled:YES];
}


#pragma mark - Likes / Reposts

-(void)updateLabels {
    
    self.likeLabel.userInteractionEnabled = YES;
    self.repostLabel.userInteractionEnabled = YES;

    NSInteger likes = 0;
    NSInteger reposts = 0;
    
    BOOL liked = NO;
    BOOL reposted = NO;
    
    if (self.gallery) {
        likes = [[self.gallery valueForKey:LIKES] integerValue];
        liked = [[self.gallery valueForKey:LIKED] boolValue];
        reposts = [[self.gallery valueForKey:REPOSTS] integerValue];
        reposted = [[self.gallery valueForKey:REPOSTED] boolValue];

    } else if (self.story) {
        likes = [[self.story valueForKey:LIKES] integerValue];
        liked = [[self.story valueForKey:LIKED] boolValue];
        reposts = [[self.story valueForKey:REPOSTS] integerValue];
        reposted = [[self.story valueForKey:REPOSTED] boolValue];
    }
    
    [self updateUIForLabel:self.likeLabel button:self.likeButton imageName:HEART selectedImageName:HEART_FILL count:likes enabled:liked color:[UIColor frescoRedColor]];
    
    [self updateUIForLabel:self.repostLabel button:self.repostButton imageName:REPOST selectedImageName:REPOST_FILL count:reposts enabled:reposted color:[UIColor frescoGreenColor]];
}

-(void)updateUIForLabel:(UILabel *)label button:(UIButton *)button imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName count:(NSInteger)count enabled:(BOOL)enabled color:(UIColor *)color {
    
    if (count >= 0) {
        label.text = [NSString stringWithFormat:@"%ld", count];
    } else {
        label.text = @"0";
    }
    
    if (enabled && ![label.text isEqualToString:@"0"]) {
        [button setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateNormal];
        label.textColor = color;
        
    } else {
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        label.textColor = [UIColor frescoMediumTextColor];
    }
    
}

-(void)configureSocialButtons {
    
    [self configureSocialButton:self.likeButton withImageName:HEART selectedImageName:HEART_FILL];
    
    [self configureSocialButton:self.repostButton withImageName:REPOST selectedImageName:REPOST_FILL];
}

-(void)configureSocialButton:(UIButton *)button withImageName:(NSString *)image selectedImageName:(NSString *)selectedImage {
    
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateHighlighted];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:button];
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
        defaultImageName  = HEART;
        selectedImageName = HEART_FILL;
        color = [UIColor frescoRedColor];
        
    } else {
        count = [self.repostLabel.text integerValue];
        socialButton = self.repostButton;
        socialLabel  = self.repostLabel;
        defaultImageName  = REPOST;
        selectedImageName = REPOST_FILL;
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
}

- (void)setCurrentUser:(BOOL)isAuth {
    if (isAuth) {
        self.repostButton.userInteractionEnabled = NO;
    } else {
        self.repostButton.userInteractionEnabled = YES;
    }
}


#pragma mark - Actions

- (IBAction)actionButtonTapped:(id)sender {
    if (self.delegate) {
        [self.delegate handleActionButtonTapped:sender];
    }
}

- (IBAction)likeTapped:(id)sender {
    
    [self handleSocialStateForButton:self.likeButton];
    
    if (self.gallery) {
        if ([[self.gallery valueForKey:LIKED] boolValue]) {
            [FRSTracker track:galleryUnliked parameters:@{GALLERY_ID : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"unliked_from" : [self stringToTrack]}];
            [FRSSocialHandler unlikeGallery:self.gallery completion:^(id responseObject, NSError *error) {
                if (error) {
                    [FRSSocialHandler likeGallery:self.gallery completion:nil];
                }
            }];
        } else {
            [FRSTracker track:galleryLiked parameters:@{GALLERY_ID : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"liked_from" : [self stringToTrack]}];
            [FRSSocialHandler likeGallery:self.gallery completion:^(id responseObject, NSError *error) {
                if (error) {
                    [FRSSocialHandler unlikeGallery:self.gallery completion:nil];
                }
            }];
        }
        
    } else if (self.story) {
        if ([[self.story valueForKey:LIKED] boolValue]) {
            [FRSSocialHandler unlikeStory:self.story completion:^(id responseObject, NSError *error) {
                if (error) {
                    [FRSSocialHandler likeStory:self.story completion:nil];
                }
            }];
        } else {
            [FRSSocialHandler likeStory:self.story completion:^(id responseObject, NSError *error) {
                if (error) {
                    [FRSSocialHandler unlikeStory:self.story completion:nil];
                }
            }];
        }
    }
}

- (IBAction)repostTapped:(id)sender {
    
    [self handleSocialStateForButton:self.repostButton];
    
    if (self.gallery) {
        if ([[self.gallery valueForKey:REPOSTED] boolValue]) {
            [FRSTracker track:galleryUnreposted parameters:@{GALLERY_ID : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"un_reposted_from" : [self stringToTrack]}];
            [FRSSocialHandler unrepostGallery:self.gallery completion:^(id responseObject, NSError *error) {
                if (error) {
                    [FRSSocialHandler repostGallery:self.gallery completion:nil];
                }
            }];
        } else {
            [FRSTracker track:galleryReposted parameters:@{GALLERY_ID : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"reposted_from" : [self stringToTrack]}];
            [FRSSocialHandler repostGallery:self.gallery completion:^(id responseObject, NSError *error) {
                if (error) {
                    [FRSSocialHandler unrepostGallery:self.gallery completion:nil];
                }
            }];
        }
    } else if (self.story) {
        if ([[self.story valueForKey:REPOSTED] boolValue]) {
            [FRSSocialHandler unrepostStory:self.story completion:^(id responseObject, NSError *error) {
                if (error) {
                    [FRSSocialHandler repostStory:self.story completion:nil];
                }
            }];
        } else {
            [FRSSocialHandler repostStory:self.story completion:^(id responseObject, NSError *error) {
                if (error) {
                    [FRSSocialHandler unrepostStory:self.story completion:nil];
                }
            }];
        }
    }
}


- (IBAction)likeLabelTapped:(id)sender {
    if (self.delegate) {
        [self.delegate handleLikeLabelTapped:self];
    }
}

- (IBAction)repostLabelTapped:(id)sender {
    if (self.delegate) {
        [self.delegate handleRepostLabelTapped:self];
    }
}

- (IBAction)shareTapped:(id)sender {
    
    NSString *shareString;

    if (self.gallery) {
        shareString = [NSString stringWithFormat:@"Check out this gallery from Fresco News!!\nhttps://fresconews.com/gallery/%@", self.gallery.uid];
        [FRSTracker track:galleryShared parameters:@{GALLERY_ID : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"shared_from" : [self stringToTrack]}];
        
    } else if (self.story) {
        shareString = [NSString stringWithFormat:@"Check out this story from Fresco News!!\nhttps://fresconews.com/story/%@", self.story.uid];
    }
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareString] applicationActivities:nil];
    [[self.navigationController.viewControllers firstObject] presentViewController:activityViewController animated:YES completion:nil];
}


#pragma mark - Analytics

/**
 This method sets the string that should be tracked. (`opened_from_*`, `liked_from_*`, etc.)

 @return NSString screen that should be tracked.
 */
- (NSString *)stringToTrack {
    
    switch (self.trackedScreen) {
            
        case FRSTrackedScreenUnknown: // Enum defaults to 0 if not defined, avoid setting default to highlights.
            return @"unknown";
            break;
            
        case FRSTrackedScreenHighlights:
            return @"highlights";
            break;
            
        case FRSTrackedScreenStories:
            return @"stories";
            break;
            
        case FRSTrackedScreenProfile:
            return @"profile";
            break;
            
        case FRSTrackedScreenSearch:
            return @"search";
            break;
            
        case FRSTrackedScreenFollowing:
            return @"following";
            break;
            
        case FRSTrackedScreenPush:
            return @"push";
            break;
            
        case FRSTrackedScreenDetail:
            return @"detail";
            break;
            
        default:
            return @"unknown";
            break;
    }
}

@end
