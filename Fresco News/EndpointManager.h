//
//  EnpointHelper.h
//  Fresco
//
//  Created by User on 12/28/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Endpoint.h"

@interface EndpointManager : NSObject

typedef NS_ENUM(NSUInteger, EndpointName) {
    Dev,
    Prod
};

@property (nonatomic, strong) Endpoint *currentEndpoint;

+ (EndpointManager *)sharedInstance;

- (void)saveEndpoint:(EndpointName)endpoint;

@end
