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

+(NSString *)dateStringGalleryFormatFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh:mm a";
    return [formatter stringFromDate:date];
}

//temp method
+(NSString *)dateStringFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    return [formatter stringFromDate:date];
}

@end
