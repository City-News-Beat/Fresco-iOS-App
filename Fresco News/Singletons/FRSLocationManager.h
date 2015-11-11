//
//  FRSLocationManager.h
//  Fresco
//
//  Created by Fresco News on 7/15/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

typedef enum : NSUInteger {
    LocationManagerStateBackground,
    LocationManagerStateForeground
} LocationManagerState;

@interface FRSLocationManager : CLLocationManager <CLLocationManagerDelegate>

+ (FRSLocationManager *)sharedManager;

/**
 *  Runs set up for location monitoring for respetive state
 *
 *  @param state LocationManagerState (background/foreground)
 */

- (void)setupLocationMonitoringForState:(LocationManagerState)state;

/**
 *  The Location Manager state
 */

@property (assign, nonatomic) LocationManagerState managerState;

/**
 *  Current location of the manager
 */

@property (strong, nonatomic) CLLocation *currentLocation;

@property (assign, nonatomic) BOOL stopLocationUpdates;


- (void)pingUserLocationToServer:(NSArray *)locations;

@end
