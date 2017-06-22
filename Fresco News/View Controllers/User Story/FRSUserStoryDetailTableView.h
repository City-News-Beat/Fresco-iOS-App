//
//  FRSUserStoryDetailTableView.h
//  Fresco
//
//  Created by Omar Elfanek on 6/22/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSUserStory+CoreDataProperties.h"

@interface FRSUserStoryDetailTableView : UITableView

- (instancetype)initWithFrame:(CGRect)frame userStory:(FRSUserStory *)userStory;

@property (strong, nonatomic) FRSUserStory *userStory;

@end
