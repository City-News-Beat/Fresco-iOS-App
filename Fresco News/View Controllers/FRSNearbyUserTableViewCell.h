//
//  FRSNearbyUserTableViewCell.h
//  Fresco
//
//  Created by User on 2/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRSUser;

static NSString *const nearbyUserCellIdentifier = @"nearby-user-cell";

@interface FRSNearbyUserTableViewCell : UITableViewCell

- (void)loadDataWithUser:(FRSUser *)user;

@end
