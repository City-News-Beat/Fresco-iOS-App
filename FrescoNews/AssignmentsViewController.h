//
//  AssignmentsViewController.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FRSBaseViewController.h"
#import "FRSAssignment.h"

@interface AssignmentsViewController : FRSBaseViewController

@property (nonatomic, strong) FRSAssignment *currentAssignment;

- (void)setAssignment:(FRSAssignment *)assignment navigateToAssignment:(BOOL)navigate;

@end
