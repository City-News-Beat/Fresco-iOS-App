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


@interface FRSActionBar ()

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel  *likeLabel;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UILabel  *repostLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (strong, nonatomic) FRSGallery *gallery;
@property (strong, nonatomic) FRSStory *story;

@end

@implementation FRSActionBar

#define HEIGHT 44

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
    [self configureLabels];
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
    [self.actionButton layoutIfNeeded]; // This disables the default fade animation when setting a system button title.
    [UIView setAnimationsEnabled:YES];
}


#pragma mark - Likes / Reposts

-(void)configureLabels {
    
    self.likeLabel.userInteractionEnabled = YES;
    self.repostLabel.userInteractionEnabled = YES;

    NSNumber *likes = 0;
    NSNumber *reposts = 0;
    
    BOOL liked = NO;
    BOOL reposted = NO;
    
    if (self.gallery) {
        likes = [self.gallery valueForKey:@"likes"];
        liked = [[self.gallery valueForKey:@"liked"] boolValue];
        reposts = [self.gallery valueForKey:@"reposts"];
        reposted = [[self.gallery valueForKey:@"reposted"] boolValue];

    } else if (self.story) {
        likes = [self.story valueForKey:@"likes"];
        liked = [[self.story valueForKey:@"liked"] boolValue];
        reposts = [self.story valueForKey:@"reposts"];
        reposted = [[self.story valueForKey:@"reposted"] boolValue];
    }
    
    [self updateUIForLabel:self.likeLabel button:self.likeButton imageName:@"liked-heart" selectedImageName:@"liked-heart-filled" count:likes enabled:liked color:[UIColor frescoRedColor]];
    
    [self updateUIForLabel:self.repostLabel button:self.repostButton imageName:@"repost-icon-gray" selectedImageName:@"repost-icon-green" count:reposts enabled:reposted color:[UIColor frescoGreenColor]];
}

-(void)updateUIForLabel:(UILabel *)label button:(UIButton *)button imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName count:(NSNumber *)count enabled:(BOOL)enabled color:(UIColor *)color {
    
    if (count >= 0) {
        label.text = [NSString stringWithFormat:@"%@", count];
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
    
    [self configureSocialButton:self.likeButton withImageName:@"liked-heart" selectedImageName:@"liked-heart-filled"];
    
    [self configureSocialButton:self.repostButton withImageName:@"repost-icon-gray" selectedImageName:@"repost-icon-green"];
}

-(void)configureSocialButton:(UIButton *)button withImageName:(NSString *)image selectedImageName:(NSString *)selectedImage {
    
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateHighlighted];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.contentMode = UIViewContentModeScaleAspectFit;
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
    [self handleLikeButtonTapped];
    
    if (self.gallery) {
        
        NSLog(@"LIKED_FROM: %@", [self stringToTrack]);
    
        if ([[self.gallery valueForKey:@"liked"] boolValue]) {
            
            [FRSTracker track:galleryUnliked parameters:@{@"gallery_id" : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"unliked_from" : [self stringToTrack]}];

            self.gallery.likes = @([self.gallery.likes intValue] - 1);
            [[FRSGalleryManager sharedInstance] unlikeGallery:self.gallery completion:^(id responseObject, NSError *error) {
                if (error) {
                    self.gallery.likes = @([self.gallery.likes intValue] + 1);
                }
            }];
        } else {
            
            [FRSTracker track:galleryLiked parameters:@{@"gallery_id" : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"liked_from" : [self stringToTrack]}];
            
            self.gallery.likes = @([self.gallery.likes intValue] + 1);
            [[FRSGalleryManager sharedInstance] likeGallery:self.gallery completion:^(id responseObject, NSError *error) {
                if (error) {
                    self.gallery.likes = @([self.gallery.likes intValue] - 1);
                }
            }];
        }
    } else if (self.story) {
        
        __block NSInteger storyLikes = (long)[self.story valueForKey:@"likes"];
        
        if ([[self.story valueForKey:@"liked"] boolValue]) {
            storyLikes--;
            [[FRSStoryManager sharedInstance] unlikeStory:self.story completion:^(id responseObject, NSError *error) {
                if (error) {
                    storyLikes++;
                    [self.story setValue:[NSNumber numberWithInteger:storyLikes] forKey:@"likes"];
                }
            }];
        } else {
            storyLikes++;
            [[FRSStoryManager sharedInstance] likeStory:self.story completion:^(id responseObject, NSError *error) {
                if (error) {
                    storyLikes--;
                    [self.story setValue:[NSNumber numberWithInteger:storyLikes] forKey:@"likes"];
                }
            }];
        }
        
        [self.story setValue:[NSNumber numberWithInteger:storyLikes] forKey:@"likes"];
    }
}

