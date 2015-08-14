//
//  FRSTradionalSource.m
//  Fresco
//
//  Created by Team Fresco on 2/9/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSArticle.h"

@implementation FRSArticle

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"title" : @"title",
             @"favicon" : @"favicon",
             @"URL" : @"link"
             };
}

+ (NSValueTransformer *)URLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)faviconJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}


@end
