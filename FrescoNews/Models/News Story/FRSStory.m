//
//  FRSStory.m
//  Fresco
//
//  Created by Jason Gresh on 3/11/2015.
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
             @"caption" : @"caption",
             @"title" : @"title",
             @"byline" : @"byline",
             @"date" : @"time_created",
             @"tags" : @"tags",
             @"galleries" : @"galleries",
             @"articleIds" : @"articles",
             @"curator" : @"curator"
             };
}

+ (NSValueTransformer *)articlesJSONTransformer
{
    return [MTLModel sourcesJSONTransformer];
}

- (NSString *)caption
{
    return [_caption length] ? _caption : NSLocalizedString(@"No Caption", nil);
}

@end
