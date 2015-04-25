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
#import "FRSPost.h"
#import "FRSImage.h"
#import "UIImage+ALAsset.h"

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
    if (!self) {
        return nil;
    }
    
    NSMutableArray *posts = [NSMutableArray new];
    for (ALAsset *asset in assets) {
        FRSPost *post = [[FRSPost alloc] init];
        FRSImage *image = [[FRSImage alloc] init];
        image.image = [UIImage imageFromAsset:asset];
        image.height = @1; // ?
        image.width = @1; // ?
        post.largeImage = image;
        [posts addObject:post];
    }
    
    _posts = posts;
    return self;
}

- (NSString *)caption
{
    return [_caption length] ? _caption : NSLocalizedString(@"No Caption", nil);
}

@end
