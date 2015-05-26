//
//  AssignmentLocation.h
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/22/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AssignmentLocation : NSObject <MKAnnotation>

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;

- (MKMapItem*)mapItem;

@end
