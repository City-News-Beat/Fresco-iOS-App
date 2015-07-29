//
//  AssignmentLocation.h
//  FrescoNews
//
//  Created by Fresco News on 5/22/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Foundation;
@import MapKit;

@interface AssignmentAnnotation : NSObject <MKAnnotation>

- (id)initWithAssignment:(FRSAssignment*)assignment andIndex:(NSInteger)index;

@property (nonatomic) NSInteger assignmentIndex;
@property (nonatomic) NSString *assignmentId;

@end
