//
//  FRSPost.m
//  Fresco
//
//  Created by Moshe Berman on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSPost.h"
#import "FRSUser.h"
#import "FRSTag.h"
#import "FRSTradionalSource.h"
#import "FRSImage.h"

@implementation FRSPost

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"postID": @"post_id",
             @"caption" : @"caption",
             @"smallImage" : @"image.small",
             @"largeImage" : @"image.large",
             @"user" : @"user",
             @"date" : @"timestamp",
             @"sources" : @"sources",
             @"tags" : @"tags",
             @"byline" : @"byline"
             };
}

+ (NSValueTransformer *)smallImageJSONTransformer
{
    return [MTLModel imageJSONTransformer];
}

+ (NSValueTransformer *)largeImageJSONTransformer
{
    return [MTLModel imageJSONTransformer];
}

- (NSString *)caption
{
    return [_caption length] ? _caption : NSLocalizedString(@"No Caption", nil);
}

@end
