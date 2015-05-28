//
//  AssignmentLocation.m
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/22/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "AssignmentAnnotation.h"
#import <AddressBook/AddressBook.h>

@interface AssignmentAnnotation ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;

@end

@implementation AssignmentAnnotation

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
    
    return ![self.address isEqual:[NSNull null]] ? _address : NSLocalizedString(@"Get Directions", nil);
}



- (CLLocationCoordinate2D)coordinate {
    return _theCoordinate;
}



@end
