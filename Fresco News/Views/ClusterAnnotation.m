//
//  ClusterAnnotation.m
//  FrescoNews
//
//  Created by Fresco News on 5/28/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "ClusterAnnotation.h"

@interface ClusterAnnotation ()

@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;

@end

@implementation ClusterAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate clusterIndex:(NSInteger)clusterIndex{
    
    if ((self = [super init])) {
        self.clusterIndex = clusterIndex;
        self.theCoordinate = coordinate;
    }
    return self;


}

- (CLLocationCoordinate2D)coordinate {
    return _theCoordinate;
}


@end
