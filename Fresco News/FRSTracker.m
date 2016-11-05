//
//  FRSTracker.m
//  Fresco
//
//  Created by Philip Bernstein on 9/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSTracker.h"
#import <Mixpanel/Mixpanel.h>

@implementation FRSTracker
+(void)track:(NSString *)eventName parameters:(NSDictionary *)parameters {
    [[Mixpanel sharedInstance] track:eventName properties:parameters];
}
+(void)track:(NSString *)eventName {
    [[Mixpanel sharedInstance] track:eventName];
}

@end
