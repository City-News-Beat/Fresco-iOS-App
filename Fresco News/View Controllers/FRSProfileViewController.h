//
//  FRSProfileViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSScrollingViewController.h"
#import "FRSUser.h"
#import "FRSFeedTable.h"
#import "FRSBorderedImageView.h"

@interface FRSProfileViewController : FRSScrollingViewController <UITextViewDelegate, FRSGalleryViewDelegate, UITableViewDataSource>
{
    UILabel *titleLabel;
    UIView *topView;
}

@property (nonatomic, weak) NSArray *currentFeed;
@property (nonatomic, retain) UIScrollView *tablePageScroller;
@property (nonatomic, retain) UITableView *contentTable;
-(instancetype)initWithUser:(FRSUser *)user;
-(void)loadAuthenticatedUser;
-(FRSUser *)authenticatedUser;
@property (nonatomic, retain) FRSUser *representedUser;
@property BOOL authenticatedProfile;
-(instancetype)initWithDefaultUser;
@property (strong, nonatomic) UILabel *bioLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) FRSBorderedImageView *profileIV;

@end
