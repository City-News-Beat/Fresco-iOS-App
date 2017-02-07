//
//  FRSProfileViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSScrollingViewController.h"
#import "FRSUser.h"
#import "FRSBorderedImageView.h"

@interface FRSProfileViewController : FRSScrollingViewController <UITextViewDelegate, UITableViewDataSource> {
    UILabel *titleLabel;
    UIView *topView;
    BOOL isLoadingUser;
    NSString *userId;
    BOOL isReloading;
    BOOL isFinishedLikes;
    BOOL isFinishedUser;

    CGPoint lastScrollOffset;
    NSTimeInterval lastOffsetCapture;
    BOOL isScrollingFast;
    NSInteger galleriesScrolledPast;

    NSInteger currentProfileCount;
    NSInteger currentLikesCount;

    NSDate *dateOpened;
}


@property BOOL userIsBlocking;
@property BOOL userIsBlocked;
@property BOOL userIsSuspended;
@property BOOL userIsDisabled;

@property (nonatomic, weak) NSArray *currentFeed;
@property (nonatomic, retain) UIScrollView *tablePageScroller;
@property (nonatomic, retain) UITableView *contentTable;

@property (nonatomic, retain) FRSUser *representedUser;
@property BOOL authenticatedProfile;
@property (strong, nonatomic) UITextView *bioTextView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) FRSBorderedImageView *profileIV;
@property BOOL editedProfile;
@property BOOL shouldShowNotificationsOnLoad;

- (instancetype)initWithUser:(FRSUser *)user;
- (instancetype)initWithUserID:(NSString *)userName;
- (void)resizeProfileContainer;
- (void)loadAuthenticatedUser;
- (void)showNotificationsNotAnimated;

@end
