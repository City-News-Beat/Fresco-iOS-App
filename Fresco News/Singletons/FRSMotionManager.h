//
//  FRSMotionManager.h
//  Fresco
//
//  Created by Fresco News on 9/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

@protocol FRSMotionMangerDelegate <NSObject>

- (void)orientationDidChange;

@end

@interface FRSMotionManager : CMMotionManager

+ (FRSMotionManager *)sharedManager;

@property (nonatomic) UIInterfaceOrientation lastOrientation;


/**
 *  Instance of the class's custom protocol
 */

@property (strong, nonatomic) id <FRSMotionMangerDelegate> delegate;

/**
 *  Begins Accelerometer updates
 */

- (void)startTrackingMovement;


/**
 *  Stops Accelerometer updates
 */

- (void)stopTrackingMovement;

@end
