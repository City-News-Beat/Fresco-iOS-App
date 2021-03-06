//
//  FRSAssignmentsViewController.h
//  Fresco
//
//  Created by Fresco News on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"
#import <CoreData/CoreData.h>
#import "MagicalRecord.h"
#import "FRSAssignment.h"

@import MapKit;

@interface FRSAssignmentsViewController : FRSBaseViewController <UIScrollViewDelegate> {
    __weak UIScrollView *currentScroller; // weak b/c we only want to hold reference when in view
    BOOL isScrolling;

    NSTimer *scrollTimer;
    BOOL notFirstFetch;
}

@property CGFloat assignmentLat;
@property CGFloat assignmentLong;
@property (nonatomic) BOOL hasDefault;
@property (strong, nonatomic) UIButton *closeButton;
@property (nonatomic, retain) NSString *defaultID;

@property BOOL mapShouldFollowUser;
@property BOOL assignmentCardIsOpen;
@property (strong, nonatomic) FRSAssignment *selectedAssignment;

- (void)globalAssignmentsSegue;
- (void)setInitialMapRegion;
- (void)configureMap;

@end
