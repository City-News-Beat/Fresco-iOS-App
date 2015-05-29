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
             @"mediaWidth" : @"meta.width",
             @"mediaHeight" : @"meta.height",
             @"mediaURLString" : @"file",
             @"image" : @"file",
             @"date" : @"time_created",
             @"byline" : @"byline",
             @"visibility" : @"visibility",
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self) {
        // because the image data is spread over different levels of the hierarchy
        // we need to touch it up after the object is loaded
        if (self.image) {
            self.image.width = self.mediaWidth;
            self.image.height = self.mediaHeight;
        }
    }
    return self;
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
