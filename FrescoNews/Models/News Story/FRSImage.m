//
//  FRSImage.m
//  Fresco
//
//  Created by Jason Gresh on 3/11/2015.
//  Copyright (c) 2015 TapMedia LLC. All rights reserved.
//

#import "FRSImage.h"
#import "MTLModel+Additions.h"

@interface FRSImage()
@end

@implementation FRSImage

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"URL": @"file",
             @"width" : @"width",
             @"height" : @"height"
             };
}

- (NSURL *)cdnAssetURL
{
    // TODO: Use local asset, if available?
    if ([[self.URL absoluteString] containsString:@"/videos/"]) {
        return self.URL;
    }

    return [self cdnAssetURLForURLString:[self.URL absoluteString] withSize:CGSizeMake([self.width floatValue], [self.height floatValue]) transformationString:nil];
}

- (NSURL *)cdnAssetInListURL
{
    if ([[self.URL absoluteString] containsString:@"/videos/"]) {
        return self.URL;
    }

    CGSize size = CGSizeMake([self.width floatValue], [self.height floatValue]);
    NSString *transformString;
    
    // we don't want portrait aspect so square off
    if ([self.height floatValue] > [self.width floatValue]) {
        size.height = size.width;
        transformString = @"c_fill,g_faces";
    }
    
    return [self cdnAssetURLForURLString:[self.URL absoluteString] withSize:size transformationString:transformString];
}

@end
