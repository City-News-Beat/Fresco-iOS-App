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

/*
** Retrieves URL for image, with specified size, used in thumbnails
*/

- (NSURL *)cdnAssetURLWithSize:(CGSize)size{
    
    NSString *sizeString;
    
    if (size.width > 0) {
        sizeString = [NSString stringWithFormat:@"w_%d", (int)size.width];
        if (size.height)
            sizeString = [sizeString stringByAppendingString:@","];
    }
    if (size.height > 0) {
        sizeString = [NSString stringWithFormat:@"%@h_%d", sizeString, (int)size.height];
    }
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/%@/%@", CDN_BASE_URL, sizeString, [[self smallImageUrl] absoluteString]];
    
    return [NSURL URLWithString:fullURL];
    
}

/*
** Retrieves small version of image
*/

- (NSURL *)smallImageUrl{
    
    NSString *urlString = [self.URL absoluteString];
    
    if (!([urlString rangeOfString:@"cloudfront"].location == NSNotFound)){
        
        NSMutableString *mu = [NSMutableString stringWithString:urlString];
        
        NSRange range = [mu rangeOfString:@"/images/"];
        
        if (!(range.location == NSNotFound)) {
            
            [mu insertString:@"small/" atIndex:(range.location + range.length)];
            
            return [NSURL URLWithString:mu];
            
        }
        
    }
    else return self.URL;
    
    return nil;

}

/*
** Retrieves medium version of image
*/

- (NSURL *)mediumImageUrl{
    
    NSString *urlString = [self.URL absoluteString];

    if (!([urlString rangeOfString:@"cloudfront"].location == NSNotFound)){
        
        NSMutableString *mu = [NSMutableString stringWithString:urlString];
        
        NSRange range = [mu rangeOfString:@"/images/"];
        
        if (!(range.location == NSNotFound)) {
            
            [mu insertString:@"medium/" atIndex:(range.location + range.length)];
            
            return [NSURL URLWithString:mu];
            
        }
        
    }
    else return self.URL;
    
    return nil;

}

/*
** Retrieves large version of image
*/

- (NSURL *)largeImageUrl{
    
    NSString *urlString = [self.URL absoluteString];
    
    if (!([urlString rangeOfString:@"cloudfront"].location == NSNotFound) && urlString != nil){
        
        NSMutableString *mu = [NSMutableString stringWithString:urlString];
        
        NSRange range = [mu rangeOfString:@"/images/"];
        
        if (!(range.location == NSNotFound)) {
            
            [mu insertString:@"large/" atIndex:(range.location + range.length)];
            
            return [NSURL URLWithString:mu];
            
        }
        
    }
    else return self.URL;
        
    return nil;
    
}

- (NSString *)description
{
    return [self.URL description];
}

@end
