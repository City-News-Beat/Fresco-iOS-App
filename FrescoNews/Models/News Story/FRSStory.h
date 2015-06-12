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

@property (nonatomic, copy) NSString *storyID;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSArray *galleryIds;
@property (nonatomic, strong) NSArray *articleIds;
@property (nonatomic, strong) NSArray *thumbnails;
@property (nonatomic, strong) FRSUser *curator;

@end
