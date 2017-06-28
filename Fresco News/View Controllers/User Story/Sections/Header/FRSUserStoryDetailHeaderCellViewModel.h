//
//  FRSUserStoryDetailHeaderCellViewModel.h
//  Fresco
//
//  Created by Omar Elfanek on 6/23/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSUserStory+CoreDataClass.h"

@interface FRSUserStoryDetailHeaderCellViewModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) FRSUser *creator;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSDate *editedDate;

- (instancetype)initWithUserStory:(FRSUserStory *)userStory;

@end
