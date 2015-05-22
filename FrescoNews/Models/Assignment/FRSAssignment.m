//
//  FRSAssignment.m
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/21/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSAssignment.h"
#import "MTLModel+Additions.h"

@implementation FRSAssignment

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"assignmendId": @"_id",
             @"title" : @"title",
             @"caption" : @"caption",
             @"galleries" : @"galleries",
             @"active" : @"active",
             @"location": @"location",
             @"lat" : @"location.geo.coordinates",
             @"lon" : @"location.geo.coordinates",
             @"radius" : @"radius",
             @"timeCreated" : @"time_created",
             @"timeEdited" : @"time_edited",
             @"expirationTime": @"expiration_time"
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

+ (NSValueTransformer *)timeCreatedJSONTransformer
{
    return [MTLModel dateJSONTransformer];
}

+ (NSValueTransformer *)timeEditedJSONTransformer
{
    return [MTLModel dateJSONTransformer];
}

+ (NSValueTransformer *)expirationTimeJSONTransformer
{
    return [MTLModel dateJSONTransformer];
}

- (NSString *)caption
{
    return [_caption length] ? _caption : NSLocalizedString(@"No Caption", nil);
}

@end
