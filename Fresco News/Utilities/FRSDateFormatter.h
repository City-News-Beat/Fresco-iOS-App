//
//  FRSDateFormatter.h
//  Fresco
//
//  Created by Daniel Sun on 1/8/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSDateFormatter : NSDateFormatter

+(NSDate*)dateFromEpochTime:(id)epochTime;
+(NSString *)dateStringGalleryFormatFromDate:(NSDate *)date;

@end
