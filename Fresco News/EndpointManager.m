//
//  EnpointHelper.m
//  Fresco
//
//  Created by Maurice Wu on 12/28/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "EndpointManager.h"

@implementation EndpointManager

+ (EndpointManager *)sharedInstance {
    static EndpointManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.currentEndpoint = [Endpoint new];
        #ifdef DEBUG
            [self.currentEndpoint setEndpoint:Dev];
            self.currentEndpoint.segmentKey = segmentWriteKeyDev;
        #else
            [self.currentEndpoint setEndpoint:Prod];
            self.currentEndpoint.segmentKey = segmentWriteKeyProd;
        #endif
    }
    return self;
}

- (NSDictionary *)typeDisplayNames {
    return @{ @(Dev) : @"dev",
              @(Prod) : @"prod" };
}

- (NSString *)typeDisplayName:(EndpointName)endpoint {
    return [self typeDisplayNames][@(endpoint)];
}

- (void)saveEndpoint:(EndpointName)endpoint {
    NSString *endpointString = [self typeDisplayName:endpoint];
    [[NSUserDefaults standardUserDefaults] setObject:endpointString forKey:@"endpoint"];
    [self.currentEndpoint setEndpoint:endpoint];
}

@end
