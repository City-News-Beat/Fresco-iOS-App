//
//  CLLocation+Fresco.h
//  Fresco
//
//  Created by Elmir Kouliev on 2/27/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "FRSAPIClient.h"
#import "FRSAssignment.h"

@interface CLLocation (Fresco)

/**
 Fetches address as string for the calling CLLocation

 @param completion Complection handler that provides the address
 */
- (void)fetchAddress:(FRSAPIDefaultCompletionBlock)completion;



/**
 Calculates the distance from an assignment and the user's location

 @param assignment The assignment to calculate with
 @return Returns distance from assignment, in miles
 */
+ (float)calculatedDistanceFromAssignment:(FRSAssignment *)assignment;

@end
