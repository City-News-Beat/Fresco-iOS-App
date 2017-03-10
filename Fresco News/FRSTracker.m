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
#import "FRSAssignment.h"
#import "Adjust.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <Crashlytics/Crashlytics.h>
#import <Smooch/Smooch.h>
#import <Analytics/SEGAnalytics.h>
#import <Segment_Flurry/SEGFlurryIntegrationFactory.h>
#import <Segment_Localytics/SEGLocalyticsIntegrationFactory.h>
#import <UXCam/UXCam.h>

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
    [[SEGAnalytics sharedAnalytics] track:eventName
                               properties:parameters
                                  options:@{ @"integrations": @{ @"All": @YES }}];
}

+ (void)track:(NSString *)eventName {
    [self track:eventName parameters:@{}];
}

+ (void)startSegmentAnalytics {
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:[EndpointManager sharedInstance].currentEndpoint.segmentKey];
    [configuration use:[SEGFlurryIntegrationFactory instance]];
    [configuration use:[SEGLocalyticsIntegrationFactory instance]];
    configuration.trackApplicationLifecycleEvents = YES; // Enable this to record certain application events automatically!
    configuration.recordScreenViews = NO; // Enable this to record screen views automatically!

    [SEGAnalytics setupWithConfiguration:configuration];
}

+ (void)screen:(NSString *)screen {
    [FRSTracker screen:screen parameters:@{}];
}

+ (void)screen:(NSString *)screen parameters:(NSDictionary *)parameters {
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

#pragma mark - Adjust

+ (void)launchAdjust{
    NSString *yourAppToken = adjustAppKey;
    NSString *environment = ADJEnvironmentProduction;
    
    #if DEBUG
        environment = ADJEnvironmentSandbox;
    #endif
    
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken
                                                environment:environment];
    
    [Adjust appDidLaunch:adjustConfig];
}

#pragma mark - Fabric

+ (void)configureFabric {
    [[Twitter sharedInstance] startWithConsumerKey:[EndpointManager sharedInstance].currentEndpoint.twitterConsumerKey consumerSecret:[EndpointManager sharedInstance].currentEndpoint.twitterConsumerSecret];
    [Fabric with:@[ [Twitter class], [Crashlytics class] ]];
}

#pragma mark - Smooch

+ (void)configureSmooch {
    [Smooch initWithSettings:[SKTSettings settingsWithAppToken:[EndpointManager sharedInstance].currentEndpoint.smoochToken]];
}


@end
