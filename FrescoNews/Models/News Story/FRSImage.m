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

@end
