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

@property (weak, nonatomic) FRSGallery *gallery;
@property (weak, nonatomic) FRSStory *story;

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
//        NSLog(@"%@", self.gallery.uid);
    } else if ([object isKindOfClass:[FRSStory class]]) {
        self.story = (FRSStory *)object;
//        NSLog(@"%@", self.story.uid);
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
    [self.actionButton layoutIfNeeded]; // This disables the default fade animation when setting a system button title.
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
        likes = [[self.gallery valueForKey:@"likes"] integerValue];
        liked = [[self.gallery valueForKey:@"liked"] boolValue];
        reposts = [[self.gallery valueForKey:@"reposts"] integerValue];
        reposted = [[self.gallery valueForKey:@"reposted"] boolValue];

    } else if (self.story) {
        likes = [[self.story valueForKey:@"likes"] integerValue];
        liked = [[self.story valueForKey:@"liked"] boolValue];
        reposts = [[self.story valueForKey:@"reposts"] integerValue];
        reposted = [[self.story valueForKey:@"reposted"] boolValue];
    }
    
    [self updateUIForLabel:self.likeLabel button:self.likeButton imageName:@"liked-heart" selectedImageName:@"liked-heart-filled" count:likes enabled:liked color:[UIColor frescoRedColor]];
    
    [self updateUIForLabel:self.repostLabel button:self.repostButton imageName:@"repost-icon-gray" selectedImageName:@"repost-icon-green" count:reposts enabled:reposted color:[UIColor frescoGreenColor]];
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


// TODO: Abstract all the social logic into a FRSSocialController and add all social actions (like/repost/follow etc.)

-(void)saveLike:(BOOL)didLike value:(NSInteger)value {
    
    if (self.gallery) {
        if (didLike) {
            [self.gallery setValue:[NSNumber numberWithInteger:value] forKey:@"likes"];
            [self.gallery setValue:@1 forKey:@"liked"];
        } else {
            [self.gallery setValue:[NSNumber numberWithInteger:value] forKey:@"likes"];
            [self.gallery setValue:@0 forKey:@"liked"];
        }
    } else if (self.story) {
        if (didLike) {
            [self.story setValue:[NSNumber numberWithInteger:value] forKey:@"likes"];
            [self.story setValue:@1 forKey:@"liked"];
        } else {
            [self.story setValue:[NSNumber numberWithInteger:value] forKey:@"likes"];
            [self.story setValue:@0 forKey:@"liked"];
        }
    } else {
        NSLog(@"Unable to save likes");
    }
}

-(void)saveRepost:(BOOL)didRepost value:(NSInteger)value {
    if (self.gallery) {
        if (didRepost) {
            [self.gallery setValue:[NSNumber numberWithInteger:value] forKey:@"reposts"];
            [self.gallery setValue:@0 forKey:@"reposted"];
        } else {
            [self.gallery setValue:[NSNumber numberWithInteger:value] forKey:@"reposts"];
            [self.gallery setValue:@1 forKey:@"reposted"];
        }
    } else if (self.story) {
        if (didRepost) {
            [self.story setValue:[NSNumber numberWithInteger:value] forKey:@"reposts"];
            [self.story setValue:@0 forKey:@"reposted"];
        } else {
            [self.story setValue:[NSNumber numberWithInteger:value] forKey:@"reposts"];
            [self.story setValue:@1 forKey:@"reposted"];
        }
    } else {
        NSLog(@"Unable to save reposts");
    }
}


// TODO: These methods can be refined
- (IBAction)likeTapped:(id)sender {
    
    // Update like button and label UI
    [self handleSocialStateForButton:self.likeButton];
    
    if (self.gallery) {
        
        // Using __block to access storyLikes in the completion block
        __block NSInteger galleryLikes = [[self.gallery valueForKey:@"likes"] integerValue];
        
        // Check to see if user has already likes
        if ([[self.gallery valueForKey:@"liked"] boolValue]) {
            
            // Track unlike action
            [FRSTracker track:galleryUnliked parameters:@{@"gallery_id" : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"unliked_from" : [self stringToTrack]}];

            // Subtract 1 like on the gallery
            galleryLikes--;
            [self saveLike:NO value:galleryLikes];
            
            // Update on the API and revert on failure
            [[FRSGalleryManager sharedInstance] unlikeGallery:self.gallery completion:^(id responseObject, NSError *error) {
                
                [self logError:error andResponse:responseObject]; // Debug

                if (error) {
                    galleryLikes++;
                    [self saveLike:YES value:galleryLikes];
                }
            }];
        } else {
            
            // Track like action
            [FRSTracker track:galleryLiked parameters:@{@"gallery_id" : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"liked_from" : [self stringToTrack]}];
            
            // Add 1 like on the gallery
            galleryLikes++;
            [self saveLike:YES value:galleryLikes];
            
            // Update on the API and revert on failure
            [[FRSGalleryManager sharedInstance] likeGallery:self.gallery completion:^(id responseObject, NSError *error) {
                
                [self logError:error andResponse:responseObject]; // Debug

                if (error) {
                    galleryLikes--;
                    [self saveLike:NO value:galleryLikes];
                }
            }];
        }
        
        
    } else if (self.story) {
        
        // Using __block to access storyLikes in the completion block
        __block NSInteger storyLikes = [[self.story valueForKey:@"likes"] integerValue];
        
        // Check to see if user has already liked
        if ([[self.story valueForKey:@"liked"] boolValue]) {
            
            // Subtract 1 like from the story
            storyLikes--;
            [self saveLike:NO value:storyLikes];
            
            // Update on the API and revert on failure
            [[FRSStoryManager sharedInstance] unlikeStory:self.story completion:^(id responseObject, NSError *error) {
                
                [self logError:error andResponse:responseObject]; // Debug

                if (error) {
                    storyLikes++;
                    [self saveLike:YES value:storyLikes];
                }
            }];
        } else {
            
            // Add 1 like to the story
            storyLikes++;
            [self saveLike:YES value:storyLikes];
            
            // Update on the API and revert on failure
            [[FRSStoryManager sharedInstance] likeStory:self.story completion:^(id responseObject, NSError *error) {
                
                [self logError:error andResponse:responseObject]; // Debug

                if (error) {
                    storyLikes--;
                    [self saveLike:NO value:storyLikes];
                }
            }];
        }
        
        // Update story object for Core Data
        [self.story setValue:[NSNumber numberWithInteger:storyLikes] forKey:@"likes"];
    }
    
    [self save];
}

