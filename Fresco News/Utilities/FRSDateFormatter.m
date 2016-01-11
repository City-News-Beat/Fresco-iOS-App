//
//  FRSDateFormatter.m
//  Fresco
//
//  Created by Daniel Sun on 1/8/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDateFormatter.h"

@implementation FRSDateFormatter

+(NSDate*)dateFromEpochTime:(id)epochTime{
    double seconds = [epochTime doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

+(NSString *)dateStringGalleryFormatFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh:mm a";
    return [formatter stringFromDate:date];
}

@end
