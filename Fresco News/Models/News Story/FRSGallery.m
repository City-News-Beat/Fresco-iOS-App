//
//  FRSGallery.m
//  Fresco
//
//  Created by Fresco News on 3/11/2015.
//  Copyright (c) 2015 TapMedia LLC. All rights reserved.
//

#import "FRSGallery.h"
#import "FRSUser.h"
#import "FRSTag.h"
#import "FRSArticle.h"
#import "MTLModel+Additions.h"
#import "FRSPost.h"
#import "FRSImage.h"
@import Photos;
@import CoreLocation;

@implementation FRSGallery

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"galleryID": @"_id",
             @"visibility" : @"visibility",
             @"createTime" : @"time_created",
             @"owner" : @"owner",
             @"caption" : @"caption",
             @"byline" : @"byline",
             @"tags" : @"tags",
             @"articles" : @"articles",
             @"relatedStories" : @"related_stories",
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

+ (NSValueTransformer *)createTimeJSONTransformer
{
    return [MTLModel dateJSONTransformer];
}

+ (NSValueTransformer *)modifiedTimeJSONTransformer
{
    return [MTLModel dateJSONTransformer];
}

- (instancetype)initWithAssets:(NSArray *)assets
{
    self = [super init];
    
    if (self) {
        
        NSMutableArray *posts = [NSMutableArray new];
        
        for (PHAsset *asset in assets) {
            
            FRSPost *post = [[FRSPost alloc] init];
            
            FRSImage *image = [[FRSImage alloc] init];
            
            image.asset = asset;
            
            #if TARGET_IPHONE_SIMULATOR
                image.latitude = @(40.6);
                image.longitude = @(-74.1);
            #else
            
                CLLocation *location = asset.location;
            
                if (location) {
                    image.latitude = @(location.coordinate.latitude);
                    image.longitude = @(location.coordinate.longitude);
                }
                else {
                    NSLog(@"Skipping - no location information available");
                    continue;
                }
            
            #endif
            
            post.image = image;
            
            post.createdDate = asset.creationDate;
            
            if (asset.mediaType == PHAssetMediaTypeImage) {
                post.type = @"image";
            }
            else if (asset.mediaType == PHAssetMediaTypeVideo) {
                post.type = @"video";
            }
            else {
                NSLog(@"Skipping - cannot determine asset type");
                continue;
            }
            
            [posts addObject:post];
        }
        
        //Check if we have any posts
        if (posts.count == 0)
            return nil;
        
        self.posts = posts;
        
    }
    
    return self;
}



- (NSString *)caption
{
    return [_caption length] ? _caption : NSLocalizedString(@"No Caption", nil);
}

@end
