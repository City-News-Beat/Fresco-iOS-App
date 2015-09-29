//
//  FRSStory.m
//  Fresco
//
//  Created by Fresco News on 3/11/2015.
//  Copyright (c) 2015 TapMedia LLC. All rights reserved.
//

#import "FRSStory.h"
#import "MTLModel+Additions.h"
#import "FRSUser.h"
#import "FRSArticle.h"

@implementation FRSStory

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"storyID": @"_id",
             @"curator" : @"curator",
             @"title" : @"title",
             @"caption" : @"caption",
             @"tags" : @"tags",
             @"articleIds" : @"articles",
             @"thumbnails" : @"thumbnails",
             @"createdTime" : @"time_created",
             @"editedTime" : @"time_edited"
             };
}

+ (NSValueTransformer *)articlesJSONTransformer
{
    return [MTLModel sourcesJSONTransformer];
}


+ (NSValueTransformer *)createdTimeJSONTransformer
{
    return [MTLModel dateJSONTransformer];
}

+ (NSValueTransformer *)editedTimeJSONTransformer
{
    return [MTLModel dateJSONTransformer];
}


- (NSString *)caption
{
    return [_caption length] ? _caption : NSLocalizedString(@"No Caption", nil);
}

+ (NSValueTransformer *)curatorJSONTransformer
{
    return [MTLModel userJSONTransformer];
}

+ (NSValueTransformer *)thumbnailsJSONTransformer
{
    return [MTLModel postsJSONTransformer];
}
@end
