//
//  AssignmentsViewController.m
//  FrescoNews
//
//  Created by Fresco News on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "AppDelegate.h"
#import "AssignmentsViewController.h"
#import "UIViewController+Additions.h"
#import "MKMapView+Additions.h"
#import "MTLModel+Additions.h"
#import "FRSDataManager.h"
#import "AssignmentAnnotation.h"
#import "ClusterAnnotation.h"
#import "ProfileSettingsViewController.h"
#import <SVPulsingAnnotationView.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "AssignmentOnboardViewController.h"

#define kSCROLL_VIEW_INSET 75

//static NSString *assignmentIdentifier = @"AssignmentAnnotation";
//static NSString *clusterIdentifier = @"ClusterAnnotation";
//static NSString *userIdentifier = @"currentLocation";

@class FRSAssignment;

@interface AssignmentsViewController () <UIScrollViewDelegate, MKMapViewDelegate, UIActionSheetDelegate>

    /*
    ** UI Elements
    */

    @property (weak, nonatomic) IBOutlet UIView *storyBreaksView;
    @property (weak, nonatomic) IBOutlet UIView *detailViewWrapper;
    @property (weak, nonatomic) IBOutlet UILabel *assignmentTitle;
    @property (weak, nonatomic) IBOutlet UILabel *assignmentTimeElapsed;
    @property (weak, nonatomic) IBOutlet UILabel *assignmentDescription;
    @property (weak, nonatomic) IBOutlet MKMapView *assignmentsMap;
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (weak, nonatomic) IBOutlet UIView *onboardContainerView;
    @property (strong, nonatomic) UIActionSheet *navigationSheet;
    @property (nonatomic) MKAnnotationView *pinView;

    /*
    ** Conditioning Variables
    */

    @property (assign, nonatomic) BOOL centeredAssignment;

    @property (assign, nonatomic) BOOL navigateTo;

    @property (assign, nonatomic) BOOL updating;

    @property (assign, nonatomic) BOOL viewingClusters;

    @property (strong, nonatomic) NSNumber *operatingRadius;

    @property (strong, nonatomic) NSNumber *operatingLat;

    @property (strong, nonatomic) NSNumber *operatingLon;

@end

@implementation AssignmentsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setFrescoNavigationBar];
    
    [self tweakUI];
    
    self.navigationSheet = [[UIActionSheet alloc]
                            initWithTitle:NAVIGATE_TO_ASSIGNMENT
                            delegate:self
                            cancelButtonTitle:CANCEL
                            destructiveButtonTitle:nil
                            otherButtonTitles:OPEN_IN_GOOG_MAPS, OPEN_IN_MAPS, nil];
    
    
    //Navigation Sheet Tag
    self.navigationSheet.tag = 100;

    //Set all values to 0 to reset controller
    self.operatingRadius = 0;
    self.operatingLat = 0;
    self.operatingLon = 0;
    
    if(self.currentAssignment == nil)
        [self updateAssignments];
    else
        [self presentCurrentAssignment];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideOnboarding:) name:@"onboard" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserPin:) name:NOTIFICATION_IMAGE_SET object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPin:) name:@"profilePicReset" object:nil];

}

- (void)resetPin:(NSNotification *)notification {
    self.assignmentsMap.delegate = self;
    
    CLLocationDegrees lat = self.assignmentsMap.userLocation.coordinate.latitude;
    CLLocationDegrees lon = self.assignmentsMap.userLocation.coordinate.longitude;
    
    MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance (CLLocationCoordinate2DMake(lat + .01, lon + .01), 0, 0);
    [self.assignmentsMap setRegion:newRegion animated:NO];
    
    MKCoordinateRegion oldRegion = MKCoordinateRegionMakeWithDistance (CLLocationCoordinate2DMake(lat, lon), 300, 300);
    [self.assignmentsMap setRegion:oldRegion animated:NO];

    self.assignmentsMap.delegate = nil;
}

