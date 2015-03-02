//
//  FRSTradionalSource.m
//  Fresco
//
//  Created by Team Fresco on 2/9/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSTradionalSource.h"

@implementation FRSTradionalSource

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"identifier" : @"identifier", @"prettyName" : @"pretty_name", @"URL" : @"url"};
}

+ (NSValueTransformer *)URLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
