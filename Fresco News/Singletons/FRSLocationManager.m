//
//  FRSLocationManager.m
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSLocationManager.h"
#import "FRSAppDelegate.h"
#import "FRSAssignment.h"

#define TIMER_INTERVAL 30

@interface FRSLocationManager () <CLLocationManagerDelegate>

@property (strong, nonatomic) NSNotificationCenter *notificationCenter;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSArray *updatedLocations;

@end

@implementation FRSLocationManager

+ (instancetype)sharedManager {
    static FRSLocationManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      _manager = [[FRSLocationManager alloc] init];
    });
    return _manager;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.delegate = self;

        self.monitoringState = FRSLocationMonitoringStateOff;

        self.activityType = CLActivityTypeFitness;

        if ([self respondsToSelector:@selector(setPausesLocationUpdatesAutomatically:)]) {
            [self setPausesLocationUpdatesAutomatically:YES];
        }

        if ([self respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
            [self setAllowsBackgroundLocationUpdates:YES];
        }

        self.notificationCenter = [NSNotificationCenter defaultCenter];
    }
    
    return self;
}

#pragma mark - Monitoring

- (void)startLocationMonitoringBackground {

    if (self.monitoringState == FRSLocationMonitoringStateBackground)
        return;
    else if (self.monitoringState == FRSLocationMonitoringStateForeground) {
        [self stopUpdatingLocation];
    }

    self.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

    [self startMonitoringSignificantLocationChanges];

    self.monitoringState = FRSLocationMonitoringStateBackground;
}

- (void)startLocationMonitoringForeground {
    //Check if we're already monitoring
    if (self.monitoringState == FRSLocationMonitoringStateForeground){
        return;
    } else if (self.monitoringState == FRSLocationMonitoringStateBackground) {
        [self stopMonitoringSignificantLocationChanges];
    }


    self.desiredAccuracy = kCLLocationAccuracyBest;

    self.monitoringState = FRSLocationMonitoringStateForeground;

    [self startUpdatingLocation];
}

- (void)pauseLocationMonitoring {
    if (self.monitoringState == FRSLocationMonitoringStateBackground) {
        [self stopMonitoringSignificantLocationChanges];
    } else if (self.monitoringState == FRSLocationMonitoringStateForeground) {
        [self stopUpdatingLocation];
    }

    self.monitoringState = FRSLocationMonitoringStateOff;

    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Authorizaton

- (void)handleAuthorizationWithCompletion:(void (^)(BOOL authorized))completion {
    if ([FRSLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        completion(YES);
    } else if ([FRSLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self requestAlwaysAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        
    } else {
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!locations.count) {
        return NSLog(@"FRSLocationManager did not return any locations");
    }

    if (![self significantLocationChangeForLocation:[locations lastObject]]) {
        return;

    }
    
    self.lastAcquiredLocation = [locations lastObject];
}

- (BOOL)significantLocationChangeForLocation:(CLLocation *)location {
    if (!self.lastAcquiredLocation) {
        return YES;
    } else if ([self.lastAcquiredLocation distanceFromLocation:location] > 5.0) {
        return YES;
    }

    return NO;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"FRSLocationManager failed to retrieve locations with error : %@", error.localizedDescription);
}


+ (float)calculatedDistanceFromAssignment:(FRSAssignment *)assignment {
    CLLocation *assignmentLocation = [[CLLocation alloc] initWithLatitude:assignment.latitude.floatValue longitude:assignment.longitude.floatValue];
    CLLocationManager *userLocation = [[CLLocationManager alloc] init];
    float distance = (float)[assignmentLocation distanceFromLocation:[userLocation location]];
    return (distance / metersInAMile);
}


@end
