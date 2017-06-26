//
//  FRSUserStoryDetailMediaTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 6/22/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSUserStory+CoreDataProperties.h"

static NSString *const storyDetailMediaCellIdentifier = @"story-detail-media-cell";

@interface FRSUserStoryDetailMediaTableViewCell : UITableViewCell

- (void)configureWithStory:(FRSUserStory *)userStory;

@end
