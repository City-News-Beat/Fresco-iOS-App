//
//  AssignmentLocation.m
//  FrescoNews
//
//  Created by Fresco News on 5/22/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSAssignment.h"
#import "AssignmentAnnotation.h"
@import AddressBook;

@interface AssignmentAnnotation ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;

@end

@implementation AssignmentAnnotation

- (id)initWithAssignment:(FRSAssignment*)assignment andIndex:(NSInteger)index{
    
    if (self = [super init]) {
        
        if ([assignment.title isKindOfClass:[NSString class]])
            self.name = assignment.title;
        else
            self.name = @"Unknown Assignment";

        self.assignmentIndex = index;
        self.assignmentId = assignment.assignmentId;
        self.address = assignment.location[@"address"];
        self.theCoordinate = CLLocationCoordinate2DMake([assignment.lat floatValue], [assignment.lon floatValue]);
        
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
