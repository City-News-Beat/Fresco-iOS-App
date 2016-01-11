//
//  FRSLocationManager.h
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, FRSLocationMonitoringState){
    FRSLocationMonitoringStateOff,
    FRSLocationMonitoringStateAlways,
    FRSLocationMonitoringStateBackground
};

@interface FRSLocationManager : CLLocationManager

@property (nonatomic) FRSLocationMonitoringState monitoringState;

@property (strong, nonatomic) CLLocation *lastAcquiredLocation;


+(instancetype)sharedManager;

-(void)startLocationMonitoringAlways;

-(void)startLocationMonitoringForBackground;

-(void)pauseLocationMonitoring;

@end