/*
 ** Prevents scroll and map delegates from being called outside controller
 */

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.assignmentsMap.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.scrollView.delegate = nil;
    self.assignmentsMap.delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if([[FRSDataManager sharedManager] currentUserIsLoaded]){
        if([[FRSDataManager sharedManager].currentUser.notificationRadius integerValue] == 0){
            self.storyBreaksView.hidden = NO;
        }
        else{
            self.storyBreaksView.hidden = YES;
        }
    }
    
    if(self.currentAssignment == nil)
        [self updateAssignments];
    else
        [self presentCurrentAssignment];

}

- (void)viewDidLayoutSubviews{
    self.scrollView.contentInset = UIEdgeInsetsMake(self.assignmentsMap.frame.size.height - kSCROLL_VIEW_INSET, 0, 0, 0);
}

/*
** Perform neccessary tweaks on views, called on viewDidLoad
*/

- (void)tweakUI {
   
   if([[FRSDataManager sharedManager].currentUser.notificationRadius integerValue] != 0){
       self.storyBreaksView.hidden = YES;
   }
   else
    self.storyBreaksView.hidden = YES;
    
    self.scrollView.alpha = 0;
    
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
** Action for clicking radius banner
*/

- (IBAction)clickedRadiusNotificationButton:(id)sender {
    
    //Retreieve Notifications View Controller from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    ProfileSettingsViewController *profileSettings = [storyboard instantiateViewControllerWithIdentifier:@"ProfileSettingsViewController"];
    
    [self.navigationController pushViewController:profileSettings animated:YES];
    
}

/*
** Action to open camera from single assignment view
*/

- (IBAction)openInCamera:(id)sender {
    
    [self navigateToCamera];
}


/*
** Listener checking if user has set or changed profile picture
*/

- (void)updateUserPin:(NSNotification *)notification {
    [MKMapView updateUserPinViewForMapView:self.assignmentsMap WithImage:notification.object];
}

//create function


#pragma mark - Assignment Management

/*
** Sets current assignment of view controller, with conditioning variables and checks for expiration
*/

-(void)setCurrentAssignment:(FRSAssignment *)currentAssignment navigateTo:(BOOL)navigate present:(BOOL)present{
    
    if(([currentAssignment.expirationTime timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970]) > 0) {
        
        self.currentAssignment = currentAssignment;
        
        self.centeredUserLocation = YES;
        
        if(navigate) self.navigateTo = YES;
        
        if(present) [self presentCurrentAssignment];
    
    }
}

/*
** Presents current assignment of view controller, fades in view
*/

-(void)presentCurrentAssignment{
    
    self.assignmentTitle.text= self.currentAssignment.title;
    
    self.assignmentDescription.text = self.currentAssignment.caption;
    
    self.assignmentTimeElapsed.text = [NSString stringWithFormat:@"Expires %@", [MTLModel futureDateStringFromDate:self.currentAssignment.expirationTime]];
    
    [self zoomToCoordinates:self.currentAssignment.lat lon:self.currentAssignment.lon withRadius:self.currentAssignment.radius];
    
    [UIView animateWithDuration:.4 animations:^(void) {
        [self.scrollView setAlpha:1];
    }];
    
    if(self.navigateTo) [self.navigationSheet showInView:self.view];
    
    self.navigateTo = false;
    
    [self selectCurrentAssignmentAnnotation];

}

- (void)selectCurrentAssignmentAnnotation{

    //Loop assignments
    for (id<MKAnnotation> annotation in self.assignmentsMap.annotations){
        //Check if it's an AssignmentAnnotation
        if([annotation isKindOfClass:[AssignmentAnnotation class]]){
            //Check if it's the right one by Assignment Id
            if([((AssignmentAnnotation *)annotation).assignmentId isEqualToString:self.currentAssignment.assignmentId]){
                //Select id
                [self.assignmentsMap selectAnnotation:annotation animated:YES];
            }
        }
    }
}

/*
** Update Assignments
*/

-(void)updateAssignments{
    
    if(!self.updating){
        
        //One degree of latitude = 69 miles
        NSNumber *radius = [NSNumber numberWithFloat:self.assignmentsMap.region.span.latitudeDelta * 69];
    
        //Check if the user moves at least a difference greater than .4
        if((fabsf(radius.floatValue - [self.operatingRadius floatValue]) > .4 && ([radius floatValue] > [self.operatingRadius floatValue]))
           
           ||
           
           (fabs((self.assignmentsMap.centerCoordinate.latitude - [self.operatingLat floatValue]) * 69) > .7 || fabs((self.assignmentsMap.centerCoordinate.longitude - [self.operatingLon floatValue]) * 69) > .7 )
           ){
            
            self.updating = true;
        
            self.operatingRadius = radius;
            
            self.operatingLat = [NSNumber numberWithFloat:self.assignmentsMap.centerCoordinate.latitude];
            
            self.operatingLon = [NSNumber numberWithFloat:self.assignmentsMap.centerCoordinate.longitude];
            
            if([radius integerValue] < 500){

                [[FRSDataManager sharedManager]
                 getAssignmentsWithinRadius:[radius floatValue]
                 ofLocation:CLLocationCoordinate2DMake(
                                                       self.assignmentsMap.centerCoordinate.latitude,
                                                       self.assignmentsMap.centerCoordinate.longitude)
                 withResponseBlock:^(id responseObject, NSError *error) {
                    
                     if (!error) {
                        
                        self.viewingClusters = false;
                        
                        NSMutableArray *copy = [[NSMutableArray alloc] init];
                        
                        for(FRSAssignment* assignment in responseObject){
                            [copy addObject:assignment.assignmentId];
                        }
                        
                        if(self.assignments != nil){
                            
                            for(FRSAssignment *assignment in self.assignments){
                                
                                [copy removeObject:assignment.assignmentId];
                            
                            }
                            
                        }
                        
                        if(copy.count > 0 || copy == nil || self.assignments.count == 0 || self.assignments == nil){
                            
                            self.assignments = responseObject;
                            
                            [self populateMapWithAnnotations];
                        
                        }
                        
                    }
                    
                    self.updating = false;
                    
                }];
                
            }
            else{
                
                [[FRSDataManager sharedManager]
                 getClustersWithinLocation:self.assignmentsMap.centerCoordinate.latitude
                 lon:self.assignmentsMap.centerCoordinate.longitude
                 radius:[radius floatValue]
                 withResponseBlock:^(id responseObject, NSError *error) {
                    
                     if (!error) {
                        
                        self.viewingClusters = true;
                        
                        self.clusters = responseObject;
                    
                        [self populateMapWithAnnotations];
                        
                    }
            
                    self.updating = false;
                    
                }];
            
            }
            
        }
    }
    
}

#pragma mark - MapView Annotations

/*
** Runs through controller's assignments, and adds them to the map
*/

- (void)populateMapWithAnnotations{
    
    NSUInteger count = 0;
    
    if(_viewingClusters){
        
        if(self.assignmentsMap.annotations != nil){
        
            for (id<MKAnnotation> annotation in self.assignmentsMap.annotations){
                
                MKAnnotationView *view = [self.assignmentsMap viewForAnnotation:annotation];
                
                if (view) {
                    [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
                        view.alpha = 0.0;
                    } completion:^(BOOL finished) {
                        [self.assignmentsMap removeAnnotation:annotation];
                        view.alpha = 1.0;
                    }];
                } else {
                    [self.assignmentsMap removeAnnotation:annotation];
                }
                
            }
    
            self.assignments = nil;
            
            [self.assignmentsMap removeOverlays:self.assignmentsMap.overlays];

        }
        
        for(FRSCluster *cluster in self.clusters){
            
            [self addClusterAnnotation:cluster index:count];
            count++;
        }
    
    }
    else{
        
        if(self.assignmentsMap.annotations != nil){
        
            for (id<MKAnnotation> annotation in self.assignmentsMap.annotations){
                
                if ([annotation isKindOfClass:[ClusterAnnotation class]]){
                    
                    [self.assignmentsMap removeAnnotation:annotation];
                    
                }
                
            }
             
         }
        
        [self.assignmentsMap removeOverlays:self.assignmentsMap.overlays];
        
        for(FRSAssignment *assignment in self.assignments){
            
            [self addAssignmentAnnotation:assignment index:count];
            count++;
        }
        
        // Run this after populating map with assignments, this ensures we have the annotation to select
        if(self.currentAssignment){
            
            [self selectCurrentAssignmentAnnotation];
            
        }
    
    }

}

