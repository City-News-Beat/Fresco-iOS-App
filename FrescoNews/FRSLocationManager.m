//
//  FRSLocationManager.m
//  Fresco
//
//  Created by Fresco News on 7/15/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSLocationManager.h"
#import "FRSDataManager.h"

@interface FRSLocationManager ()

/*
** Current location of the manager
*/

@property (strong, nonatomic) CLLocation *currentLocation;

/*
** Timer for location update interval
*/

@property (strong, nonatomic) NSTimer *timer;

/*
** Condition var to tell if the interval is already set
*/

@property (assign, nonatomic) BOOL intervalSet;

@end

@implementation FRSLocationManager

#pragma mark - static methods

+ (FRSLocationManager *)sharedManager
{
    static FRSLocationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![CLLocationManager locationServicesEnabled]) {
            // User has disabled location services on this device
            return;
        }
        manager = [[FRSLocationManager alloc] init];
    });
    return manager;
}

- (void)setupLocationMonitoring
{
    /* How to debug background location updates, in the simulator
     1. Pause at beginning of didFinishLaunchingWithOptions (if necessary for steps 2 and/or 3 below)
     2. Xcode/scheme location simulation should be disabled, i.e. Select "Don't Simulate Location" from the pulldown
     2b. Better: Edit Scheme > Run > Options > Core Location > Default Location > Set to "None"
     3. Simulate location via iOS Simulator > Debug > Location > Freeway Drive
     4. Unpause
     5. Terminate the app
     6. Monitor background launches via iOS Simulator > Debug > Open System Log...
     6b. Also you may be able to debug background launches using scheme launch option "Wait for executable to be launched"
     */
    // NSLog(@"Background launch via UIApplicationLaunchOptionsLocationKey");
    self.delegate = self;
    
    self.pausesLocationUpdatesAutomatically = YES;

    [self requestAlwaysAuthorization];
    [self requestWhenInUseAuthorization];
    
    self.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self startMonitoringSignificantLocationChanges];
    
}

#pragma mark - Location Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{

    if (!self.currentLocation || [self.currentLocation distanceFromLocation:[locations lastObject]] > 0) {

        self.currentLocation = [locations lastObject];
        
        NSDictionary *params = @{@"lat" : @(self.location.coordinate.latitude),
                                 @"lon" : @(self.location.coordinate.longitude)};
        
        [[FRSDataManager sharedManager] updateUserLocation:params block:nil];
        
//        //Uncomment for local notifications while testing
//        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        notification.alertBody = [self.location description];
//        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
//        notification.timeZone = [NSTimeZone defaultTimeZone];
//        [[UIApplication sharedApplication] setScheduledLocalNotifications:@[notification]];
        
        NSLog(@"Successfully updated location");
        
    }
    else {
        // NSLog(@"not a new location");
    }
    
    //Set interval for location update every `locationUpdateInterval` seconds
    if (!self.intervalSet) {
          // NSLog(@"Starting timer...");
        [NSTimer scheduledTimerWithTimeInterval:[VariableStore sharedInstance].locationUpdateInterval target:self selector:@selector(restartLocationUpdates) userInfo:nil repeats:YES];
        
        self.intervalSet = YES;
    
    }

    //Stop updating location, will be turned back on `restartLocationUpdates` on the interval
    [self stopUpdatingLocation];
    
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
//    [self stopMonitoringSignificantLocationChanges];
//    [self stopUpdatingLocation];
}

- (void)restartLocationUpdates
{
    [self startUpdatingLocation];
}


@end
