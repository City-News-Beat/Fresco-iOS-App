//
//  FRSImage.h
//  Fresco
//
//  Created by Jason Gresh on 3/11/2015.
//  Copyright (c) 2015 TapMedia LLC. All rights reserved.
//

@import Foundation;

#import <Mantle/Mantle.h>

@interface FRSImage : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) NSNumber *width;
@property (nonatomic, copy) NSNumber *height;

- (NSURL *)cdnImageURL;

@end
