//
//  FRSTag.m
//  Fresco
//
//  Created by Team Fresco on 3/14/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSTag.h"

@implementation FRSTag

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"identifier": @"identifier",
             @"smallImagePath" : @"small_path",
             @"largeImagePath" : @"large_path"
             };
}

+ (NSValueTransformer *)smallImagePathJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)largeImagePathJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}


@end
