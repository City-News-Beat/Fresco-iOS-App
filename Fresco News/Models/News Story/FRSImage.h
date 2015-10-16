//
//  FRSImage.h
//  Fresco
//
//  Created by Fresco News on 3/11/2015.
//  Copyright (c) 2015 TapMedia LLC. All rights reserved.
//

@import Foundation;

#import <Mantle/Mantle.h>

@class PHAsset;

@interface FRSImage : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) NSNumber *width;
@property (nonatomic, copy) NSNumber *height;
@property (strong, nonatomic) PHAsset *asset;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;

- (NSURL *)smallImageUrl;
- (NSURL *)mediumImageUrl;
- (NSURL *)largeImageUrl;

@end
