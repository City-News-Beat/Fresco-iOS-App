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

#define kSCROLL_VIEW_INSET 100

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
    @property (strong, nonatomic) UIActionSheet *navigationSheet;
    @property (strong, nonatomic) AssignmentAnnotation *currentAssignmentAnnotation;
    @property (weak, nonatomic) IBOutlet MKMapView *mapView;

    /*
    ** Conditionaing Variables
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
                            initWithTitle:@"Navigate to the assignment"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Open in Google Maps", @"Open in Maps", nil];
    
    
    //Navigation Sheet Tag
    self.navigationSheet.tag = 100;

    self.operatingRadius = 0;
    
    self.operatingLat = 0;
    
    self.operatingLon = 0;
    
    self.storyBreaksView.hidden = YES;
    
    if(self.currentAssignment == nil)
        [self updateAssignments];
    else
        [self presentCurrentAssignment];
    
}

- (void)dealloc
{
    self.scrollView.delegate = nil;
    self.assignmentsMap.delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if([[FRSDataManager sharedManager] isLoggedIn]){
        if([[FRSDataManager sharedManager].currentUser.notificationRadius integerValue] == 0){
            self.storyBreaksView.hidden = NO;
        }
    }
    
    if(self.currentAssignment == nil){
        [self updateAssignments];
    }
    
}

- (void)viewDidLayoutSubviews{
    self.scrollView.contentInset = UIEdgeInsetsMake(self.assignmentsMap.frame.size.height - kSCROLL_VIEW_INSET, 0, 0, 0);
}

- (void)tweakUI {
   
   if([[FRSDataManager sharedManager].currentUser.notificationRadius integerValue] != 0){
       self.storyBreaksView.hidden = YES;
   }
    
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

- (IBAction)clickedRadiusNotificationButton:(id)sender {
    
    //Retreieve Notifications View Controller from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    ProfileSettingsViewController *profileSettings = [storyboard instantiateViewControllerWithIdentifier:@"ProfileSettingsViewController"];
    
    [self.navigationController pushViewController:profileSettings animated:YES];
    
}
- (IBAction)openInCamera:(id)sender {
    
    [self navigateToCamera];
    
}

-(void)setCurrentAssignment:(FRSAssignment *)currentAssignment navigateTo:(BOOL)navigate{
    
    if(([currentAssignment.expirationTime timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970]) > 0) {
        
        self.currentAssignment = currentAssignment;
        
        self.centeredUserLocation = YES;
        
        if(navigate) self.navigateTo = YES;
        
        [self presentCurrentAssignment];
    }
}

-(void)presentCurrentAssignment{
    
    self.assignmentTitle.text= self.currentAssignment.title;
    
    self.assignmentDescription.text = self.currentAssignment.caption;
    
    self.assignmentTimeElapsed.text = [NSString stringWithFormat:@"Expires %@", [MTLModel futureDateStringFromDate:self.currentAssignment.expirationTime]];
    
    [self zoomToCoordinates:self.currentAssignment.lat lon:self.currentAssignment.lon withRadius:self.currentAssignment.radius];
    
    [UIView animateWithDuration:1 animations:^(void) {
        [self.scrollView setAlpha:1];
    }];
    
    if(self.navigateTo) [self.navigationSheet showInView:self.view];
    
    self.navigateTo = false;

}

/*
** Update Assignments
*/

