//
//  FRSAssignment.m
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/21/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSAssignment.h"
@import CoreLocation;
#import "MTLModel+Additions.h"

@implementation FRSAssignment

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"assignmentId": @"_id",
             @"title" : @"title",
             @"caption" : @"caption",
             @"galleries" : @"galleryArray",
             @"active" : @"active",
             @"location": @"location",
             @"lat" : @"location.geo.coordinates",
             @"lon" : @"location.geo.coordinates",
             @"radius" : @"location.radius",
             @"timeCreated" : @"time_created",
             @"timeEdited" : @"time_edited",
             @"expirationTime": @"expiration_time"
             };
}

+ (NSValueTransformer *)latJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithBlock:^NSNumber *(NSArray *location) {
        return location[1];
    }];
}

+ (NSValueTransformer *)lonJSONTransformer
{
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
    return [self.caption length] ? self.caption : NSLocalizedString(@"No Caption", nil);
}

- (CLLocation *)locationObject
{
    if (!_locationObject) {
        _locationObject  = [[CLLocation alloc] initWithLatitude:[self.lat floatValue]
                                                      longitude:[self.lon floatValue]];
    }

    return _locationObject;
}

@end
