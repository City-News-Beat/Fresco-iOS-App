//
//  FRSPost.h
//  Fresco
//
//  Created by Moshe Berman on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

@import Foundation;

#import <Mantle/Mantle.h>
#import "MTLModel+Additions.h"

@class FRSUser, FRSTag, FRSImage;

@interface FRSPost : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) FRSUser *user;
@property (nonatomic, copy) NSNumber *postID;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) FRSImage *largeImage;
@property (nonatomic, copy) FRSImage *smallImage;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, strong) NSArray *sources;
@property (nonatomic, copy) NSString *byline;

#warning part of reverse compatibility hack
@property (nonatomic, copy) NSString *large_path;
- (NSURL *)largeImageURL;

@end
