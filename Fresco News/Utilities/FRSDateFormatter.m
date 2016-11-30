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
    [formatter setDateFormat:@"h:mm a"];
    return [formatter stringFromDate:correctDate];
}


+(NSString *)relativeTimeFromDate:(NSDate *)compareDate {
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:compareDate];
    
    int temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"Just now"];
    } else if ((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%d minutes ago", temp];
        if ([result isEqualToString:@"1 minutes ago"]) {
            result = @"1 minute ago";
        }
    } else if ((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%d hours ago", temp];
        if ([result isEqualToString:@"1 hours ago"]) {
            result = @"1 hour ago";
        }
    } else {
        temp = temp / 24;
        result = [NSString stringWithFormat:@"%d days ago", temp];
        if ([result isEqualToString:@"1 days ago"]) {
            result = @"1 day ago";
        }
    }
    return result;
}

+(NSString *)dateDifference:(NSDate *)date {
    const NSTimeInterval secondsPerDay = 60 * 60 * 24;
    NSTimeInterval diff = [date timeIntervalSinceNow] * -1.0;

    diff /= secondsPerDay;
    
    if (diff < 1) {
        return @"today";
    } else if (diff < 2) {
        return @"yesterday";
    } else {
        NSTimeInterval secondsFromGMT = [[NSTimeZone localTimeZone] secondsFromGMT];
        NSDate *correctDate = [date dateByAddingTimeInterval:secondsFromGMT];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        [formatter setDateFormat:@"MMMM d"];
        
        // Display year only if <1yr
        if (diff >= 365) {
            [formatter setDateFormat:@"MMMM d, yyy"];
        }
        return [formatter stringFromDate:correctDate];
    }

}

@end
