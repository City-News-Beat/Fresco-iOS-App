//
//  FRSAssignmentTracker.m
//  Fresco
//
//  Created by Omar Elfanek on 2/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSAssignmentTracker.h"
#import "FRSLocationManager.h"

@implementation FRSAssignmentTracker


#pragma mark - Assignment Tracking

+ (void)trackAssignmentAccept:(FRSAssignment *)assignment didAccept:(BOOL)accepted {
    [FRSTracker track:(accepted ? assignmentAccepted : assignmentUnaccepted) parameters:[self trackedParamsFromAssignment:assignment]];
}

+ (void)trackAssignmentClick:(FRSAssignment *)assignment didClick:(BOOL)clicked {
    [FRSTracker track:(clicked ? assignmentClicked : assignmentDismissed)];
}

/**
 Creates an NSDictionary formatted for assignment tracking.
 
 @param assignment FRSAssignment
 @return NSDictionary formatted with the assignment id and the distance away from the current user.
 */
+ (NSDictionary *)trackedParamsFromAssignment:(FRSAssignment *)assignment {
    NSDictionary *trackedParams = @{ASSIGNMENT_ID: assignment.uid, DISTANCE_AWAY: @([FRSLocationManager calculatedDistanceFromAssignment:assignment])};
    return trackedParams;
}

@end
