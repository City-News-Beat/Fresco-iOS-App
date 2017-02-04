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
+ (void)startSegmentAnalytics;
+ (void)reset;

/**
 Combines both the Segment user tracking event with the UXCam tracking event into one method call.
 */
+ (void)trackUser;

/**
 Stops tracking users screen.
 */
+ (void)stopUXCam;

/**
 Starts tracking users screen using UXCam.
 */
+ (void)startUXCam;

@end
