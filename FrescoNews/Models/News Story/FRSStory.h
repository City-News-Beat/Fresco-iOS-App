//
//  FRSStory.h
//  Fresco
//
//  Created by Jason Gresh on 3/11/2015.
//  Copyright (c) 2015 TapMedia LLC. All rights reserved.
//

@import Foundation;

#import <Mantle/Mantle.h>
#import "FRSUser.h"
#import "FRSTag.h"

@interface FRSStory : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *storyID;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *byline;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSArray *galleries;
@property (nonatomic, strong) NSArray *articles;
//@property (nonatomic, strong) FRSUser *user;

//@property (nonatomic, strong) NSMutableArray *traditionalSources;

@end
