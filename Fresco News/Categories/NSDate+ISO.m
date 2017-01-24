//
//  NSDate+ISO.m
//  FrescoNews
//
//  Created by Joshua Lerner on 4/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "NSDate+ISO.h"

NSString *const ISODateFormat = @"yyyy:MM:dd";
NSString *const ISODateTimeZoneFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ";
NSString *const ISOTimeFormat = @"HH:mm:ss";

@implementation NSDate (ISO)

- (NSString *)ISODate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = ISODateFormat;
    return [formatter stringFromDate:self];
}

- (NSString *)ISODateWithTimeZone {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = ISODateTimeZoneFormat;
    return [formatter stringFromDate:self];
}

- (NSString *)ISOTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    formatter.dateFormat = ISOTimeFormat;
    return [formatter stringFromDate:self];
}

@end
