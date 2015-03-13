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
#import "FRSTradionalSource.h"
#import "NSDate+RelativeDate.h"

@implementation FRSStory

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"storyID": @"story_id",
             @"caption" : @"caption",
             @"title" : @"title",
             @"byline" : @"byline",
             @"date" : @"timestamp",
             @"tags" : @"tags",
             @"galleries" : @"galleries",
             @"articles" : @"articles"
            // @"user" : @"user"
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
