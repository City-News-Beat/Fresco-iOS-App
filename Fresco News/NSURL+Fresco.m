//
//  NSURL+Fresco.m
//
//
//  Created by Arthur De Araujo on 1/17/17.
//
//

#import "NSURL+Fresco.h"

@implementation NSURL (Fresco)

+ (NSURL *)URLResizedFromURLString:(NSString *)url width:(NSInteger)width {
    NSString *adjustedURL = url;
    
    if ([adjustedURL containsString:@"cdn.fresconews"]) {
        NSString *adjustedSize = [NSString stringWithFormat:@"%d", (int)width];
        adjustedSize = [@"/images/" stringByAppendingString:adjustedSize];
        adjustedURL = [adjustedURL stringByReplacingOccurrencesOfString:@"/images" withString:adjustedSize];
    }
    
    return [NSURL URLWithString:adjustedURL];
}

+ (NSString *)uniqueFileString {
    return [[NSTemporaryDirectory()
             stringByAppendingPathComponent:localDirectory]
            stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
}

+ (NSURL *)uniqueFileURL {
    return [NSURL fileURLWithPath:[self uniqueFileString]];
}

@end
