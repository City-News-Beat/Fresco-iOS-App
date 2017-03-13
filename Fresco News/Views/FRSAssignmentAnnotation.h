//
//  FRSAssignmentAnnotation.h
//  Fresco
//
//  Created by Daniel Sun on 1/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
@class FRSAssignment;

@interface FRSAssignmentAnnotation : NSObject <MKAnnotation>

- (instancetype)initWithAssignment:(FRSAssignment *)assignment atIndex:(NSInteger)index;
@property (strong, nonatomic) FRSAssignment *assignment;

// TODO: Remove all these properties and use annotation.assignment.property when implementing
- (NSString *)title;
- (NSString *)subtitle;
- (NSDate *)assignmentExpirationDate;
- (NSDate *)assignmentPostedDate;
@property (nonatomic) NSInteger assignmentIndex;
@property (nonatomic) NSString *assignmentId;
@property (nonatomic) NSArray *outlets;
@property (nonatomic) BOOL isAcceptable; // add isAcceptable to model

@end
