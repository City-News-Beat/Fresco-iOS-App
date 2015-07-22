//
//  FRSImage.m
//  Fresco
//
//  Created by Fresco News on 3/11/2015.
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

- (NSURL *)cdnAssetInListURL
{

    if(self.width && self.height){

        CGSize size = CGSizeMake([self.width floatValue], [self.height floatValue]);
        NSString *transformString;
        
        // we don't want portrait aspect so square off
        if ([self.height floatValue] > [self.width floatValue]) {
            size.height = size.width;
            transformString = @"c_fill,g_faces";
        }
        
        return [self cdnAssetURLForURLString:[self.URL absoluteString] withSize:size transformationString:transformString];
            
    }
    else{
        
        return self.URL;
    }
}

- (NSString *)description
{
    return [self.URL description];
}

@end