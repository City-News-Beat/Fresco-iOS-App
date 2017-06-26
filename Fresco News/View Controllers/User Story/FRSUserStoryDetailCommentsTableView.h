//
//  FRSUserStoryDetailCommentsTableView.h
//  Fresco
//
//  Created by Omar Elfanek on 6/26/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSUserStory+CoreDataProperties.h"

@interface FRSUserStoryDetailCommentsTableView : UITableView

- (void)configureCommentsTableViewWithUserStory:(FRSUserStory *)userStory;

@end
