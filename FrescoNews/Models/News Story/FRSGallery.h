//
//  FRSGallery.h
//  Fresco
//
//  Created by Jason Gresh on 3/11/2015.
//  Copyright (c) 2015 TapMedia LLC. All rights reserved.
//

@import Foundation;

#import <Mantle/Mantle.h>

@class FRSUser, FRSTag;

@interface FRSGallery : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *galleryID;
@property (nonatomic, copy) NSString *visibility;
@property (nonatomic, copy) NSDate *createTime;
@property (nonatomic, copy) NSDate *modifiedTime;
@property (nonatomic, strong) FRSUser *owner;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *byline;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSArray *articles;
@property (nonatomic, strong) NSArray *relatedStories;
@property (nonatomic, strong) NSArray *posts;

- (instancetype)initWithAssets:(NSArray *)assets;

@end
