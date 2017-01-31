//
//  FRSTracker.m
//  Fresco
//
//  Created by Philip Bernstein on 9/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSTracker.h"
#import "EndpointManager.h"
#import "FRSUserManager.h"

@implementation FRSTracker
+ (void)track:(NSString *)eventName parameters:(NSDictionary *)parameters {
    [FRSTracker startTracking];
    [[SEGAnalytics sharedAnalytics] track:eventName
                               properties:parameters];
}
+ (void)track:(NSString *)eventName {

    [FRSTracker startTracking];
    [[SEGAnalytics sharedAnalytics] track:eventName];
}

+ (void)startTracking {
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:[EndpointManager sharedInstance].currentEndpoint.segmentKey];
    configuration.trackApplicationLifecycleEvents = YES; // Enable this to record certain application events automatically!
    configuration.recordScreenViews = NO; // Enable this to record screen views automatically!

    [SEGAnalytics setupWithConfiguration:configuration];
}

+ (void)screen:(NSString *)screen {
    [FRSTracker startTracking];
    [FRSTracker screen:screen parameters:@{}];
}

+ (void)screen:(NSString *)screen parameters:(NSDictionary *)parameters {
    [FRSTracker startTracking];
    [[SEGAnalytics sharedAnalytics] screen:screen
                                properties:parameters];
}

+ (void)reset {
    [[SEGAnalytics sharedAnalytics] reset];
}



+ (void)startUXCam {
#if DEBUG // Avoid tracking when debugging
#else
    [UXCam startWithKey:UXCamKey];
    [self tagUXCamUser];
#endif
}


+ (void)stopUXCam {
    [UXCam stopApplicationAndUploadData];
}


+ (void)tagUXCamUser {
    if ([FRSUserManager sharedInstance].authenticatedUser.uid) {
        [UXCam tagUsersName:[[FRSUserManager sharedInstance].authenticatedUser uid]];
    } else if ([FRSUserManager sharedInstance].authenticatedUser.username) { // Fall back on username if UID is not found
        [UXCam tagUsersName:[[FRSUserManager sharedInstance].authenticatedUser username]];
    }
}

@end
