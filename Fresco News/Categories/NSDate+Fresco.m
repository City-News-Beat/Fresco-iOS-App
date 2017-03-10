//
//  NSDate+Fresco.m
//  Fresco
//
//  Created by Maurice Wu on 2/23/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "NSDate+Fresco.h"

@implementation NSDate (Fresco)

+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;

    NSCalendar *calendar = [NSCalendar currentCalendar];

    [calendar rangeOfUnit:NSCalendarUnitDay
                startDate:&fromDate
                 interval:NULL
                  forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay
                startDate:&toDate
                 interval:NULL
                  forDate:toDateTime];

    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate
                                                 toDate:toDate
                                                options:0];

    return [difference day];
}

@end
