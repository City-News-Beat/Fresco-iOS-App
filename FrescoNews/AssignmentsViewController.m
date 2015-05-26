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
#import "MTLModel+Additions.h"
#import "FRSDataManager.h"
#import "AssignmentLocation.h"

#define kSCROLL_VIEW_INSET 100

@class FRSAssignment;

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

    @property (assign, nonatomic) NSNumber *operatingRadius;

@end

@implementation AssignmentsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setFrescoImageHeader];
    
    self.scrollView.delegate = self;
    
    self.assignmentsMap.delegate = self;
    
    [self tweakUI];
    
    //Go to user location
    
    [self zoomToCurrentLocation];
    
//    [self updateAssignments];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    static BOOL firstTime = YES;
    if (firstTime) {
        // move the legal link in order to tuck the map behind nicely
        [self.assignmentsMap offsetLegalLabel:CGSizeMake(0, -kSCROLL_VIEW_INSET)];
    }
    firstTime = NO;
}

- (void)viewDidLayoutSubviews{
    self.scrollView.contentInset = UIEdgeInsetsMake(self.assignmentsMap.frame.size.height - kSCROLL_VIEW_INSET, 0, 0, 0);
}

- (void)tweakUI {
    
    self.storyBreaksNotification.text = @"Click here to be notified when a story breaks in your area";
    
    // UI Values
    self.storyBreaksView.backgroundColor = [UIColor colorWithHex:[VariableStore sharedInstance].colorStoryBreaksBackground];
    self.detailViewWrapper.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.detailViewWrapper.layer.shadowOpacity = 0.26;
    self.detailViewWrapper.layer.shadowOffset = CGSizeMake(-1, 0);
    
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


/*
** Update Assignments
*/

-(void)updateAssignments
{
    // Grab the assignments in that region; one degree of latitude = 69 miles
    NSNumber *radius = [NSNumber numberWithFloat:self.assignmentsMap.region.span.latitudeDelta * 69];

    [[FRSDataManager sharedManager] getAssignmentsWithinRadius:[radius floatValue]
                                                    ofLocation:self.assignmentsMap.centerCoordinate
                                             withResponseBlock:^(id responseObject, NSError *error) {
        if (!error) {
            [self setAssignments:responseObject];
            [self populateMapWithAnnotations];
            [self setOperatingRadius:radius];
        }
    }];
}

/*
** Runs through controller's assignments, and adds them to the map
*/

- (void)populateMapWithAnnotations{
    
    for(FRSAssignment *assignment in self.assignments){
        
        [self addAssignmentAnnotation:assignment];
        
    }
    
}


/*
** Set the current assignment
*/

- (void)setAssignment:(FRSAssignment *)assignment navigateToAssignment:(BOOL)navigate{
    
    [self setCurrentAssignment:assignment];
    
    self.assignmentTitle.text= self.currentAssignment.title;
    
    self.assignmentDescription.text = self.currentAssignment.caption;
    
    self.assignmentTimeElapsed.text = [MTLModel relativeDateStringFromDate:self.currentAssignment.timeCreated];
    
    [self zoomToCoordinates:self.currentAssignment.lat lng:self.currentAssignment.lon];
    
    //Navgiate to the location if true
    if(navigate){
    
        
    }

}

/*
** Zoom to specified coordinates
*/

- (void)zoomToCoordinates:(NSNumber*)lat lng:(NSNumber *)lon{

    MKCoordinateSpan span = MKCoordinateSpanMake(0.0002f, 0.0002f);
    
    MKCoordinateRegion region = {CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]), span};
    
    MKCoordinateRegion regionThatFits = [self.assignmentsMap regionThatFits:region];
    
    [self.assignmentsMap setRegion:regionThatFits animated:YES];

}

/*
** Adds assignment to map through annotation
*/

- (void)addAssignmentAnnotation:(FRSAssignment*)assignment{
    
    AssignmentLocation *annotation = [[AssignmentLocation alloc] initWithName:self.currentAssignment.title address:self.currentAssignment.location[@"googlemaps"] coordinate:CLLocationCoordinate2DMake([assignment.lat floatValue], [assignment.lon floatValue])];
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake([assignment.lat floatValue], [assignment.lon floatValue]) radius:[self.currentAssignment.radius floatValue]];
    
    [self.assignmentsMap addOverlay:circle];
    
    [self.assignmentsMap addAnnotation:annotation];
    
}


/*
** Zooms to user locationter
*/

- (void)zoomToCurrentLocation {
    
    // Zooming map after delay for effect
    MKCoordinateSpan span = MKCoordinateSpanMake(0.0002f, 0.0002f);
    MKCoordinateRegion region = {self.assignmentsMap.userLocation.location.coordinate, span};
    
    MKCoordinateRegion regionThatFits = [self.assignmentsMap regionThatFits:region];

    [self.assignmentsMap setRegion:regionThatFits animated:YES];
    
    self.centeredUserLocation = YES;
    
}


#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentSize.height - scrollView.frame.size.height)];
    }

}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"AssignmentAnnotation";
    
    if ([annotation isKindOfClass:[AssignmentLocation class]]){
  
        MKAnnotationView *annotationView = (MKAnnotationView *) [self.assignmentsMap dequeueReusableAnnotationViewWithIdentifier:identifier];
    
        if (annotationView == nil) {
          
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"assignment-dot"];//here we use a nice image instead of the default pins
       
        }
        else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    
    }

    return nil;

}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{

    MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    
    [circleView setFillColor:[UIColor colorWithHex:@"ffc600" alpha:.26]];
    [circleView setStrokeColor:[UIColor clearColor]];
    
    return circleView;

}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{

    //One degree of latitude = 69 miles
    NSNumber *radius = [NSNumber numberWithFloat:self.assignmentsMap.region.span.latitudeDelta * 69];
    
    if(self.operatingRadius == nil){
    
        [self updateAssignments];
        
    }
    else if (fabsf([_operatingRadius floatValue] - [radius floatValue]) > 1) {
        
        [self updateAssignments];
        
    }
 
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"Failed to locate user: %@", error);
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // center on the current location
    if (!self.centeredUserLocation) [self zoomToCurrentLocation];
    
    self.centeredUserLocation = YES;
    
    [self.assignmentsMap setCenterCoordinate:self.assignmentsMap.userLocation.location.coordinate animated:YES];
    
}
@end
