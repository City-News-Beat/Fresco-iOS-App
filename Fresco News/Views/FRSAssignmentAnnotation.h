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

@property (nonatomic) NSInteger assignmentIndex;
@property (nonatomic) NSString *assignmentId;

-(instancetype)initWithAssignment:(FRSAssignment *)assignment atIndex:(NSInteger)index;

@end
