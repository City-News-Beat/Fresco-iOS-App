//
//  ClusterAnnotation.h
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/28/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ClusterAnnotation : NSObject <MKAnnotation>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate clusterIndex:(NSInteger)clusterIndex;

@property (nonatomic) NSInteger clusterIndex;

@end
