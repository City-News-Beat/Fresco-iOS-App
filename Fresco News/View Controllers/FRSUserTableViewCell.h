//
//  FRSUserTableViewCell.h
//  Fresco
//
//  Created by User on 2/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSUser.h"

@interface FRSUserTableViewCell : UITableViewCell

- (void)loadDataWithUser:(FRSUser *)user;

@end
