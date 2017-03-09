//
//  FRSActionBar.h
//  Fresco
//
//  Created by Omar Elfanek on 2/23/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSNavigationBar.h"


@protocol FRSActionBarDelegate;

@interface FRSActionBar : UIView

typedef NS_ENUM(NSUInteger, FRSTrackedScreen) {
    FRSTrackedScreenUnknown, // Enum defaults to 0 if not defined, avoid setting default to highlights.
    FRSTrackedScreenHighlights,
    FRSTrackedScreenStories,
    FRSTrackedScreenProfile,
    FRSTrackedScreenSearch,
    FRSTrackedScreenFollowing,
    FRSTrackedScreenPush,
    FRSTrackedScreenDetail
};

@property (nonatomic, readwrite) FRSTrackedScreen trackedScreen;

@property (weak, nonatomic) NSObject <FRSActionBarDelegate> *delegate;

- (instancetype)initWithOrigin:(CGPoint)origin delegate:(id<FRSActionBarDelegate>)delegate;

@property (strong, nonatomic) UINavigationController *navigationController;

/**
 Configures the UI with an FRSGallery or FRSStory object.

 @param object FRSGallery or FRSStory to be passed in and help configure the action bar.
 */
-(void)configureWithObject:(id)object;

/**
 Updates the title using the titleForActionButton delegate method.
 */
- (void)updateTitle;

/**
 This checks if the authenticated user owns the content being liked/reposted and disables the repost button accordingly.

 @param isAuth BOOL Set YES to disable the repost button on the given content.
 */
- (void)setCurrentUser:(BOOL)isAuth;

/**
 UIButton left aligned button. (Read more, # comments)
 */
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@end

@protocol FRSActionBarDelegate <NSObject>


/**
 Set the title for the gallerys action button.
 
 @return NSString title for action button.
 */
- (NSString *)titleForActionButton;

/**
 Segues to the like/repost view controller focused on the likes tab.
 
 @param actionBar FRSActionBar
 */
-(void)handleLikeLabelTapped:(FRSActionBar *)actionBar;

/**
 Segues to the like/repost view controller focused on the reposts tab.
 
 @param actionBar FRSActionBar
 */
-(void)handleRepostLabelTapped:(FRSActionBar *)actionBar;

/**
 Segues to the gallery expanded view when the user taps [READ MORE]
 
 @param actionBar FRSActionBar
 */
-(void)handleActionButtonTapped:(FRSActionBar *)actionBar;

/**
 Presents share action sheet with a link to the current gallery.
 
 @param actionbar FRSActionBar
 */
-(void)handleShare:(FRSActionBar *)actionbar;

@end
