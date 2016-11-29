//
//  FRSTracker.h
//  Fresco
//
//  Created by Philip Bernstein on 9/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSTracker : NSObject
{
    
}

+(void)track:(NSString *)eventName parameters:(NSDictionary *)parameters;
+(void)track:(NSString *)eventName;
@end
