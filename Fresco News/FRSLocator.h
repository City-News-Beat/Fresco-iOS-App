//
//  FRSLocator.h
//  Fresco
//
//  Created by Philip Bernstein on 3/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <stdio.h>
#import <time.h>

/*
 Completely new location manager that does not subclass CLLocationManager, instead simply utilizes its abilities to send notifications to anyone who needs them. Creation is with battery optimization in mind. While app is in foreground, we can optimize for very specific locations. While app is in background, we can debate, but should probably track significant change (every 3-4m, or 500m location difference). While the app is completely terminated, we have no choice but to track significant location changes, which is handled by the App Delegate.
 
 Designed to be separate from API. In 3.0 it should be handled by FRSApiClient; in 2.x it will be handle by FRSDataManager.
 To watch for location changes, simply register for the notification constant defined below. This decouples location tracking from any other class, something I think will drastically help in 3.0.
 */

static NSString * const FRSLocationUpdateNotification = @"FRSLocationUpdateNotification";
typedef void (^BackgroundBlock)(NSArray *locations); // allows us to add ability for background task (in case app is killed in background)

@interface FRSLocator : NSObject <CLLocationManagerDelegate>
{
    NSTimer *stopTimer;
}

@property (nonatomic, assign) UIApplicationState currentState;
@property (nonatomic, assign) CLLocation *currentLocation;
@property (nonatomic, assign) unsigned long lastLocationUpdate; // epoch timestamp of last location update
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BackgroundBlock backgroundBlock; // block to execute if app is in background state

-(void)manualUpdate;

+(instancetype)sharedLocator;

@end