-(void)updateAssignments{
    
    if(!self.updating){
        
        //One degree of latitude = 69 miles
        NSNumber *radius = [NSNumber numberWithFloat:self.assignmentsMap.region.span.latitudeDelta * 69];
    
        //Check if the user moves at least a difference greater than .4
        if((fabsf(radius.floatValue - _operatingRadius.floatValue) > .4 &&  ([radius floatValue] > [self.operatingRadius floatValue]))
           
           ||
           
           (fabs((self.assignmentsMap.centerCoordinate.latitude - [self.operatingLat floatValue]) * 69) > .7 || fabs((self.assignmentsMap.centerCoordinate.longitude - [self.operatingLon floatValue]) * 69) > .7 )
           ){
            
            self.updating = true;
        
            self.operatingRadius = radius;
            
            self.operatingLat = [NSNumber numberWithFloat:self.assignmentsMap.centerCoordinate.latitude];
            
            self.operatingLon = [NSNumber numberWithFloat:self.assignmentsMap.centerCoordinate.longitude];
            
            if([radius integerValue] < 500){

                [[FRSDataManager sharedManager] getAssignmentsWithinRadius:[radius floatValue] ofLocation:CLLocationCoordinate2DMake(self.assignmentsMap.centerCoordinate.latitude, self.assignmentsMap.centerCoordinate.longitude) withResponseBlock:^(id responseObject, NSError *error) {
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
                
                [[FRSDataManager sharedManager] getClustersWithinLocation:self.assignmentsMap.centerCoordinate.latitude lon:self.assignmentsMap.centerCoordinate.longitude radius:[radius floatValue] withResponseBlock:^(id responseObject, NSError *error) {
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
    
    }
    
}

/*
** Adds assignment to map through annotation
*/

- (void)addAssignmentAnnotation:(FRSAssignment*)assignment index:(NSInteger)index{
    
    AssignmentAnnotation *annotation = [[AssignmentAnnotation alloc] initWithName:assignment.title address:(assignment.location[@"address"] ?: @"Get Directions") assignmentIndex:index coordinate:CLLocationCoordinate2DMake([assignment.lat floatValue], [assignment.lon floatValue])];
    
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


#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentSize.height - scrollView.frame.size.height)];
    }

}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *assignmentIdentifier = @"AssignmentAnnotation";
    static NSString *clusterIdentifier = @"ClusterAnnotation";
    static NSString *userIdentifier = @"currentLocation";

    if (annotation == mapView.userLocation) {
        
        if ([FRSDataManager sharedManager].currentUser.cdnProfileImageURL) {
            
            MKAnnotationView *pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:userIdentifier];

            if (!pinView) {
                pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userIdentifier];

                UIImageView *profileImageView = [[UIImageView alloc] init];
                profileImageView.frame = CGRectMake(0, 0, 22, 22);
                profileImageView.layer.masksToBounds = YES;
                profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2;
    
                [profileImageView setImageWithURL:[[FRSDataManager sharedManager].currentUser cdnProfileImageURL]];
                [pinView addSubview:profileImageView];
            }

            return pinView;
        }
        else {
            SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[self.assignmentsMap dequeueReusableAnnotationViewWithIdentifier:userIdentifier];
            if (!pulsingView) {
                pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userIdentifier];
                pulsingView.annotationColor = [UIColor colorWithHex:@"0077ff"];
            }
            
            return pulsingView;
        }
    }
    else if ([annotation isKindOfClass:[AssignmentAnnotation class]]){
  
        MKAnnotationView *annotationView = (MKAnnotationView *) [self.assignmentsMap dequeueReusableAnnotationViewWithIdentifier:assignmentIdentifier];
    
        if (annotationView == nil) {
          
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:assignmentIdentifier];
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
    else if ([annotation isKindOfClass:[ClusterAnnotation class]]){
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [self.assignmentsMap dequeueReusableAnnotationViewWithIdentifier:clusterIdentifier];
        
        if (annotationView == nil) {
            
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:clusterIdentifier];
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
    
    [circleView setFillColor:[UIColor colorWithHex:@"#ffc600"]];
    
    circleView.alpha = .26;
    
    return circleView;
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    if ([view.annotation isKindOfClass:[AssignmentAnnotation class]]){
        
        [self setCurrentAssignment:[self.assignments objectAtIndex:((AssignmentAnnotation *) view.annotation).assignmentIndex] navigateTo:NO];
        
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
    
    [UIView animateWithDuration:1 animations:^(void) {
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


@end
