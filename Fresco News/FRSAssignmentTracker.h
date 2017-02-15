//
//  FRSAssignmentTracker.h
//  Fresco
//
//  Created by Omar Elfanek on 2/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSAssignment.h"

@interface FRSAssignmentTracker : NSObject

/**
 Tracks whether the user accepted or unaccepted the given assignment.
 
 @param assignment FRSAssignment to be tracked.
 @param accepted BOOL to determine if the accepted|unaccepted key will be sent.
 */
+ (void)trackAssignmentAccept:(FRSAssignment *)assignment didAccept:(BOOL)accepted;


/**
 Tracks whether the user clicked or dismissed the given assignment.
 
 @param assignment FRSAssignment to be tracked.
 @param accepted BOOL to determine if the clicked|dismissed key will be sent.
 */
+ (void)trackAssignmentClick:(FRSAssignment *)assignment didClick:(BOOL)clicked;

@end
