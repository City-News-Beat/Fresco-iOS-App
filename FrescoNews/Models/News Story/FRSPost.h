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

@property (nonatomic, copy, readonly) NSString *postID;
@property (nonatomic, strong) FRSUser *user;
@property (nonatomic, copy, readonly) NSString *source;
@property (nonatomic, copy) NSString *type; // TODO: -> enum
@property (nonatomic, strong) FRSImage *image;
@property (nonatomic, copy) NSURL *mediaURL;
@property (nonatomic, copy, readonly) NSNumber *mediaWidth;
@property (nonatomic, copy, readonly) NSNumber *mediaHeight;
@property (nonatomic, copy, readonly) NSDate *date;
@property (nonatomic, copy, readonly) NSString *byline;
@property (nonatomic, copy, readonly) NSNumber *visibility;

- (NSURL *)largeImageURL;
- (BOOL)isVideo;

@end
