//
//  FRSLocator.m
//  Fresco
//
//  Created by Elmir Kouliev on 3/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSLocator.h"
#import "FRSUserManager.h"

@implementation FRSLocator

+ (instancetype)sharedLocator {
    static FRSLocator *sharedLocator = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
      sharedLocator = [[FRSLocator alloc] init];
    });

    return sharedLocator;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        [self defaultSetup];
    }

    return self;
}

- (BOOL)awake {
    return self == nil;
}

#pragma mark - Configuration

- (void)defaultSetup {
//    [self checkForCachedLocation];
    [self setupLocationManager];
}

/*
 Sets up CLLocationManager to be used in class.
 */
- (void)setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.activityType = CLActivityTypeFitness;

    // background notifications
    if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        self.locationManager.allowsBackgroundLocationUpdates = TRUE;
    }
    
    [self updateLocationManagerForState:[[UIApplication sharedApplication] applicationState]];
}

/**
 Checks for a cached location and sends that to the app to start
 */
- (void)checkForCachedLocation {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:cachedLocation]){
        NSDictionary *loc = (NSDictionary *)[[NSUserDefaults standardUserDefaults] dictionaryForKey:cachedLocation];
        self.currentLocation = [[CLLocation alloc]
                                initWithLatitude:(CLLocationDegrees)[loc[@"latitude"] floatValue]
                                longitude:(CLLocationDegrees)[loc[@"latitude"] floatValue]];
        [self handlePassiveChange:self.currentLocation];
    }
}

/*
 Sends NSNotification out through the default notification center, for any observers to use the new location
 */
- (void)sendNotificationForUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:FRSLocationUpdateNotification
         object:nil
         userInfo:@{ @"location" : self.currentLocation }];
    });
}

#pragma mark - CLLocationManager Delegate

/**
 Updates locaiton manager depending on state passed
 
 @param state UIApplicationState we want to confiugre the app for
 */
- (void)updateLocationManagerForState:(UIApplicationState)state {
    self.currentState = state;
    if(state == UIApplicationStateActive) {
        [self trackAsActive];
    } else if(state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
        [self trackAsPassive];
        //Update immediatelly as the location manager will have one ready immediatlely if the app is launched
        //from the background.
        [self handlePassiveChange:self.locationManager.location];
    }
}


/**
 Starts background task to update location

 @param location Current location of the user
 */
- (void)startBackgroundLocationTask:(CLLocation *)location {
    //Don't create multiple background tasks until the current one is finished
    if(self.backgroundTask != UIBackgroundTaskInvalid) return;
    
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
    
    //Check if task is valid before trying to run the update
    if (self.backgroundTask == UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
    } else {
        [[FRSUserManager sharedInstance] updateUserLocation:[[CLLocation alloc] initWithLatitude:2.0 longitude:2.0]
                                                 completion:^(id responseObject, NSError *error) {
                                                     if (error) {
                                                         NSLog(@"Location Error");
                                                     } else {
                                                         NSLog(@"Background Location Updated");
                                                     }
                                                 }];
    }
}

- (void)endBackgroundTask {
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
    self.backgroundTask = UIBackgroundTaskInvalid;
}

/*
 Changes location manager configuration into active state. This simply means we track the location to a higher accuracy.
 */
- (void)trackAsActive {
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
}

/*
 Typically called when the app enters a background state and we only want to
 track signifcant changes to the location which a lower accuracy
 */
- (void)trackAsPassive {
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    [self.locationManager startMonitoringSignificantLocationChanges];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if ([locations count] == 0) {
        return;
    }
    
    CLLocation *currentLocation = [locations firstObject];

    switch (self.currentState) {
        case UIApplicationStateActive:
            [self handleActiveChange:currentLocation];
            break;
        case UIApplicationStateBackground:
            [self handlePassiveChange:currentLocation];
            break;
        default:
            [self handlePassiveChange:currentLocation];
            break;
    }
}

/*
 Manually request a new location from our location manager
 */
- (void)manualUpdate {
    if (self.locationManager) {
        [self.locationManager requestLocation];
    }
}

/**
 Handle location update as if user has application open. We use a timer here
 to make sure we only save locations every 10 seconds. After 10 seconds the location manager is 
 restarted and the tiemr is cleared. In this method it'll be re-created once the location manager handles an active change
 
 When the locaiton is handled it will update state in the class so the rest
 of the app has an update to date idea of what's going on with the 
 location i.e. last update, current location.
 
 A notificaiton will also be broadcasted here to the rest of the app with the location.

 @param location Location to handle change with
 */
- (void)handleActiveChange:(CLLocation *)location {
    if (self.stopTimer == nil) {
        [self.locationManager stopUpdatingLocation];
        self.currentLocation = location;
        self.lastLocationUpdate = [NSDate date];
        [self cacheLocation:location];
        [self sendNotificationForUpdate];
        
        self.stopTimer = [NSTimer timerWithTimeInterval:10
                                            target:self
                                          selector:@selector(restartLocationUpdate)
                                          userInfo:Nil
                                           repeats:FALSE];

        [[NSRunLoop mainRunLoop] addTimer:self.stopTimer forMode:NSRunLoopCommonModes];
    }
}

/**
 Handle location update if user has application in background.

 @param location Location to handle change with
 */
- (void)handlePassiveChange:(CLLocation *)location {
    [self startBackgroundLocationTask:location];
}

/**
 Restarts location updates and nullifies the timer
 */
- (void)restartLocationUpdate {
    if (self.stopTimer) {
        [self.stopTimer invalidate];
        self.stopTimer = Nil;
    }
    
    [self.locationManager startUpdatingLocation];
}

/**
 Caches location into NSUserDefaults for us

 @param location CLLocation we want to save
 */
- (void)cacheLocation:(CLLocation *)location {
    [[NSUserDefaults standardUserDefaults]
     setObject:@{
                 @"latitude": [NSNumber numberWithDouble:(float)location.coordinate.latitude],
                 @"longitude": [NSNumber numberWithDouble:(float)location.coordinate.longitude]
                 }
     forKey:cachedLocation];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
