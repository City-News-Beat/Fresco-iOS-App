//
//  FRSLocationManager.m
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSLocationManager.h"

@interface FRSLocationManager() <CLLocationManagerDelegate>

@property (strong, nonatomic) NSNotificationCenter *notificationCenter;

@end

@implementation FRSLocationManager

+(instancetype)sharedManager{
    static FRSLocationManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[FRSLocationManager alloc] initPrivate];
    });
    return _manager;
}

-(instancetype)initPrivate{
    self = [super init];
    if (self){
        self.delegate = self;
        
        self.monitoringState = FRSLocationMonitoringStateOff;
        
        self.pausesLocationUpdatesAutomatically = YES;
        self.activityType = CLActivityTypeFitness;
        
        if([self respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]){
            [self setAllowsBackgroundLocationUpdates:YES];
        }
        
        self.notificationCenter = [NSNotificationCenter defaultCenter];
        
    }
    return self;
}


#pragma mark - Monitoring

-(void)startLocationMonitoringForBackground{
    
    if (self.monitoringState == FRSLocationMonitoringStateBackground)
        return;
    else if (self.monitoringState == FRSLocationMonitoringStateAlways){
        [self stopUpdatingLocation];
    }
    
    self.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    
    
    [self startMonitoringSignificantLocationChanges];
    
    self.monitoringState = FRSLocationMonitoringStateBackground;
}

-(void)startLocationMonitoringAlways{
    if (self.monitoringState == FRSLocationMonitoringStateAlways)
        return;
    else if (self.monitoringState == FRSLocationMonitoringStateBackground){
        [self stopMonitoringSignificantLocationChanges];
    }
    
    //This should be moved out of here. THis is just temporary.
    [self requestAlwaysAuthorization];
    
    self.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self startUpdatingLocation];
    
    self.monitoringState = FRSLocationMonitoringStateAlways;
}

-(void)pauseLocationMonitoring{
    [self stopMonitoringSignificantLocationChanges];
    [self stopUpdatingLocation];
    self.monitoringState = FRSLocationMonitoringStateOff;
}

#pragma mark - Authorizaton

-(void)handleAuthorizationWithCompletion:(void(^)(BOOL authorized))completion{
    if ([FRSLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways){
        completion(YES);
    }
    else if ([FRSLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        [self requestAlwaysAuthorization];
    }
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusAuthorizedAlways){
        
    }
    else {
        
    }
}



-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [self.notificationCenter postNotificationName:NOTIF_LOCATIONS_UPDATE object:nil userInfo:@{@"locations" : locations}];
    
    if (!locations.count){
        NSLog(@"FRSLocationManager did not return any locatoins");
        return;
    }
    
    
    
}

@end
