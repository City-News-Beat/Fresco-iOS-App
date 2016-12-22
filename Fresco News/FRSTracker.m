//
//  FRSTracker.m
//  Fresco
//
//  Created by Philip Bernstein on 9/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSTracker.h"
#import <Segment_Flurry/SEGFlurryIntegrationFactory.h>
#import <Segment_Mixpanel/SEGMixpanelIntegrationFactory.h>
#import <Segment_Localytics/SEGLocalyticsIntegrationFactory.h>
#import <Segment_Adjust/SEGAdjustIntegrationFactory.h>

@implementation FRSTracker
+(void)track:(NSString *)eventName parameters:(NSDictionary *)parameters {
    [FRSTracker startTracking];
    [[SEGAnalytics sharedAnalytics] track:eventName
                               properties:parameters];
}
+(void)track:(NSString *)eventName {
    
    [FRSTracker startTracking];
    [[SEGAnalytics sharedAnalytics] track:eventName];
}

+(void)startTracking {
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:segmentWriteKey];
    configuration.trackApplicationLifecycleEvents = YES; // Enable this to record certain application events automatically!
    configuration.recordScreenViews = NO; // Enable this to record screen views automatically!
    
    [configuration use:[SEGFlurryIntegrationFactory instance]];
    [configuration use:[SEGMixpanelIntegrationFactory instance]];
    [configuration use:[SEGLocalyticsIntegrationFactory instance]];
    [configuration use:[SEGAdjustIntegrationFactory instance]];
    
    [SEGAnalytics setupWithConfiguration:configuration];
}

+(void)screen:(NSString *)screen {
    [FRSTracker startTracking];
    [FRSTracker screen:screen parameters:@{}];
}

+(void)screen:(NSString *)screen parameters:(NSDictionary *)parameters {
    [FRSTracker startTracking];
    [[SEGAnalytics sharedAnalytics] screen:screen
                                properties:parameters];
}

+(void)reset {
    [[SEGAnalytics sharedAnalytics] reset];
}

@end
