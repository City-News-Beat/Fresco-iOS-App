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
             @"postID" : @"_id",
             @"user" : @"owner",
             @"source" : @"source",
             @"type" : @"type",
             //@"mediaSize" : @"meta",
             @"mediaURLString" : @"file",
             @"image" : @"file",
             @"date" : @"time_created",
             @"byline" : @"byline",
             @"visibility" : @"visibility",
             };
}

+ (NSValueTransformer *)mediaURLStringJSONTransformer
{
    return [MTLModel URLJSONTransformer];
}

+ (NSValueTransformer *)imageJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^FRSImage *(NSString *imageURL) {
        FRSImage *image = [[FRSImage alloc] init];
        image.URL = [NSURL URLWithString:imageURL];
        image.width = [NSNumber numberWithFloat:800.0f];
        image.height =  [NSNumber numberWithFloat:600.0f];
        return image;
    }];
}

- (BOOL)isVideo
{
    return [_type isEqualToString:@"video"] ? YES : NO;
}



- (NSURL *)largeImageURL
{
    return [self.image cdnImageInListURL];
    //return [self.largeImage cdnImageInListURL];
}

@end
