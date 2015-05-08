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

/*
 {
 _id: "55284f3b11fe08b11f00d30c",
 owner: {},
 byline: "George Jenkin via Fresco News",
 source: "https://twitter.com/jenkin_george/status/585802954994749440",
 type: "image",
 file: "http://www.fresconews.com/uploads/408/large_353e51460b4944f0b70cb1b7e001897085febc38.jpg",
 meta: [ ],
 license: "Twitter",
 location: {
 type: "Point",
 coordinates: [
 -1.721871,
 52.451649
 ]
 },
 time_created: 1428502262,
 visibility: 1,
 uses: [ ]
 }*/
/*
@property (nonatomic, copy, readonly) NSNumber *postID;
@property (nonatomic, strong, readonly) FRSUser *user;
@property (nonatomic, copy, readonly) NSString *source;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSURL *mediaURL;
@property (nonatomic, assign, readonly) CGSize mediaSize;
@property (nonatomic, copy, readonly) NSDate *date;
@property (nonatomic, copy, readonly) NSString *byline;
@property (nonatomic, copy, readonly) NSNumber *visibility;
 */

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
             @"caption" : @"caption",
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

//#warning part of reverse compatability hack
//+ (NSValueTransformer *)large_pathJSONTransformer
//{
//    return [MTLModel ];
//}

/*
- (NSString *)caption
{
    return [_caption length] ? _caption : NSLocalizedString(@"No Caption", nil);
}
*/

- (NSURL *)largeImageURL
{
    return [self.image cdnImageInListURL];
    //return [self.largeImage cdnImageInListURL];
}

@end
