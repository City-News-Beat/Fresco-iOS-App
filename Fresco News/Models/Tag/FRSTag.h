//
//  FRSTag.h
//  Fresco
//
//  Created by Team Fresco on 3/14/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FRSTag : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSURL *smallImagePath;
@property (nonatomic, copy) NSURL *largeImagePath;

@end
