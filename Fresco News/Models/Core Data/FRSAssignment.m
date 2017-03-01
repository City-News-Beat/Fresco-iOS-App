//
//  FRSAssignment.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSAssignment.h"
#import "FRSDateFormatter.h"
#import "MagicalRecord.h"
#import "FRSCoreData.h"
#import "NSString+Fresco.h"

@implementation FRSAssignment

// Insert code here to add functionality to your managed object subclass

+ (instancetype)assignmentWithDictionary:(NSDictionary *)dictionary {
    FRSAssignment *assignment = [FRSAssignment MR_createEntity];
    [assignment configureWithDictionary:dictionary];
    return assignment;
}

+ (instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSAssignment *assignment = [NSEntityDescription insertNewObjectForEntityForName:@"FRSAssignment" inManagedObjectContext:context];
    [assignment configureWithDictionary:properties];
    return assignment;
}

- (void)configureWithDictionary:(NSDictionary *)dictionary {

    if (dictionary[@"title"] && ![dictionary[@"title"] isEqual:[NSNull null]]) {
        self.title = dictionary[@"title"];
    }

    if (dictionary[@"id"] && ![dictionary[@"id"] isEqual:[NSNull null]]) {
        self.uid = dictionary[@"id"];
    }

    if (![dictionary[@"location"] isEqual: [NSNull null]] && dictionary[@"location"] != Nil && dictionary[@"location"][@"coordinates"] != Nil && ![dictionary[@"location"][@"coordinates"] isEqual: [NSNull null]]){
        NSArray *coords = dictionary[@"location"][@"coordinates"]; //coordinates are sent in geojson format meaning (long, lat)
        if (coords.count == 2) {
            self.longitude = [coords firstObject];
            self.latitude = [coords lastObject];
        }
    }

    if (dictionary[@"address"] && ![dictionary[@"address"] isEqual:[NSNull null]]) {
        self.address = dictionary[@"address"];
    }

    if (dictionary[@"radius"] && ![dictionary[@"radius"] isEqual:[NSNull null]]) {
        self.radius = dictionary[@"radius"];
    }

    self.createdDate = [NSString dateFromString:dictionary[@"starts_at"]];
    self.expirationDate = [NSString dateFromString:dictionary[@"ends_at"]];
    self.caption = dictionary[@"caption"];


//    NSString *dateStr = @"2012-05-03 06:03:00 +0000";
    NSString *dateStr = dictionary[@"starts_at"];

    NSDateFormatter *datFormatter = [[NSDateFormatter alloc] init];
    [datFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate* date = [datFormatter dateFromString:dateStr];
    NSLog(@"date: %@", [datFormatter stringFromDate:date]);
    
    
    if (dictionary[@"is_acceptable"]) {
        self.acceptable = dictionary[@"is_acceptable"];
    }

    if (dictionary[@"accepted"]) {
        self.accepted = dictionary[@"accepted"];
    }

    if (dictionary[@"outlets"]) {
        self.outlets = dictionary[@"outlets"];
    }
}

-(NSString *)getLocalDateTimeFromUTC:(NSString *)strDate
{
    NSDateFormatter *dtFormat = [[NSDateFormatter alloc] init];
    [dtFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dtFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *aDate = [dtFormat dateFromString:strDate];
    
    [dtFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dtFormat setTimeZone:[NSTimeZone systemTimeZone]];
    
    return [dtFormat stringFromDate:aDate];
}



@end
