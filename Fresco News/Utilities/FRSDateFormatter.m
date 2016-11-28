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

+(NSString *)timestampStringFromDate:(NSDate *)date {
    NSTimeInterval doubleDiff = [date timeIntervalSinceNow];
    long diff = (long) doubleDiff;
    int seconds = diff % 60;
    diff = diff / 60;
    int minutes = diff % 60;
    diff = diff / 60;
    int hours = diff % 24;
    int days = diff / 24;
    
    NSString *timestampString;
    
    if (days < 0) {
        days *= -1;
    }
    if (hours < 0) {
        hours *= -1;
    }
    if (minutes < 0) {
        minutes *= -1;
    }
    if (seconds < 0) {
        seconds *= -1;
    }
    
    if (days != 0) {
        timestampString = [NSString stringWithFormat:@"%d days ago", days];
        if (days >= 1 && days < 2) {
            timestampString = [NSString stringWithFormat:@"%d day ago", days];
        }
    } else if (hours != 0) {
        timestampString = [NSString stringWithFormat:@"%d hours ago", hours];
        if (hours == 1 && hours < 2) {
            timestampString = [NSString stringWithFormat:@"%d hour ago", hours];
        }
    } else if (minutes != 0) {
        timestampString = [NSString stringWithFormat:@"%d minutes ago", minutes];
        if (minutes == 1 && minutes < 2) {
            timestampString = [NSString stringWithFormat:@"%d minute ago", minutes];
        }
    } else if (seconds != 0) {
        timestampString = [NSString stringWithFormat:@"%d seconds ago", seconds];
        if (seconds == 1 && seconds <2) {
            timestampString = [NSString stringWithFormat:@"%d second ago", seconds];
        }
    }
    
    if ([timestampString containsString:@"-"]) {
        NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"-"];
        timestampString = [[timestampString componentsSeparatedByCharactersInSet:trim] componentsJoinedByString:@""];
    }
    
    return timestampString;
}

//temp method
+(NSString *)dateStringFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    return [formatter stringFromDate:date];
}

@end
