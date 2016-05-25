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

+(instancetype)assignmentWithDictionary:(NSDictionary *)dictionary{
    FRSAssignment *assignment = [FRSAssignment MR_createEntity];
    [assignment configureWithDictionary:dictionary];
    return assignment;
}

+(instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSAssignment *assignment = [NSEntityDescription insertNewObjectForEntityForName:@"FRSAssignment" inManagedObjectContext:context];
    [assignment configureWithDictionary:properties];
    return assignment;
}

-(void)configureWithDictionary:(NSDictionary *)dictionary {
    
    self.uid = dictionary[@"id"];
    self.title = dictionary[@"title"];

    if (dictionary[@"location"][@"coordinates"] != Nil && ![dictionary[@"location"][@"coordinates"] isEqual: [NSNull null]]){
        NSArray *coords = dictionary[@"location"][@"coordinates"]; //coordinates are sent in geojson format meaning (long, lat)
        if (coords.count == 2){
            self.longitude = [coords firstObject];
            self.latitude = [coords lastObject];
        }
    }
    
    self.address = dictionary[@"address"];
    self.radius = dictionary[@"radius"];
    
    self.createdDate = [[FRSAPIClient sharedClient] dateFromString:dictionary[@"starts_at"]];
    self.expirationDate = [[FRSAPIClient sharedClient] dateFromString:dictionary[@"ends_at"]];
    self.caption = dictionary[@"caption"];
}

@end
