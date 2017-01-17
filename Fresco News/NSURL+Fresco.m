//
//  NSURL+Fresco.m
//  
//
//  Created by Arthur De Araujo on 1/17/17.
//
//

#import "NSURL+Fresco.h"

@implementation NSURL (Fresco)


- (id) initWithString:(NSString *)URLString width:(float)width{
    return [self initWithString:[self URLResizedFromURLString:URLString width:width]];
}

- (NSString *)URLResizedFromURLString:(NSString *)url width:(float)width{
    NSString *adjustedURL = url;
    
    if ([adjustedURL containsString:@"cdn.fresconews"]) {
        NSString *adjustedSize = [NSString stringWithFormat:@"%d", (int)width];
        adjustedSize = [@"/images/" stringByAppendingString:adjustedSize];
        adjustedURL = [adjustedURL stringByReplacingOccurrencesOfString:@"/images" withString:adjustedSize];
    }
    
    return  adjustedURL;
}

@end
