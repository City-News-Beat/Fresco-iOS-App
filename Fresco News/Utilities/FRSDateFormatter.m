//
//  FRSDateFormatter.m
//  Fresco
//
//  Created by Daniel Sun on 1/8/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDateFormatter.h"

@implementation FRSDateFormatter

+(NSDate*)dateFromEpochTime:(id)epochTime milliseconds:(BOOL)milliseconds{
    double seconds = [epochTime doubleValue];
    
    if (milliseconds) seconds /= 1000;
    
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

+ (NSString *)daySuffixForDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger dayOfMonth = [calendar component:NSCalendarUnitDay fromDate:date];
    switch (dayOfMonth) {
        case 1:
        case 21:
        case 31: return @"st";
        case 2:
        case 22: return @"nd";
        case 3:
        case 23: return @"rd";
        default: return @"th";
    }
}

+(NSString *)dateStringGalleryFormatFromDate:(NSDate *)date {
    NSTimeInterval sinceStart = [date timeIntervalSinceNow];
    sinceStart *= -1;
    
    if (sinceStart >= (24 * 60 * 60)) {
        NSTimeInterval secondsFromGMT = [[NSTimeZone localTimeZone] secondsFromGMT];
        NSDate *correctDate = [date dateByAddingTimeInterval:secondsFromGMT];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        [formatter setDateFormat:@"hh:mm a, MMMM d"];
        return [[formatter stringFromDate:correctDate] stringByAppendingString:[FRSDateFormatter daySuffixForDate:date]];
    }
    
    NSTimeInterval secondsFromGMT = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *correctDate = [date dateByAddingTimeInterval:secondsFromGMT];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"hh:mm a"];
    return [formatter stringFromDate:correctDate];
}

//temp method
+(NSString *)dateStringFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    return [formatter stringFromDate:date];
}

@end
