//
//  FRSLocationManager.m
//  Fresco
//
//  Created by Fresco News on 7/15/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSLocationManager.h"
#import "FRSDataManager.h"
#import "FRSAssignment.h"

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

@property (strong, nonatomic) NSTimer *locationTimer;

/*
** Current assignment of the location manager
*/

@property (strong, nonatomic) FRSAssignment *currentAssignment;

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
        
        [[FRSDataManager sharedManager] updateUserLocation:params block:^(BOOL sucess, NSError *error) {
            
            if(sucess)  NSLog(@"Successfully updated location");
            
        }];
        
        //Check if we're inactive, then send the local push for the assignment
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive || [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground){
            [self sendLocalPushForAssignment];
        }
        
//        Uncomment for local notifications while testing
//        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        notification.alertBody = [self.location description];
//        notification.soundName = UILocalNotificationDefaultSoundName;
//        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
//        notification.timeZone = [NSTimeZone defaultTimeZone];
//        [[UIApplication sharedApplication] setScheduledLocalNotifications:@[notification]];
        
        
    }
    
    //Stop updating location, will be turned back on `restartLocationUpdates` on the interval
    [self stopUpdatingLocation];
    
    //Set interval for location update every `locationUpdateInterval` seconds
    if (self.locationTimer == nil) {
          // NSLog(@"Starting timer...");
       self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_UPDATE_INTERVAL target:self selector:@selector(restartLocationUpdates) userInfo:nil repeats:YES];
        
    }
    
}

- (void)restartLocationUpdates
{
    [self startUpdatingLocation];
}

- (void)sendLocalPushForAssignment{

    [[FRSDataManager sharedManager] getAssignmentsWithinRadius:20 ofLocation:self.location.coordinate withResponseBlock:^(id responseObject, NSError *error) {
        
        if([responseObject count] > 0){
            
            FRSAssignment *retrievedAssignment = (FRSAssignment *)[responseObject firstObject];
            
            //Check if the current assignment is nil, or if the current assignment and the fethced one are different
            if(self.currentAssignment == nil
               || !([retrievedAssignment.assignmentId isEqualToString:self.currentAssignment.assignmentId])){
                
                CGFloat distanceInMiles = [self.location distanceFromLocation:retrievedAssignment.locationObject] / kMetersInAMile;
                
                //Checks if the user is within radius of the assignmnet
                if(distanceInMiles < [retrievedAssignment.radius floatValue]){
            
                    self.currentAssignment = [responseObject firstObject];
                    
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.alertBody = [NSString stringWithFormat:@"In range of %@", self.currentAssignment.title];
                    notification.userInfo = @{
                                              @"type" : @"assignment",
                                              @"assignment" : self.currentAssignment.assignmentId};
                    
                    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
                    notification.soundName = UILocalNotificationDefaultSoundName;
                    notification.timeZone = [NSTimeZone defaultTimeZone];
                    [[UIApplication sharedApplication] setScheduledLocalNotifications:@[notification]];
                    
                }
                
            }
        }
    }];
}



@end