/*
** Adds assignment to map through annotation
*/

- (void)addAssignmentAnnotation:(FRSAssignment*)assignment index:(NSInteger)index{
    
    AssignmentAnnotation *annotation = [[AssignmentAnnotation alloc] initWithAssignment:assignment andIndex:index];
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake([assignment.lat floatValue], [assignment.lon floatValue]) radius:([assignment.radius floatValue] * 1609.34)];
    
    [self.assignmentsMap addOverlay:circle];
    
    [self.assignmentsMap addAnnotation:annotation];
    
}

/*
** Adds cluster to map through annotation
*/

- (void)addClusterAnnotation:(FRSCluster*)cluster index:(NSInteger)index{
    
    ClusterAnnotation *annotation = [[ClusterAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake([cluster.lat floatValue], [cluster.lon floatValue]) clusterIndex:index];
    
    [self.assignmentsMap addAnnotation:annotation];
    
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentSize.height - scrollView.frame.size.height)];
    }

}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{

    //If the annotiation is for the user location
    if (annotation == mapView.userLocation) {
        
        self.pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:USER_IDENTIFIER];
        
        //Check to see if the annotation is dequeued and set already, if not, make one
        if(!self.pinView) return [MKMapView setupPinForAnnotation:annotation withAnnotationView:self.pinView];
            
    }
    //If the annotation is for an assignment
    else if ([annotation isKindOfClass:[AssignmentAnnotation class]]){
  
        MKAnnotationView *annotationView = (MKAnnotationView *) [self.assignmentsMap dequeueReusableAnnotationViewWithIdentifier:ASSIGNMENT_IDENTIFIER];
    
        if (annotationView == nil) {
          
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ASSIGNMENT_IDENTIFIER];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            
            annotationView.image = [UIImage imageNamed:@"assignment-dot"]; //here we use a nice image instead of the default pins
        
            /* Callout */
            
                UIButton *caret = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
                [caret setImage:[UIImage imageNamed:@"forwardCaret"] forState:UIControlStateNormal];
                
                caret.frame = CGRectMake(caret.frame.origin.x, caret.frame.origin.x, 10.0f, 15.0f);
                
                caret.contentMode = UIViewContentModeScaleAspectFit;
                
                annotationView.rightCalloutAccessoryView = caret;
                
            /* End Callout */
            
        }
        else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    
    }
    //If the annotation is for a cluster (multiple assignments into one annotiation)
    else if ([annotation isKindOfClass:[ClusterAnnotation class]]){
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [self.assignmentsMap dequeueReusableAnnotationViewWithIdentifier:CLUSTER_IDENTIFIER];
        
        if (annotationView == nil) {
            
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:CLUSTER_IDENTIFIER];
            annotationView.enabled = YES;
            
            annotationView.image = [UIImage imageNamed:@"assignment-dot"]; //here we use a nice image instead of the default pins
            
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
    
    [circleView setFillColor:[UIColor radiusGoldColor]];
    
    circleView.alpha = .26;
    
    return circleView;
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    if ([view.annotation isKindOfClass:[AssignmentAnnotation class]]){
        
        [self setCurrentAssignment:[self.assignments objectAtIndex:((AssignmentAnnotation *) view.annotation).assignmentIndex] navigateTo:NO present:YES];
        
    }
    else if ([view.annotation isKindOfClass:[ClusterAnnotation class]]){
        
        FRSCluster *cluster = [self.clusters objectAtIndex:((ClusterAnnotation *) view.annotation).clusterIndex];
        
        [self zoomToCoordinates:cluster.lat lon:cluster.lon withRadius:cluster.radius];
        
    }
    
    [mapView selectAnnotation:view.annotation animated:YES];
    
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{

    [mapView deselectAnnotation:view.annotation animated:YES];
    
    self.currentAssignment = nil;
    
    [UIView animateWithDuration:.4 animations:^(void) {
        self.scrollView.alpha = 0.0f;
        self.centeredAssignment = NO;
    }];

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    if ([view.annotation isKindOfClass:[AssignmentAnnotation class]]){
        
        [self.navigationSheet showInView:self.view];
        
    }
    
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
    if(self.currentAssignment == nil) {
        [self zoomToCurrentLocation];
    }
}

#pragma mark - Location Zoom/View Methods

/*
 ** Zoom to specified coordinates
 */

- (void)zoomToCoordinates:(NSNumber*)lat lon:(NSNumber *)lon withRadius:(NSNumber *)radius{
    
    //Span uses degrees, 1 degree = 69 miles
    MKCoordinateSpan span = MKCoordinateSpanMake(([radius floatValue] / 30.0), ([radius floatValue] / 30.0));
    
    MKCoordinateRegion region = {CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]), span};
    
    MKCoordinateRegion regionThatFits = [self.assignmentsMap regionThatFits:region];
    
    [self.assignmentsMap setRegion:regionThatFits animated:YES];
    
    self.operatingRadius = 0;
    
}


