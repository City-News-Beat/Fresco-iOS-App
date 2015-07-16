//
//  FRSCluster.h
//  FrescoNews
//
//  Created by Fresco News on 5/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Foundation;


#import <Mantle/Mantle.h>

@interface FRSCluster : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;
@property (nonatomic, strong) NSNumber *radius;

@end
