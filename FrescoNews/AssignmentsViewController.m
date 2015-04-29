//
//  AssignmentsViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "AssignmentsViewController.h"
#import "UIViewController+Additions.h"
#import "MKMapView+LegalLabel.h"

#define kSCROLL_VIEW_INSET 100

@interface AssignmentsViewController () <UIScrollViewDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *storyBreaksNotification;
@property (weak, nonatomic) IBOutlet UIView *storyBreaksView;
@property (weak, nonatomic) IBOutlet UIView *detailViewWrapper;

@property (weak, nonatomic) IBOutlet UILabel *assignmentTitle;
@property (weak, nonatomic) IBOutlet UILabel *assignmentTimeElapsed;
@property (weak, nonatomic) IBOutlet UILabel *assignmentDescription;
@property (weak, nonatomic) IBOutlet MKMapView *assignmentsMap;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign, nonatomic) BOOL centeredUserLocation;
@end

@implementation AssignmentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setFrescoImageHeader];
    
    self.scrollView.delegate = self;
    self.assignmentsMap.delegate = self;
    
    self.centeredUserLocation = NO;
    
    [self tweakUI];
    [self insertFakeData];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.detailViewWrapper
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.detailViewWrapper
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:rightConstraint];
}


- (void)tweakUI {
    // UI Values
    self.storyBreaksView.backgroundColor = [UIColor colorWithHex:[VariableStore sharedInstance].colorStoryBreaksBackground];
    self.detailViewWrapper.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.detailViewWrapper.layer.shadowOpacity = 0.26;
    self.detailViewWrapper.layer.shadowOffset = CGSizeMake(-1, 0);
}

- (void)zoomToCurrentLocation {
    // Zooming map after delay for effect
    MKCoordinateSpan span = MKCoordinateSpanMake(0.0002f, 0.0002f);
    MKCoordinateRegion region = {self.assignmentsMap.userLocation.location.coordinate, span};
    
    MKCoordinateRegion regionThatFits = [self.assignmentsMap regionThatFits:region];
    NSLog(@"Fit Region %f %f", regionThatFits.center.latitude, regionThatFits.center.longitude);

    [self.assignmentsMap setRegion:regionThatFits animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    static BOOL firstTime = YES;
    if (firstTime) {
        // move the legal link in order to tuck the map behind nicely
        [self.assignmentsMap offsetLegalLabel:CGSizeMake(0, -kSCROLL_VIEW_INSET)];
    }
    firstTime = NO;
}

- (void)viewDidLayoutSubviews
{
    self.scrollView.contentInset = UIEdgeInsetsMake(self.assignmentsMap.frame.size.height - kSCROLL_VIEW_INSET, 0, 0, 0);
}

- (void)insertFakeData {
    // "Real Fake Data"
    self.storyBreaksNotification.text = @"Click here to be notified when a story breaks in your area";
    self.assignmentTitle.text= @"Pileup by Dame Tipping Primary School";
    self.assignmentDescription.text = @"Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed.";
    
    self.assignmentDescription.text = @"Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three casualities; police and EMS have not confirmed. Six cars and one truck were involved in a major car accident on North Rd/B175. Eyewitness reports suggest at least three ca";
    
    self.assignmentTimeElapsed.text = @"3m";
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentSize.height - scrollView.frame.size.height)];
    }
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"Failed to locate user: %@", error);
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // center on the current location
    if (!self.centeredUserLocation)
        [self zoomToCurrentLocation];
    
    self.centeredUserLocation = YES;
    
    //[self.assignmentsMap setCenterCoordinate:self.assignmentsMap.userLocation.location.coordinate animated:YES];
}
@end
