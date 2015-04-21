//
//  AssignmentsViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "AssignmentsViewController.h"
#import "UIViewController+Additions.h"

@interface AssignmentsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *storyBreaksNotification;

@property (weak, nonatomic) IBOutlet UILabel *assignmentTitle;
@property (weak, nonatomic) IBOutlet UILabel *assignmentTimeElapsed;
@property (weak, nonatomic) IBOutlet UILabel *assignmentDescription;
@property (weak, nonatomic) IBOutlet MKMapView *assignmentsMap;

@end

@implementation AssignmentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setFrescoImageHeader];
}

@end
