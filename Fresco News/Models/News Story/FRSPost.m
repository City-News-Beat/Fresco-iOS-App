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
#import "FRSArticle.h"
#import "FRSImage.h"

@implementation FRSPost

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"postID" : @"_id",
             @"user" : @"owner",
             @"source" : @"source",
             @"mediaWidth" : @"meta.width",
             @"mediaHeight" : @"meta.height",
             @"image" : @"image",
             @"imageUrl" : @"image",
             @"video" : @"video",
             @"date" : @"time_created",
             @"byline" : @"byline",
             @"visibility" : @"visibility",
             @"address" : @"location.address",
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self) {
        // because the image data is spread over different levels of the hierarchy
        // we need to touch it up after the object is loaded
        if (self.image) {
            if ([self.mediaWidth isKindOfClass:[NSNumber class]]) {
                self.image.width = self.mediaWidth ?: [NSNumber numberWithFloat:800.0f];
                self.image.height = self.mediaHeight ?: [NSNumber numberWithFloat:600.0f];
            }
        }
    }
    return self;
}


+ (NSValueTransformer *)videoJSONTransformer
{
    return [MTLModel URLJSONTransformer];
}

+ (NSValueTransformer *)imageUrlJSONTransformer
{
    return [MTLModel URLJSONTransformer];
}


- (BOOL)isVideo
{
    return self.video || [self.type isEqualToString:@"video"] ? YES : NO;
}

+ (NSValueTransformer *)imageJSONTransformer{
    
    return [MTLValueTransformer transformerWithBlock:^FRSImage *(NSString *imageURL) {
        
        FRSImage *image = [[FRSImage alloc] init];
        
        if (!([imageURL rangeOfString:@"cloudfront"].location == NSNotFound)){
            
            NSMutableString *mu = [NSMutableString stringWithString:imageURL];
            
            NSRange range = [mu rangeOfString:@"/images/"];
            
            if (!(range.location == NSNotFound)) {
                
                [mu insertString:@"medium/" atIndex:(range.location + range.length)];
                
                image.URL = [NSURL URLWithString:mu];
                
            }
            
        }
        else{
        
            image.URL = [NSURL URLWithString:imageURL];
            
        }
        
        return image;
        
    }];

}


- (NSURL *)largeImageURL
{
    if(self.isVideo){
        self.image.URL = self.imageUrl;
    }
    
    return [self.image cdnAssetInListURL];
}

@end
