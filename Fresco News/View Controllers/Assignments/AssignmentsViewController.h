//
//  AssignmentsViewController.h
//  FrescoNews
//
//  Created by Fresco News on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;
@import MapKit;
#import "FRSBaseViewController.h"
#import "FRSAssignment.h"

@interface AssignmentsViewController : FRSBaseViewController

/*
** Represents the current assignment being viewed
*/

@property (nonatomic, strong) FRSAssignment *currentAssignment;

/*
** Persistent array of assignments
*/

@property (nonatomic, strong) NSMutableArray *assignments;

/*
** Persistent array of clusters i.e. clusters repreresent a group of assignments
*/

@property (nonatomic, strong) NSMutableArray *clusters;

/*
** Tells us if the user is already centered
*/

@property (assign, nonatomic) BOOL centeredUserLocation;

-(void)setCurrentAssignment:(FRSAssignment *)currentAssignment navigateTo:(BOOL)navigate present:(BOOL)present;

- (void)zoomToCurrentLocation;

@end
