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

@property (nonatomic, strong) FRSUser *user;

@property (nonatomic, strong) FRSImage *image;
@property (nonatomic, copy, readonly) NSString *postID;
@property (nonatomic, copy, readonly) NSString *galleryID;
@property (nonatomic, copy, readonly) NSString *source;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, copy) NSURL *video;
@property (nonatomic, copy, readonly) NSNumber *mediaWidth;
@property (nonatomic, copy, readonly) NSNumber *mediaHeight;
@property (nonatomic, copy, readonly) NSDate *date;
@property (nonatomic, copy, readonly) NSString *byline;
@property (nonatomic, copy, readonly) NSNumber *visibility;
@property (nonatomic, copy, readonly) NSString *address;

- (NSURL *)largeImageURL;
- (BOOL)isVideo;

@end
