//
//  FRSCluster.m
//  FrescoNews
//
//  Created by Fresco News on 5/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSCluster.h"

@implementation FRSCluster

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"location": @"geo",
             @"lat" : @"geo.coordinates",
             @"lon" : @"geo.coordinates",
             @"radius" : @"radius",
             };
}

+ (NSValueTransformer *)latJSONTransformer{
    
    return [MTLValueTransformer reversibleTransformerWithBlock:^NSNumber *(NSArray *location) {
        
        return location[1];
        
    }];
    
}

+ (NSValueTransformer *)lonJSONTransformer{
    
    return [MTLValueTransformer reversibleTransformerWithBlock:^NSNumber *(NSArray *location) {
        
        return location[0];
        
    }];
    
}

@end
