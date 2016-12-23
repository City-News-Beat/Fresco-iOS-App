//
//  FRSFollowersViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSScrollingViewController.h"
#import "FRSUser.h"

@interface FRSFollowersViewController : FRSScrollingViewController <UITableViewDelegate, UITableViewDataSource>
{
    BOOL isAtBottomFollowers;
    BOOL isAtBottomFollowing;
    BOOL isReloadingFollowing;
    BOOL isReloadingFollowers;
}

@property (nonatomic, weak) FRSUser *representedUser;
@property BOOL shouldUpdateOnReturn;
@end
