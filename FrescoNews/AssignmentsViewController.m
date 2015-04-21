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
@property (weak, nonatomic) IBOutlet UIView *storyBreaksView;
@property (weak, nonatomic) IBOutlet UIView *detailViewWrapper;

@property (weak, nonatomic) IBOutlet UILabel *assignmentTitle;
@property (weak, nonatomic) IBOutlet UILabel *assignmentTimeElapsed;
@property (weak, nonatomic) IBOutlet UILabel *assignmentDescription;
@property (weak, nonatomic) IBOutlet MKMapView *assignmentsMap;


@end

@implementation AssignmentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setFrescoImageHeader];
    
    // UI Values
    self.storyBreaksView.backgroundColor = [UIColor colorWithHex:[VariableStore sharedInstance].colorStoryBreaksBackground];
    self.detailViewWrapper.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.detailViewWrapper.layer.shadowOpacity = 0.26;
    self.detailViewWrapper.layer.shadowOffset = CGSizeMake(-1, 0);
    
    
    // "Real Fake Data"
    self.storyBreaksNotification.text = @"Click here to be notified when a story breaks in your area";
    self.assignmentTitle.text= @"Pileup by Dame Tipping Primary School";
    self.assignmentDescription.text = @"Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed.";
    self.assignmentTimeElapsed.text = @"3m";
}

@end
