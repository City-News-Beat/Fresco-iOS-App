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
             @"URL": @"path",
             @"width" : @"width",
             @"height" : @"height"
             };
}

- (NSURL *)cdnImageURL
{
    return [self cdnImageURLForURLString:[self.URL absoluteString] withSize:CGSizeMake([self.width floatValue], [self.height floatValue])];
}

@end
