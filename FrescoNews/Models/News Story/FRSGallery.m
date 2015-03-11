//
//  FRSGallery.m
//  Fresco
//
//  Created by Jason Gresh on 3/11/2015.
//  Copyright (c) 2015 TapMedia LLC. All rights reserved.
//

#import "FRSGallery.h"
#import "FRSUser.h"
#import "FRSTag.h"
#import "FRSTradionalSource.h"
#import "NSDate+RelativeDate.h"
#import "MTLModel+Additions.h"

@interface FRSGallery ()
@end

@implementation FRSGallery

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"galleryID": @"gallery_id",
             @"visibility" : @"visibility",
             @"createTime" : @"times.created",
             @"modifiedTime" : @"times.edited",
             @"owner" : @"owner",
             @"caption" : @"caption",
             @"byline" : @"byline",
             @"tags" : @"tags",
             @"articles" : @"articles",
             @"posts" : @"posts"
             };
}

+ (NSValueTransformer *)articlesJSONTransformer
{
    return [MTLModel sourcesJSONTransformer];
}

+ (NSValueTransformer *)ownerJSONTransformer
{
    return [MTLModel userJSONTransformer];
}

- (NSString *)caption
{
    return [_caption length] ? _caption : NSLocalizedString(@"No Caption", nil);
}
@end
