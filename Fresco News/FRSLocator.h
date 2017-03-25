//
//  FRSLocator.h
//  Fresco
//
//  Created by Elmir Kouliev on 3/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

static NSString *const FRSLocationUpdateNotification = @"FRSLocationUpdateNotification";

/**
 Allows us to add ability for background task (in case app is killed in background)

 @param location Location to handle
 */
typedef void (^BackgroundBlock)(CLLocation *location);

/**
 General purpose location manager used across the app. Handles location monitoring in foreground and background. This class
 reacts to Application state changes i.e. foreground, background.
 */
@interface FRSLocator : NSObject <CLLocationManagerDelegate>

/**
 Current application state of the class
 */
@property (nonatomic, assign) UIApplicationState currentState;

@property (nonatomic, assign) NSInteger backgroundTask;

/**
 Timer used to start and stop the location manager
 */
@property (nonatomic, strong) NSTimer *stopTimer;

/**
 Current location of the uer
 */
@property (nonatomic, retain) CLLocation *currentLocation;

/**
 Epoch timestamp of last location update
 */
@property (nonatomic, assign) NSDate *lastLocationUpdate;

/**
 CLLocationManager
 */
@property (nonatomic, strong) CLLocationManager *locationManager;

/**
 Block to execute if app is in background state
 */
@property (nonatomic, assign) BackgroundBlock backgroundBlock;

/**
 Singleton accessor

 @return Instance of FRSLocater
 */
+ (instancetype)sharedLocator;

/**
 Used to simple make sure the FRSLocator is on and running

 @return True if it is awake, False if not
 */
- (BOOL)awake;

- (void)manualUpdate;

/**
 Updates locaiton manager depending on state passed
 
 @param state UIApplicationState we want to confiugre the app for
 */
- (void)updateLocationManagerForState:(UIApplicationState)state;

@end

/**
 Protocol definition for the FRSLocater. See optional methods below.
 */
@protocol FRSLocatorDelegate <NSObject>

@optional

/**
 Delegate responder for when the FRSLocater has a new location to provide

 @param newLocation The new location of the user
 */
- (void)locationChanged:(CLLocation*)newLocation;

@end
