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
    return @{ @"URL": @"file" };
}

- (NSURL *)cdnAssetURLWithSize:(CGSize)size
{
    return [self cdnAssetURLForURLString:[self.URL absoluteString] withSize:size transformationString:nil];
}

/*
- (NSURL *)cdnAssetURL
{
    return [self cdnAssetURLWithSize:CGSizeMake([self.width floatValue], [self.height floatValue])];
}
*/
- (NSURL *)cdnAssetURL
{
    // TODO: Use local asset, if available?
    return [self cdnAssetURLForURLString:[self.URL absoluteString] withSize:CGSizeMake([self.width floatValue], [self.height floatValue]) transformationString:nil];
}

- (NSURL *)cdnAssetInListURL
{
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
