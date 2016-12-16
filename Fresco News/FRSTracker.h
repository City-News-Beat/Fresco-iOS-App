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

@interface FRSTracker : NSObject
{
    
}

+(void)track:(NSString *)eventName parameters:(NSDictionary *)parameters;
+(void)track:(NSString *)eventName;
+(void)screen:(NSString *)screen;
+(void)screen:(NSString *)screen parameters:(NSDictionary *)parameters;
+(void)startTracking;
+(void)reset;
@end
