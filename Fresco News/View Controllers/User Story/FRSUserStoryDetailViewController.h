//
//  FRSUserStoryDetailViewController.h
//  Fresco
//
//  Created by Omar Elfanek on 6/21/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"
#import "FRSUserStory+CoreDataClass.h"


@interface FRSUserStoryDetailViewController : FRSBaseViewController

- (instancetype)initWithUserStory:(FRSUserStory *)userStory;

@end