/*
 ** Zooms to user location
 */

- (void)zoomToCurrentLocation {
    
    //center on the current location
    if (!self.centeredUserLocation){
        
        __block BOOL runUserLocation = true;
        
        //Find nearby assignments in a 20 mile radius
        [[FRSDataManager sharedManager] getAssignmentsWithinRadius:10.f ofLocation:CLLocationCoordinate2DMake(self.assignmentsMap.userLocation.location.coordinate.latitude, self.assignmentsMap.userLocation.location.coordinate.longitude) withResponseBlock:^(id responseObject, NSError *error) {
            if (!error) {
                
                //If the assignments exists, navigate to the avg location respective to the current location
                if([responseObject count]){
                    
                    //Don't zoom to uer location
                    runUserLocation = false;
                    
                    float avgLat = 0;
                    
                    float avgLng = 0;
                    
                    self.assignments = responseObject;
                    
                    //Add up lat/lng
                    for(FRSAssignment *assignment in self.assignments){
                        
                        avgLat += [assignment.lat floatValue];
                        
                        avgLng += [assignment.lon floatValue];
                        
                    }
                    
                    // Zooming map after delay for effect
                    MKCoordinateSpan span = MKCoordinateSpanMake(0.15f, 0.15f);
                    
                    //Get Average location of all assignments and current location
                    CLLocationCoordinate2D avgLoc =  CLLocationCoordinate2DMake(
                                                                                (avgLat + self.assignmentsMap.userLocation.location.coordinate.latitude) / (self.assignments.count  +1),
                                                                                (avgLng + self.assignmentsMap.userLocation.location.coordinate.longitude) / (self.assignments.count  +1)
                                                                                );
                    
                    
                    MKCoordinateRegion region = {avgLoc, span};
                    
                    MKCoordinateRegion regionThatFits = [self.assignmentsMap regionThatFits:region];
                    
                    [self.assignmentsMap setRegion:regionThatFits animated:YES];
                    
                }
                
            }
            
        }];
        
        if(runUserLocation){
            
            if(self.assignmentsMap.userLocation.location != nil){
                
                // Zooming map after delay for effect
                MKCoordinateSpan span = MKCoordinateSpanMake(0.0002f, 0.0002f);
                
                MKCoordinateRegion region = {self.assignmentsMap.userLocation.location.coordinate, span};
                
                MKCoordinateRegion regionThatFits = [self.assignmentsMap regionThatFits:region];
                
                [self.assignmentsMap setRegion:regionThatFits animated:YES];
                
            }
            
        }
        
        self.centeredUserLocation = YES;
        
        self.operatingRadius = 0;
        
    }
    
}

#pragma mark - Action Sheet Delegate

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

#pragma mark - UIStoryboardSegue Delegate

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if ([identifier isEqualToString:@"assignmentOnboard"]) {
        
        //Check if the assignmnet onboarding should be set through the user defautls
        if ([[NSUserDefaults standardUserDefaults] boolForKey:UD_ASSIGNMENTS_ONBOARDING])
            return NO;
        else
            [self.view bringSubviewToFront:self.onboardContainerView];
        
    }

    return YES;

}

- (void)hideOnboarding:(NSNotification *)notification {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.onboardContainerView.alpha = 0;
    } completion:^(BOOL finished){
    
        [self.onboardContainerView removeFromSuperview];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_ASSIGNMENTS_ONBOARDING];
        
    }];

}

@end