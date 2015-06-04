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
             @"URL": @"file"
             /*@"width" : @"width",
             @"height" : @"height"*/
             };
}

- (NSURL *)cdnImageURLWithSize:(CGSize)size
{
    return [self cdnImageURLForURLString:[self.URL absoluteString] withSize:size transformationString:nil];
}

- (NSURL *)cdnImageURL
{
    return [self cdnImageURLWithSize:CGSizeMake([self.width floatValue], [self.height floatValue])];
}

- (NSURL *)cdnImageInListURL
{
    CGSize size = CGSizeMake([self.width floatValue], [self.height floatValue]);
    NSString *transformString;
    
    // we don't want portrait aspect so square off
    if ([self.height floatValue] > [self.width floatValue]) {
        size.height = size.width;
        transformString = @"c_fill,g_faces";
    }
    
    return [self cdnImageURLForURLString:[self.URL absoluteString] withSize:size transformationString:transformString];
}

@end
