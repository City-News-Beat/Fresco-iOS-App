//
//  FRSUserStoryDetailArticlesTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 6/22/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSUserStory+CoreDataProperties.h"

static NSString *const storyDetailArticlesCellIdentifier = @"story-detail-articles-cell";

@interface FRSUserStoryDetailArticlesTableViewCell : UITableViewCell

- (void)configureWithStory:(FRSUserStory *)userStory;

@end
