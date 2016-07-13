//
//  FRSLocator.m
//  Fresco
//
//  Created by Philip Bernstein on 3/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSLocator.h"
#import "FRSAPIClient.h"

@implementation FRSLocator


+(instancetype)sharedLocator {
    static FRSLocator *sharedLocator = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedLocator = [[FRSLocator alloc] init];
    });
    
    return sharedLocator;
}

/*
 Just in case we want custom initializations in the future. -init calls default setup, which calls abstracted setup methods. Will be possible in future to have different setups for different situations.
 */
-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self defaultSetup];
    }
    
    return self;
}

/*
 Sets up CLLocationManager, and sets us up to receive UIApplicationState change notifications
 */

-(void)checkForCachedLocation {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"fresco-last-longitude"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"fresco-last-latitude"]) {
        NSNumber *latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"fresco-last-latitude"];
        NSNumber *longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"fresco-last-longitude"];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        self.currentLocation = location;
        
        NSDictionary *userInfo = @{@"lat":@(_currentLocation.coordinate.latitude), @"lng":@(_currentLocation.coordinate.longitude)};
        
        // propogate last location through notification center
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:FRSLocationUpdateNotification object:Nil userInfo:userInfo];
        });
    }
}

-(void)defaultSetup {
    [self setupNotifications];
    [self setupLocationManager];
    [self checkForCachedLocation];
    
    self.backgroundBlock = ^(NSArray *locations) {
        UIApplication *app = [UIApplication sharedApplication];
        
        __block UIBackgroundTaskIdentifier locationUpdateTaskID = [app beginBackgroundTaskWithExpirationHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (locationUpdateTaskID != UIBackgroundTaskInvalid) {
                    [app endBackgroundTask:locationUpdateTaskID];
                    locationUpdateTaskID = UIBackgroundTaskInvalid;
                }
            });
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CLLocation *currentLocation = [locations firstObject];
            NSDictionary *userLocation = @{@"lat":@(currentLocation.coordinate.latitude), @"lng":@(currentLocation.coordinate.longitude)};
            
            [[FRSAPIClient sharedClient] pingLocation:userLocation completion:^(id responseObject, NSError *error) {
                if (error) {
                    NSLog(@"Location Error");
                }
                else {
                    NSLog(@"Background Location Updated");
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (locationUpdateTaskID != UIBackgroundTaskInvalid) {
                        [app endBackgroundTask:locationUpdateTaskID];
                        locationUpdateTaskID = UIBackgroundTaskInvalid;
                    }
                });

            }];
        });
        
    };
}

-(void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationStateChange:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationStateChange:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationStateChange:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

/*
 Initializes location manager if first call, otherwise does default setup
 */
-(void)setupLocationManager {
    
    BOOL firstSetup = FALSE;
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        firstSetup = TRUE;
    }
    
    // background notifications
    if([_locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]){
        _locationManager.allowsBackgroundLocationUpdates = TRUE;
    }
    
    
    if (firstSetup) {
        [self trackAsActive]; // first initialization, we have foreground (unless the construct of spacetime has changed)
    }
}

/*
 Handles the various application state changes, and makes the matching method call
 */
-(void)applicationStateChange:(NSNotification *)notification {
    
    NSString *stateType = notification.name;
    
    if (stateType == UIApplicationWillEnterForegroundNotification) {
        [self trackAsActive];
    }
    else if (stateType == UIApplicationDidEnterBackgroundNotification) {
        [self trackAsPassive];
    }
    else if (stateType == UIApplicationWillTerminateNotification) {
        [self trackAsPassive];
    }
    else { // who knows
        [self trackAsPassive];
    }
}

/*
 We have the current visual foreground (phone is on, screen is lit, and they're using our app. It's generally okay to track the user quite granularly in this scenario.
 */
-(void)trackAsActive {
    
    _currentState = UIApplicationStateActive;
    
    [_locationManager requestWhenInUseAuthorization];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager requestLocation];
}

