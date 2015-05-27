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

@interface AssignmentsViewController () <UIScrollViewDelegate, MKMapViewDelegate, UIActionSheetDelegate>

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

    self.operatingRadius = 0;

    [self tweakUI];
    
    if(self.currentAssignment != nil){
        
        [self updateCurrentAssignmentInView];
    
    }
    else{
        
        self.scrollView.alpha = 0;
        
    }
    
    [self updateAssignments];

}

- (void)viewDidAppear:(BOOL)animated{
    static BOOL firstTime = YES;
    
    if(self.currentAssignment != nil){
        
        [self updateCurrentAssignmentInView];
        
    }

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

-(void)updateAssignments{
    
    //Grab the assignments in that region
    //One degree of latitude = 69 miles
    NSNumber *radius = [NSNumber numberWithFloat:self.assignmentsMap.region.span.latitudeDelta * 69];

    [[FRSDataManager sharedManager] getAssignmentsWithinLocation:self.assignmentsMap.centerCoordinate.latitude lon:self.assignmentsMap.centerCoordinate.longitude radius:[radius floatValue] WithResponseBlock:^(id responseObject, NSError *error) {
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
    
    NSUInteger count = 0;
    
    for(FRSAssignment *assignment in self.assignments){
        
        [self addAssignmentAnnotation:assignment index:count];
        count++;
    }
    
}


/*
** Set the current assignment
*/

- (void)updateCurrentAssignmentInView{
    
    self.assignmentTitle.text= self.currentAssignment.title;
    
    self.assignmentDescription.text = self.currentAssignment.caption;
    
    self.assignmentTimeElapsed.text = [MTLModel relativeDateStringFromDate:self.currentAssignment.timeCreated];
    
    [self zoomToCoordinates:self.currentAssignment.lat lng:self.currentAssignment.lon withRadius:self.currentAssignment.radius];
    
    [mapView selectAnnotation:view.annotation animated:YES];
    
    [UIView animateWithDuration:1 animations:^(void) {
        [self.scrollView setAlpha:1];
    }];
    
//    //Navgiate to the location if true
//    if(navigate){
//    
//        
//    }

}

/*
** Zoom to specified coordinates
*/

- (void)zoomToCoordinates:(NSNumber*)lat lng:(NSNumber *)lon withRadius:(NSNumber *)radius{

    //Span uses degrees, 1 degree = 69 miles
    MKCoordinateSpan span = MKCoordinateSpanMake(([radius floatValue] / 69.0), ([radius floatValue] / 69.0));
    
    MKCoordinateRegion region = {CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]), span};
    
    MKCoordinateRegion regionThatFits = [self.assignmentsMap regionThatFits:region];
    
    [self.assignmentsMap setRegion:regionThatFits animated:YES];

}

/*
** Adds assignment to map through annotation
*/

- (void)addAssignmentAnnotation:(FRSAssignment*)assignment index:(NSInteger)index{
    
    AssignmentLocation *annotation = [[AssignmentLocation alloc] initWithName:assignment.title address:assignment.location[@"googlemaps"] assignmentIndex:index coordinate:CLLocationCoordinate2DMake([assignment.lat floatValue], [assignment.lon floatValue])];
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake([assignment.lat floatValue], [assignment.lon floatValue]) radius:([assignment.radius floatValue] * 1609.34)];
    
    [self.assignmentsMap addOverlay:circle];
    
    [self.assignmentsMap addAnnotation:annotation];
    
}


/*
** Zooms to user location
*/

- (void)zoomToCurrentLocation {
    
    // Zooming map after delay for effect
    MKCoordinateSpan span = MKCoordinateSpanMake(0.0002f, 0.0002f);
    
    MKCoordinateRegion region = {self.assignmentsMap.userLocation.location.coordinate, span};
    
    MKCoordinateRegion regionThatFits = [self.assignmentsMap regionThatFits:region];
    
    [self.assignmentsMap setRegion:regionThatFits animated:YES];
    
    //center on the current location
    if (!self.centeredUserLocation){
        
        self.centeredUserLocation = YES;
    }
    
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
            
            UIButton *caret = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            [caret setImage:[UIImage imageNamed:@"forwardCaret"] forState:UIControlStateNormal];
            
            caret.frame = CGRectMake(caret.frame.origin.x, caret.frame.origin.x, 10.0f, 15.0f);
            
            caret.contentMode = UIViewContentModeScaleAspectFit;
            
            annotationView.rightCalloutAccessoryView = caret;
            
            annotationView.image = [UIImage imageNamed:@"assignment-dot"]; //here we use a nice image instead of the default pins
       
        }
        else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    
    }

    return nil;

}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    [mapView selectAnnotation:view.annotation animated:YES];
    
    if ([view.annotation isKindOfClass:[AssignmentLocation class]]){
        
        self.currentAssignment = [self.assignments objectAtIndex:((AssignmentLocation *) view.annotation).assignmentIndex];
        
        [self updateCurrentAssignmentInView];

    }

}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{

    [mapView deselectAnnotation:view.annotation animated:YES];
    
    [UIView animateWithDuration:1 animations:^(void) {
        [self.scrollView setAlpha:0];
    }];

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    if ([view.annotation isKindOfClass:[AssignmentLocation class]]){
        

        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Navigate to the assignment"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Open in Google Maps", @"Open in Maps", nil];
        
        
        // Google Maps
        actionSheet.tag = 100;
        
        [actionSheet showInView:self.view];


        
    }
    

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == 100) {
        
        CLLocationCoordinate2D start = self.assignmentsMap.userLocation.location.coordinate;
        
        CLLocationCoordinate2D destination = { [self.currentAssignment.lat floatValue], [self.currentAssignment.lon floatValue] };

        
        //Google Maps
        if(buttonIndex == 0){

            NSString *googleMapsURLString = [NSString stringWithFormat:@"comgooglemapsurl://?saddr=%f,%f&daddr=%f,%f",
                                             start.latitude, start.longitude, destination.latitude, destination.longitude];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
                
        }
        //Apple Maps :(
        else if(buttonIndex == 1){
            
            NSString *appleMapsURLString = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%f,%f&saddr=%f,%f",
                                            start.latitude, start.longitude, destination.latitude, destination.longitude];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appleMapsURLString]];
            
        }
        
        
    }


}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{

    MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    
    [circleView setFillColor:[UIColor colorWithHex:@"e8d2a2" alpha:.3]];
    
    circleView.alpha = .1;
    
    return circleView;

}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    [self updateAssignments];
 
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"Failed to locate user: %@", error);
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    if(self.currentAssignment == nil){
        
        [self zoomToCurrentLocation];
    
    }

    
}

@end
