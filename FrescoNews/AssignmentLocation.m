//
//  AssignmentLocation.m
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/22/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "AssignmentLocation.h"
#import <AddressBook/AddressBook.h>

@interface AssignmentLocation ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;

@end

@implementation AssignmentLocation

- (id)initWithName:(NSString*)name address:(NSString*)address assignmentIndex:(NSInteger)assignmentIndex coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        if ([name isKindOfClass:[NSString class]]) {
            self.name = name;
        } else {
            self.name = @"Unknown Assignment";
        }
        self.assignmentIndex = assignmentIndex;
        self.address = address;
        self.theCoordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    return _name;
}

- (NSString *)subtitle {
    return _address;
}

- (CLLocationCoordinate2D)coordinate {
    return _theCoordinate;
}

- (MKMapItem*)mapItem {
    
    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : _address};
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    mapItem.name = self.title;
    
    return mapItem;
}

@end
