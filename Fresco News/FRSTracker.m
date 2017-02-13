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

+ (void)trackUser {
    if ([[FRSUserManager sharedInstance] authenticatedUser]) {
        NSString *userID = nil;
        
        FRSUser *user = [[FRSUserManager sharedInstance] authenticatedUser];
        NSMutableDictionary *identityDictionary = [[NSMutableDictionary alloc] init];
        
        if (user.uid && ![user.uid isEqual:[NSNull null]]) {
            userID = user.uid;
        }
        
        if (user.firstName && ![user.firstName isEqual:[NSNull null]]) {
            identityDictionary[@"name"] = user.firstName;
        }
        
        if (user.email && ![user.email isEqual:[NSNull null]]) {
            identityDictionary[@"email"] = user.email;
        }
        
        if(userID != nil) {
            [[SEGAnalytics sharedAnalytics] identify:userID traits:identityDictionary];
            [self tagUXCamUser:userID];
        }
    }
}



#pragma mark - Segment

+ (void)track:(NSString *)eventName parameters:(NSDictionary *)parameters {
    [FRSTracker startSegmentAnalytics];
    [[SEGAnalytics sharedAnalytics] track:eventName
                               properties:parameters];
}

+ (void)track:(NSString *)eventName {
    [FRSTracker startSegmentAnalytics];
    [[SEGAnalytics sharedAnalytics] track:eventName];
}

+ (void)startSegmentAnalytics {
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:[EndpointManager sharedInstance].currentEndpoint.segmentKey];
    configuration.trackApplicationLifecycleEvents = YES; // Enable this to record certain application events automatically!
    configuration.recordScreenViews = NO; // Enable this to record screen views automatically!

    [SEGAnalytics setupWithConfiguration:configuration];
}

+ (void)screen:(NSString *)screen {
    [FRSTracker startSegmentAnalytics];
    [FRSTracker screen:screen parameters:@{}];
}

+ (void)screen:(NSString *)screen parameters:(NSDictionary *)parameters {
    [FRSTracker startSegmentAnalytics];
    [[SEGAnalytics sharedAnalytics] screen:screen
                                properties:parameters];
}

+ (void)reset {
    [[SEGAnalytics sharedAnalytics] reset];
}



#pragma mark - UXCam

+ (void)startUXCam {
#if DEBUG // Avoid tracking when debugging
//    [UXCam startWithKey:UXCamKey appVariantIdentifier:@"joinedDev"];
#else
    [UXCam startWithKey:UXCamKey appVariantIdentifier:@"joinedProd"];
#endif
}

+ (void)stopUXCam {
    [UXCam stopApplicationAndUploadData];
}

/**
 Associates an identifiable string with the UXCam session.
 Tags session with UID and falls back on username. (Default username tag is the device name).
 
 @param userID An The user id that should be tracked.
 */

+ (void)tagUXCamUser:(NSString *)userID {
    if (userID) {
        [UXCam tagUsersName:userID];
    }
}

@end
