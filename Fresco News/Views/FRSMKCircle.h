//
//  FRSMKCircle.h
//  Fresco
//
//  Created by Nicolas Rizk on 9/16/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum : NSInteger {
    FRSUserCircle = 0,
    FRSAssignmentCircle = 1
} FRSCircleType;

@interface FRSMKCircle : MKCircle

@property (nonatomic) FRSCircleType identifier;

//- (instancetype)initWithIdentifier: (FRSCircleType)identifier;

@end
