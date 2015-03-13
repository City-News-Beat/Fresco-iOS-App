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
             @"byline" : @"byline",
             @"large_path": @"large_path"
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

//#warning part of reverse compatability hack
//+ (NSValueTransformer *)large_pathJSONTransformer
//{
//    return [MTLModel ];
//}

- (NSString *)caption
{
    return [_caption length] ? _caption : NSLocalizedString(@"No Caption", nil);
}

- (NSURL *)largeImageURL
{
    //return [NSURL URLWithString:[@"http://res.cloudinary.com/dnd5ngsax/image/fetch/w_375,h_375/" stringByAppendingString:[_large_path absoluteString]]];
    return [NSURL URLWithString:[@"http://res.cloudinary.com/dnd5ngsax/image/fetch/w_750/" stringByAppendingString:self.large_path]];
}

@end
