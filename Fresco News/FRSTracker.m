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
#import "FRSAuthManager.h"
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
#import <ZendeskSDK/ZendeskSDK.h>

@implementation FRSTracker

+ (void)trackUser {
//    if ([[FRSAuthManager sharedInstance] isAuthenticated]) {
//        NSString *userID = nil;
//
//        FRSUser *user = [[FRSUserManager sharedInstance] authenticatedUser];
//        NSMutableDictionary *identityDictionary = [[NSMutableDictionary alloc] init];
//
//        if (user.uid && ![user.uid isEqual:[NSNull null]]) {
//            userID = user.uid;
//        }
//
//        if (user.firstName && ![user.firstName isEqual:[NSNull null]]) {
//            identityDictionary[@"name"] = user.firstName;
//        }
//
//        if (user.email && ![user.email isEqual:[NSNull null]]) {
//            identityDictionary[@"email"] = user.email;
//        }
//
//        if (user.username && ![user.username isEqual:[NSNull null]]) {
//            identityDictionary[@"username"] = user.username;
//        }
//
//        if (userID != nil) { // Note: When this method is called from didFinishLaunching there is no authenticated user.
//            [[SEGAnalytics sharedAnalytics] identify:userID traits:identityDictionary];
//            [self tagUXCamUser:userID];
//        }
//        [self configureZendesk]; // We're adding the Zendesk config here to avoid making another isAuthenticated check.
//    }
}

#pragma mark - Segment

+ (void)track:(NSString *)eventName parameters:(NSDictionary *)parameters {
//    [[SEGAnalytics sharedAnalytics] track:eventName
//                               properties:parameters
//                                  options:@{ @"integrations": @{ @"All": @YES }}];
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
//    [[SEGAnalytics sharedAnalytics] screen:screen
//                                properties:parameters];
}

+ (void)reset {
//    [[SEGAnalytics sharedAnalytics] reset];
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

#pragma mark - Zendesk

+ (void)configureZendesk {
    
    #if DEBUG
        [ZDKLogger enable:YES];
    #endif
    
    [[ZDKConfig instance]
     initializeWithAppId:@"ca506e6c52eb2eca41150684af0269b6642facef5d23a84e"
     zendeskUrl:@"https://fresco.zendesk.com"
     clientId:@"mobile_sdk_client_6e930a7bb6123d229c39"];
    
    ZDKAnonymousIdentity *identity = [ZDKAnonymousIdentity new];
    identity.name = [[[FRSUserManager sharedInstance] authenticatedUser] firstName];
    identity.email = [[[FRSUserManager sharedInstance] authenticatedUser] email];
    [ZDKConfig instance].userIdentity = identity;
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
