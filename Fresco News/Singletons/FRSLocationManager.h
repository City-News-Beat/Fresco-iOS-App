//
//  FRSLocationManager.h
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "FRSAssignmentManager.h"
#import "FRSAssignment.h"

typedef NS_ENUM(NSInteger, FRSLocationMonitoringState) {
    FRSLocationMonitoringStateOff,
    FRSLocationMonitoringStateForeground,
    FRSLocationMonitoringStateBackground
};

@interface FRSLocationManager : CLLocationManager

@property (nonatomic) FRSLocationMonitoringState monitoringState;

@property (strong, nonatomic) CLLocation *lastAcquiredLocation;

+ (instancetype)sharedManager;

- (void)startLocationMonitoringForeground;

- (void)startLocationMonitoringBackground;

- (void)pauseLocationMonitoring;

- (BOOL)significantLocationChangeForLocation:(CLLocation *)location;


/**
 This method takes in an assignment ID and fetches the associated assignment before calculating the distance away from the authenticated user and returning it in the response.

 @param assignmentID NSString ID of the assignment to be used when requesting the associated assignment object.
 @param completion FRSAPIDefaultCompletionBlock to notify the caller when the assignment has been fetched.
 */
+ (void)calculatedDistanceFromAssignmentWithID:(NSString *)assignmentID completion:(FRSAPIDefaultCompletionBlock)completion;

/**
 This method takes an assignment and returns the distance away from the authenticated user.

 @param assignment FRSAssignment to compare against the authenticated users location.
 @return float Distance away from the authenticated user in miles.
 */
+ (float)calculatedDistanceFromAssignment:(FRSAssignment *)assignment;

@end
