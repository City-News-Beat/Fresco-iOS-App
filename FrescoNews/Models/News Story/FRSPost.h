//
//  FRSPost.h
//  Fresco
//
//  Created by Moshe Berman on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

@import Foundation;

#import <Mantle/Mantle.h>
#import "FRSUser.h"
#import "FRSTag.h"

@interface FRSPost : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) FRSUser *user;
@property (nonatomic, copy) NSNumber *postID;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, copy) NSURL *largeImageURL;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, strong) NSArray *sources;
@property (nonatomic, copy) NSString *byline;

- (NSString *)relativeDateString;

//@property (nonatomic, strong) NSMutableArray *traditionalSources;

@end
