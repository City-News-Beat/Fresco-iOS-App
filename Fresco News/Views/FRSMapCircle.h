//
//  FRSMapCircle.h
//  Fresco
//
//  Created by Daniel Sun on 1/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef NS_ENUM(NSInteger, FRSMapCircleType) {
    FRSMapCircleTypeUser = 0,
    FRSMapCircleTypeAssignment
};

@interface FRSMapCircle : MKCircle

@property (nonatomic) FRSMapCircleType circleType;

@end
