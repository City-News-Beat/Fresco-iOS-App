//
//  ClusterAnnotation.h
//  FrescoNews
//
//  Created by Fresco News on 5/28/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Foundation;
@import MapKit;

@interface ClusterAnnotation : NSObject <MKAnnotation>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate clusterIndex:(NSInteger)clusterIndex;

@property (nonatomic) NSInteger clusterIndex;

@end
