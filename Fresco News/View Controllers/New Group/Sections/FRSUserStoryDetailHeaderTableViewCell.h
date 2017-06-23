//
//  FRSUserStoryDetailHeaderTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 6/21/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSUserStoryDetailHeaderCellViewModel.h"

static NSString *const storyDetailHeaderCellIdentifier = @"story-detail-header-cell";

@interface FRSUserStoryDetailHeaderTableViewCell : UITableViewCell


- (void)configureWithStoryHeaderCellViewModel:(FRSUserStoryDetailHeaderCellViewModel *)userStoryDetailHeaderCellViewModel;

@end