/*
 App is in background, we don't really need constant updates, so we register for significant location changes, not consistent updates every xx seconds or meters
 */
-(void)trackAsPassive { // let device decide when to tell us when we need an update
    
    _currentState = UIApplicationStateBackground;
    
    [_locationManager stopUpdatingLocation];
    [_locationManager startMonitoringSignificantLocationChanges];
}


/*
 This will track every xx seconds or meters, using defferment or a timer (whichever works best for battery)
 */
-(void)trackAsModerate { // in between active and passive, a low-accuracy, high-break track
    
    // don't think I'm actually going to implement this until I can figure out a use case.
    if (![self stateDidChange:UIApplicationStateActive]) {
        return;
    }
    
}

/*
 Simple method to check whether or not we're receiving redundant notifications
 */
-(BOOL)stateDidChange:(UIApplicationState)oldState {
    return (oldState != _currentState);
}

/*
 Handle a location update from the location manager
 */

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    stopTimer = [NSTimer timerWithTimeInterval:10
                                        target:self
                                      selector:@selector(restartActiveUpdates)
                                      userInfo:Nil
                                       repeats:FALSE];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if ([locations count] == 0) {
        return;
    }
    
    switch (_currentState) {
        case UIApplicationStateActive:
            [self handleActiveChange:locations];
            break;
        case UIApplicationStateBackground:
            [self handlePassiveChange:locations];
            break;
        default:
            break;
    }
    
    [self sendNotificationForUpdate:locations];
    
    _lastLocationUpdate = (unsigned long)time(NULL); // epoch timestamp
}

/*
 Handle location update as if user has application open
 */
-(void)handleActiveChange:(NSArray *)locations {
    
    [_locationManager stopUpdatingLocation];
    
    stopTimer = [NSTimer timerWithTimeInterval:10
                                        target:self
                                      selector:@selector(restartActiveUpdates)
                                      userInfo:Nil
                                       repeats:FALSE];
    
    [[NSRunLoop mainRunLoop] addTimer:stopTimer forMode:NSRunLoopCommonModes];
    [self cacheLocation:[locations firstObject]];
}

-(void)cacheLocation:(CLLocation *)location {
    float longitude = location.coordinate.longitude;
    float latitude = location.coordinate.latitude;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(longitude) forKey:@"fresco-last-longitude"];
    [[NSUserDefaults standardUserDefaults] setObject:@(latitude) forKey:@"fresco-last-latitude"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)restartActiveUpdates {
    
    if (stopTimer) {
        [stopTimer invalidate];
        stopTimer = Nil;
    }
    
    if (_currentState == UIApplicationStateActive) {
        [_locationManager requestLocation];
    }
}

/*
 Handle location update as if user has application in background
 */
-(void)handlePassiveChange:(NSArray *)locations {
    if (_backgroundBlock) {
        _backgroundBlock(locations);
    }
    else {
        [self handleActiveChange:locations];
    }
    
    [self cacheLocation:[locations firstObject]];
}

/*
 Sends NSNotification out through the default notification center, for any observers to use the new location
 */
-(void)sendNotificationForUpdate:(NSArray *)locations {
    _currentLocation = (CLLocation *)[locations lastObject];
    
    // sends out as NSNotification, sends array of locations as well as preformed params for API update
    NSDictionary *userInfo = @{@"lat":@(_currentLocation.coordinate.latitude), @"lng":@(_currentLocation.coordinate.longitude)};
    
    // make sure we're on the main thread so the updates actually get receieved
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FRSLocationUpdateNotification object:Nil userInfo:userInfo];
    });
}

/*
 Manually request a new location from our location manager
 */
-(void)manualUpdate {
    if (_locationManager) {
        [_locationManager requestLocation];
    }
}

/* 
    Fetch cached assignments, should be used in conjunction with API client
 */

+(NSArray *)localAssignments {
    return @[];
}

+(NSArray *)globalAssignments {
    return @[];

}

+(NSArray *)allAssignments {
    return @[];
}

@end