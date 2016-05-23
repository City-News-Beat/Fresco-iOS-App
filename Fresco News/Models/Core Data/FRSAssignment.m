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

@implementation FRSAssignment

// Insert code here to add functionality to your managed object subclass

+(instancetype)assignmentWithDictionary:(NSDictionary *)dictionary{
    FRSAssignment *assignment = [FRSAssignment MR_createEntity];
    [assignment configureWithDictionary:dictionary];
    return assignment;
}

+(instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSAssignment *assignment = [NSEntityDescription insertNewObjectForEntityForName:@"FRSAssignment" inManagedObjectContext:context];
    [assignment configureWithDictionary:properties];
    return assignment;
}g

-(void)configureWithDictionary:(NSDictionary *)dictionary{
    self.uid = dictionary[@"id"];
    self.title = dictionary[@"title"];

    if (dictionary[@"location"][@"geo"][@"coordinates"] != Nil && ![dictionary[@"location"][@"geo"][@"coordinates"] isEqual: [NSNull null]]){
        NSArray *coords = dictionary[@"location"][@"geo"][@"coordinates"]; //coordinates are sent in geojson format meaning (long, lat)
        if (coords.count == 2){
            self.longitude = [coords firstObject];
            self.latitude = [coords lastObject];
        }
    }
    
    self.address = dictionary[@"location"][@"address"];
    self.radius = dictionary[@"location"][@"radius"];
    
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dictionary[@"time_created"] milliseconds:YES];
    NSInteger epoch = [dictionary[@"expiration_time"] integerValue];
    self.expirationDate = [NSDate dateWithTimeIntervalSince1970:epoch/1000];
    self.caption = dictionary[@"caption"];
}

@end
