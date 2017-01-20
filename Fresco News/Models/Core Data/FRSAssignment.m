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
#import "FRSAPIClient.h"

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

    self.createdDate = [[FRSAPIClient sharedClient] dateFromString:dictionary[@"starts_at"]];
    self.expirationDate = [[FRSAPIClient sharedClient] dateFromString:dictionary[@"ends_at"]];
    self.caption = dictionary[@"caption"];

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

@end
