//
//  FRSLocator.m
//  Fresco
//
//  Created by Elmir Kouliev on 3/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSLocator.h"
#import "FRSUserManager.h"
#import "FRSSessionManager.h"
#import "EndpointManager.h"

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
        [self setupLocationManager];
    }
    
    return self;
}

- (BOOL)awake {
    return self == nil;
}

#pragma mark - Configuration

/*
 Sets up CLLocationManager to be used in class.
 */
- (void)setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.activityType = CLActivityTypeOther;
    self.locationManager.distanceFilter = 20;
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    
    // background notifications
    if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        self.locationManager.allowsBackgroundLocationUpdates = TRUE;
    }
    
    self.currentLocation = [self cachedLocation];
    
    [self updateLocationManagerForState:[[UIApplication sharedApplication] applicationState]];
}

/**
 Updates locaiton manager depending on state passed
 
 @param state UIApplicationState we want to confiugre the app for
 */
- (void)updateLocationManagerForState:(UIApplicationState)state {
    if(state == UIApplicationStateActive) {
        [self trackAsActive];
    } else if((state == UIApplicationStateBackground || state == UIApplicationStateInactive) && self.currentState != UIApplicationStateBackground) {
        [self trackAsPassive];
        //Immediatlely start background task we don't run out of time
        [self startBackgroundLocationTask];
    }
    
    self.currentState = state;
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
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [self.locationManager startMonitoringSignificantLocationChanges];
}


#pragma mark - Background Mode

/**
 Starts a new background task. Sets backgroundTask in class as well.
 */
- (void)startBackgroundLocationTask {
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTaskId = UIBackgroundTaskInvalid;
    
    if([application respondsToSelector:@selector(beginBackgroundTaskWithExpirationHandler:)]){
        bgTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"background task %lu expired", (unsigned long)bgTaskId);
            [application endBackgroundTask:bgTaskId];
            bgTaskId = UIBackgroundTaskInvalid;
        }];
        
        if (self.backgroundTask == UIBackgroundTaskInvalid || self.backgroundTask == 0) {
            self.backgroundTask = bgTaskId;
            NSLog(@"started master task %lu", (unsigned long)self.backgroundTask);
        } else {
            NSLog(@"started background task %lu", (unsigned long)bgTaskId);
        }
    }
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if ([locations count] == 0) return;
    
    [self updateWithAccurateLocation:locations];
    
    //If timer is still valid, return
    if(self.stopTimer != nil) return;
    
    switch (self.currentState) {
        case UIApplicationStateActive:
            [self handleActiveChange];
            break;
        case UIApplicationStateBackground:
            [self handlePassiveChange];
            break;
        default:
            [self handlePassiveChange];
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
 to make sure we only save locations every 60 seconds. After 60 seconds the location manager is
 restarted and the timer is cleared. In this method it'll be re-created once the location manager handles an active change
 */
- (void)handleActiveChange {
    [self.locationManager stopUpdatingLocation];
    [self sendNotificationForUpdate];
    [self cacheLocation:self.currentLocation];
    
    //Restart in 10 seconds
    self.stopTimer = [NSTimer
                      scheduledTimerWithTimeInterval:60
                      target:self
                      selector:@selector(restartLocationUpdate)
                      userInfo:nil
                      repeats:NO];
}

/**
 Handle location update if user has application in background. Here we
 don't want to stop the location manager because that will prevent the app from re-opening.
 We simply save and cache, and then restart the timer in 300 seconds.
 */
- (void)handlePassiveChange {
    [self startBackgroundLocationTask];
    [self cacheLocation:self.currentLocation];
    [self sendLocationToServerWithCompletionHandler:nil];
    
    //Restart in 300 seconds
    self.stopTimer = [NSTimer
                      scheduledTimerWithTimeInterval:300
                      target:self
                      selector:@selector(restartLocationUpdate)
                      userInfo:nil
                      repeats:NO];
    
}

/**
 Restarts location updates and nullifies the timer
 */
- (void)restartLocationUpdate {
    if (self.stopTimer) {
        [self.stopTimer invalidate];
        self.stopTimer = nil;
    }
    
    [self.locationManager startUpdatingLocation];
}


/**
 Selects an accurate and valid locaiton for us from a list of locations.
 
 When the locaiton is found this method will update state in the class so the rest
 of the class can access the new location
 
 @param locations Array of CLLocation objects
 */
- (void)updateWithAccurateLocation:(NSArray *)locations {
    for(int i=0;i<locations.count;i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        
        //Select only valid location
        if(newLocation!=nil && (!(theLocation.latitude==0.0 && theLocation.longitude==0.0))){
            self.currentLocation = newLocation;
            self.lastLocationUpdate = [NSDate date];
            break;
        }
    }
}

#pragma mark - Communication Methods

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

/**
 Caches location into NSUserDefaults for us. We cache every time there's a location change
 
 @param location CLLocation we want to save
 */
- (void)cacheLocation:(CLLocation *)location {
    [[NSUserDefaults standardUserDefaults]
     setObject:@{
                 @"latitude": [NSNumber numberWithDouble:(float)location.coordinate.latitude],
                 @"longitude": [NSNumber numberWithDouble:(float)location.coordinate.longitude],
                 @"date": [NSDate date]
                 }
     forKey:cachedLocation];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocation *)cachedLocation {
    NSDictionary *location = [[NSUserDefaults standardUserDefaults] objectForKey:cachedLocation];
    
    if(!location || location[@"longitude"] == nil || location[@"latitude"] == nil) {
        return nil;
    }
    
    
    return [[CLLocation alloc]
            initWithLatitude:(CLLocationDegrees)[location[@"latitude"] floatValue]
            longitude:(CLLocationDegrees)[location[@"longitude"] floatValue]];
}


#pragma mark - Networking

/**
 Sends location to the server through NSURLSession which is permitted in the background.
 *Note* We only have 30 seconds here
 
 @param completion The completion handler sent to us through the delegate method. Must be called when finished.
 */
- (void)sendLocationToServerWithCompletionHandler:(id)completion{
    void (^completionHandler)(UIBackgroundFetchResult) = completion;
    
    CLLocation *location = [self cachedLocation];
    
    if(!location) {
        if(completionHandler) completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    [[FRSUserManager sharedInstance] updateUserLocation:location completion:^(id responseObject, NSError *error) {
        if(error){
            if(completionHandler) completionHandler(UIBackgroundFetchResultFailed);
        } else {
            if(completionHandler) completionHandler(UIBackgroundFetchResultNewData);
        }
    }];
}


@end

