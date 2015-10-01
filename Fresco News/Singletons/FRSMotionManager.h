//
//  FRSMotionManager.h
//  Fresco
//
//  Created by Fresco News on 9/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

@interface FRSMotionManager : CMMotionManager

+ (FRSMotionManager *)sharedManager;

@property (nonatomic) UIInterfaceOrientation lastOrientation;

- (void)startTrackingMovement;
- (void)stopTrackingMovement;
@end
