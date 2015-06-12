//
//  AssignmentLocation.h
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/22/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Foundation;
@import MapKit;

@interface AssignmentAnnotation : NSObject <MKAnnotation>

- (id)initWithName:(NSString*)name address:(NSString*)address assignmentIndex:(NSInteger)assignmentIndex coordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic) NSInteger assignmentIndex;

@end