- (IBAction)repostTapped:(id)sender {
    [self handleRepostButtonTapped];
    
    if (self.gallery) {
        
        NSLog(@"REPOSTED_FROM: %@", [self stringToTrack]);
        
        if ([[self.gallery valueForKey:@"reposts"] boolValue]) {
            
            [FRSTracker track:galleryUnreposted parameters:@{@"gallery_id" : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"un_reposted" : [self stringToTrack]}];
            
            self.gallery.reposts = @([self.gallery.reposts intValue] - 1);
            [[FRSGalleryManager sharedInstance] unrepostGallery:self.gallery completion:^(id responseObject, NSError *error) {
                if (error) {
                    self.gallery.reposts = @([self.gallery.reposts intValue] + 1);
                }
            }];
        } else {
            
            [FRSTracker track:galleryReposted parameters:@{@"gallery_id" : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"reposted" : [self stringToTrack]}];
            
            self.gallery.reposts = @([self.gallery.reposts intValue] + 1);
            [[FRSGalleryManager sharedInstance] repostGallery:self.gallery completion:^(id responseObject, NSError *error) {
                if (error) {
                    self.gallery.reposts = @([self.gallery.reposts intValue] - 1);
                }
            }];
        }
    } else if (self.story) {
        
        __block NSInteger storyReposts = (long)[self.story valueForKey:@"reposts"];
        
        if ([[self.story valueForKey:@"reposts"] boolValue]) {
            storyReposts--;
            [[FRSStoryManager sharedInstance] unrepostStory:self.story completion:^(id responseObject, NSError *error) {
                if (error) {
                    storyReposts++;
                    [self.story setValue:[NSNumber numberWithInteger:storyReposts] forKey:@"reposts"];
                }
            }];
        } else {
            storyReposts++;
            [[FRSStoryManager sharedInstance] repostStory:self.story completion:^(id responseObject, NSError *error) {
                if (error) {
                    storyReposts--;
                    [self.story setValue:[NSNumber numberWithInteger:storyReposts] forKey:@"reposts"];
                }
            }];
        }
        
        [self.story setValue:[NSNumber numberWithInteger:storyReposts] forKey:@"reposts"];
    }
}


- (IBAction)likeLabelTapped:(id)sender {
    [self.delegate handleLikeLabelTapped:self];
}

- (IBAction)repostLabelTapped:(id)sender {
    [self.delegate handleRepostLabelTapped:self];
}

- (IBAction)shareTapped:(id)sender {
    
    NSLog(@"SHARED_FROM: %@", [self stringToTrack]); // Check app for other places where we might be tracking share (shareBlock implementations in view controllers)
    
    // DEBUG: Gallery objects data field is returning <fault>
    //    NSLog(@"gallery.uid: %@", self.gallery.uid);
    //    NSLog(@"gallery.uid: %@", [self.gallery valueForKey:@"uid"]);
    NSString *shareString;

    if (self.gallery) {
        shareString = [NSString stringWithFormat:@"Check out this gallery from Fresco News!!\nhttps://fresconews.com/gallery/%@", self.gallery.uid];
        [FRSTracker track:galleryShared parameters:@{@"gallery_id" : self.gallery.uid, @"shared_from" : [self stringToTrack]}];
        
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