- (IBAction)repostTapped:(id)sender {
    
    // Update repost button and label UI
    [self handleSocialStateForButton:self.repostButton];
    
    if (self.gallery) {
        
        // Using __block to access storyReposts in the response block
        __block NSInteger galleryReposts = [[self.gallery valueForKey:@"reposts"] integerValue];
        
        // Check to see if user has already reposted
        if ([[self.gallery valueForKey:@"reposted"] boolValue]) {
            
            // Track unrepost action
            [FRSTracker track:galleryUnreposted parameters:@{@"gallery_id" : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"un_reposted" : [self stringToTrack]}];
            
            // Subtract 1 repost the gallery
            galleryReposts--;
            [self saveRepost:NO value:galleryReposts];
            
            // Update on the API and revert on failure
            [[FRSGalleryManager sharedInstance] unrepostGallery:self.gallery completion:^(id responseObject, NSError *error) {
                
                [self logError:error andResponse:responseObject]; // Debug

                if (error) {
                    galleryReposts++;
                    [self saveRepost:YES value:galleryReposts];
                }
            }];
        } else {
            
            // Track repost action
            [FRSTracker track:galleryReposted parameters:@{@"gallery_id" : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"reposted" : [self stringToTrack]}];
            
            // Add 1 repost to the gallery
            galleryReposts++;
            [self saveRepost:YES value:galleryReposts];
            
            // Update on the API and revert on failure
            [[FRSGalleryManager sharedInstance] repostGallery:self.gallery completion:^(id responseObject, NSError *error) {
                
                [self logError:error andResponse:responseObject]; // Debug

                if (error) {
                    galleryReposts--;
                    [self saveRepost:NO value:galleryReposts];
                }
            }];
        }
        
        // Update story object in Core Data
        [self.story setValue:[NSNumber numberWithInteger:galleryReposts] forKey:@"reposts"];
        
    } else if (self.story) {
        
        // Using __block to access storyReposts in the response block
        __block NSInteger storyReposts = [[self.story valueForKey:@"reposts"] integerValue];
        
        // Check to see if user has already reposted
        if ([[self.story valueForKey:@"reposted"] boolValue]) {
            
            // Subtract 1 repost from the story
            storyReposts--;
            [self saveRepost:NO value:storyReposts];

            // Update on the API and revert on failure
            [[FRSStoryManager sharedInstance] unrepostStory:self.story completion:^(id responseObject, NSError *error) {
                
                [self logError:error andResponse:responseObject]; // Debug
                
                if (error) {
                    storyReposts++;
                    [self saveRepost:YES value:storyReposts];
                }
            }];
        } else {
            
            // Add 1 repost to the story
            storyReposts++;
            
            // Update on the API and revert on failure
            [[FRSStoryManager sharedInstance] repostStory:self.story completion:^(id responseObject, NSError *error) {
                
                [self logError:error andResponse:responseObject]; // Debug
                
                if (error) {
                    storyReposts--;
                    [self saveRepost:NO value:storyReposts];
                }
            }];
        }
        
        // Update story object in Core Data
        [self.story setValue:[NSNumber numberWithInteger:storyReposts] forKey:@"reposts"];
    }
    
    [self save];
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
        [FRSTracker track:galleryShared parameters:@{@"gallery_id" : (self.gallery.uid != nil) ? self.gallery.uid : @"", @"shared_from" : [self stringToTrack]}];
        
    } else if (self.story) {
        shareString = [NSString stringWithFormat:@"Check out this story from Fresco News!!\nhttps://fresconews.com/story/%@", self.story.uid];
    }
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareString] applicationActivities:nil];
    [[self.navigationController.viewControllers firstObject] presentViewController:activityViewController animated:YES completion:nil];
}

-(void)save {
    
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];

    
    [delegate.coreDataController.managedObjectContext performBlock:^{
        NSError *saveError;

        if (![[delegate managedObjectContext] save:&saveError]) {
            NSLog(@"ERROR: %@", saveError);
        } else {
            NSLog(@"SAVED");
        }
    }];  
}

// DEBUG
-(void)logError:(NSError *)error andResponse:(id)response {
    NSLog(@"ERROR: %@, RESPONSE: %@", error, response);
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
