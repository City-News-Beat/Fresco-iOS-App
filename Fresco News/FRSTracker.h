//
//  FRSTracker.h
//  Fresco
//
//  Created by Philip Bernstein on 9/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fresco.h"
#import <Analytics/SEGAnalytics.h>
#import <UXCam/UXCam.h>


@interface FRSTracker : NSObject {
}

+ (void)track:(NSString *)eventName parameters:(NSDictionary *)parameters;
+ (void)track:(NSString *)eventName;
+ (void)screen:(NSString *)screen;
+ (void)screen:(NSString *)screen parameters:(NSDictionary *)parameters;
+ (void)startTracking;
+ (void)reset;

/**
 Associates an identifiable string with the UXCam session.
 Tags session with UID and falls back on username. (Default username tag is the device name).
 */
+ (void)tagUXCamUser;

/**
 Stops tracking users screen
 */
+ (void)stopUXCam;

/**
 Starts tracking users screen using UXCam (3rd party)
 */
+ (void)startUXCam;

@end
