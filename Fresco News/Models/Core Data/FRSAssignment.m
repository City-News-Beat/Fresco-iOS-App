//
//  FRSAssignment.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSAssignment.h"
#import "FRSDateFormatter.h"
#import <MagicalRecord/MagicalRecord.h>
#import "FRSDataValidator.h"
#import "FRSCoreData.h"

@implementation FRSAssignment

// Insert code here to add functionality to your managed object subclass

+(instancetype)assignmentWithDictionary:(NSDictionary *)dictionary{
    FRSAssignment *assignment = [FRSAssignment MR_createEntity];
    [assignment configureWithDictionary:dictionary];
    return assignment;
}

-(void)configureWithDictionary:(NSDictionary *)dictionary{
    self.uid = dictionary[@"_id"];
    self.title = dictionary[@"title"];

    if ([FRSDataValidator isNonNullObject:dictionary[@"location"][@"geo"][@"coordinates"]]){
        NSArray *coords = dictionary[@"location"][@"geo"][@"coordinates"]; //coordinates are sent in geojson format meaning (long, lat)
        if (coords.count == 2){
            self.longitude = [coords firstObject];
            self.latitude = [coords lastObject];
        }
    }
    
    self.address = dictionary[@"location"][@"address"];
    self.radius = dictionary[@"location"][@"radius"];
    
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dictionary[@"time_created"] milliseconds:YES];
    self.expirationDate = [FRSDateFormatter dateFromEpochTime:dictionary[@"expiration"] milliseconds:YES];
    self.caption = dictionary[@"caption"];
}
//@property (nullable, nonatomic, retain) NSString *uid;
//@property (nullable, nonatomic, retain) NSString *title;
//@property (nullable, nonatomic, retain) NSString *caption;
//@property (nullable, nonatomic, retain) NSNumber *active;
//@property (nullable, nonatomic, retain) id location;
//@property (nullable, nonatomic, retain) NSNumber *radius;
//@property (nullable, nonatomic, retain) NSDate *createdDate;
//@property (nullable, nonatomic, retain) NSDate *editedDate;
//@property (nullable, nonatomic, retain) NSDate *expirationDate;

@end
