//
//  FRSDateFormatter.h
//  Fresco
//
//  Created by Daniel Sun on 1/8/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSDateFormatter : NSDateFormatter

+ (NSDate *)dateFromEpochTime:(id)epochTime milliseconds:(BOOL)milliseconds;
+ (NSString *)dateStringGalleryFormatFromDate:(NSDate *)date;
+ (NSString *)timestampStringFromDate:(NSDate *)date;
+ (NSString *)relativeTimeFromDate:(NSDate *)compareDate;
+ (NSString *)dateDifference:(NSDate *)date withAbbreviatedMonth:(BOOL)abbreviated;
+ (NSString *)formattedTimestampFromDate:(NSDate *)date;

@end
