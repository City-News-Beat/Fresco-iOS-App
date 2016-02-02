//
//  FRSPost.m
//  Fresco
//
//  Created by Moshe Berman on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

@import Photos;

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
             @"galleryID" : @"gallery",
             @"user" : @"owner",
             @"source" : @"source",
             @"mediaWidth" : @"meta.width",
             @"mediaHeight" : @"meta.height",
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
        
        image.URL = [NSURL URLWithString:imageURL];

        return image;
        
    }];
}

- (NSURL *)largeImageURL
{
    return [self.image largeImageUrl];
}


- (NSData *)constructPostMetaDataWithFileName:(NSString *)fileName{

    //Get time interval for asset creation data, in milliseconds
    NSTimeInterval postTime = round([self.createdDate timeIntervalSince1970] * 1000);

    //Create post metadata from the first post
    NSDictionary *postMetadata = @{
                                   fileName : @{
                                               @"lat" : self.image.latitude,
                                               @"lon" : self.image.longitude,
                                               @"time_captured" : [NSString stringWithFormat:@"%ld",(long)postTime]
                                               }
                                   };
    
    //Create NSData representation of the dictionary
    return [NSJSONSerialization dataWithJSONObject:postMetadata
                                           options:(NSJSONWritingOptions)0
                                             error:nil];


}

- (void)dataForPostWithResponseBlock:(FRSDataResponseBlock)responseBlock{
    
    if (self.image.asset.mediaType == PHAssetMediaTypeImage) {
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        
        [[PHImageManager defaultManager] requestImageDataForAsset:self.image.asset options:options resultHandler:^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
            
            responseBlock(imageData, nil);
            
        }];
        
    }
    else if(self.image.asset.mediaType == PHAssetMediaTypeVideo) {
        
        PHVideoRequestOptions *option = [PHVideoRequestOptions new];
        option.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:self.image.asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix * audioMix, NSDictionary * info) {
            
            responseBlock([NSData dataWithContentsOfURL:((AVURLAsset *)asset).URL], nil);
            
        }];
        
    }
}

@end
