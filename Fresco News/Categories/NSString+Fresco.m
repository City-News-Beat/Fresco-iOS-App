//
//  NSString+Fresco.m
//  Fresco
//
//  Created by Maurice Wu on 1/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "NSString+Fresco.h"
#import "FRSDateFormatters.h"

@implementation NSString (Fresco)

+ (NSString *)randomString {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:15];

    for (int i = 0; i < 15; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random_uniform([letters length])]];
    }

    return randomString;
}

+ (NSString *)random64CharacterString {
    NSString *letters = @"abcdefABCDEF0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:64];

    for (int i = 0; i < 64; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random_uniform([letters length])]];
    }

    return randomString;
}

+ (NSDate *)dateFromString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[FRSDateFormatters sharedInstance] defaultUTCTimeZoneFullDateFormatter];
    return [dateFormatter dateFromString:string];
}

@end
