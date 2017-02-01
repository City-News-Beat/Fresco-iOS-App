//
//  NSURL+Fresco.h
//  
//
//  Created by Arthur De Araujo on 1/17/17.
//
//

#import <Foundation/Foundation.h>

@interface NSURL (Fresco)

/**
 Takes a string and a width, and returns a URL for an image that is sized accordingly

 @param url URL of the asset
 @param width width of the image an integer
 @return returns an NSURL correctly formatted
 */
+ (NSURL *)URLResizedFromURLString:(NSString *)url width:(NSInteger)width;

@end
