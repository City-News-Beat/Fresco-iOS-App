//
//  FRSUserStoryDetailHeaderCellViewModel.m
//  Fresco
//
//  Created by Omar Elfanek on 6/23/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStoryDetailHeaderCellViewModel.h"

@implementation FRSUserStoryDetailHeaderCellViewModel

- (instancetype)initWithUserStory:(FRSUserStory *)userStory {
    self = [super init];
    
    if (self) {
//        self.title = userStory.title;
//        self.creator = userStory.creator;
//        self.createdDate = userStory.createdDate;
//        self.caption = userStory.caption;
        
        // DEBUG
        
        self.title = [userStory valueForKey:@"title"];
        self.creator = [userStory valueForKey:@"creator"];
        self.createdDate = [userStory valueForKey:@"createdDate"];
        self.editedDate = [userStory valueForKey:@"editedDate"];
        self.caption = [userStory valueForKey:@"caption"];
        
        // DEBUG
    }
    
    return self;
}

@end

