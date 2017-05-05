//
//  FRSReachability.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/5/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSReachability.h"
#import "Reachability.h"

@implementation FRSReachability

+(BOOL)isCurrentlyConnectedToInternet {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

@end
