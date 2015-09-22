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
#import "AssignmentOnboardViewController.h"
#import "FRSLocationManager.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <DBImageColorPicker.h>

#define kSCROLL_VIEW_INSET 75

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
    @property (strong, nonatomic) DBImageColorPicker *picker;

    /*
    ** Conditioning Variables
    */
    @property (strong, nonatomic) CLLocation *lastLoc;

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
    
    //Check for location permission
    [self requestAlwaysAuthorization];
    
    self.assignmentsMap.delegate = self;
    self.scrollView.delegate = self;
    
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideOnboarding:) name:NOTIF_ONBOARD object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPin:) name:NOTIF_IMAGE_SET object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    //Configure radius banner
    if([[FRSDataManager sharedManager] currentUserIsLoaded]){
        if([[FRSDataManager sharedManager].currentUser.notificationRadius integerValue] == 0){
            self.storyBreaksView.hidden = NO;
        }
        else{
            self.storyBreaksView.hidden = YES;
        }
        
        if(!self.picker)
            self.picker = [MKMapView createDBImageColorPickerForUserWithImage:nil];

    }
    
    //Run updates for assignments
    [self updateAssignments];
    
    //If we have an assignment set, present it
    if(self.currentAssignment && self.detailViewWrapper.hidden == YES){
    
        [self presentCurrentAssignmentWithAnimation:YES];
        
    }
    
}

- (void)resetPin:(NSNotification *)notification {
    
    if([FRSDataManager sharedManager].currentUser.avatarUrl != nil){
        
        NSData *profileImageData = [NSData dataWithContentsOfURL:[FRSDataManager sharedManager].currentUser.avatarUrl];
        
        UIImage *profileImage = [UIImage imageWithData:profileImageData];
        
        self.picker = [MKMapView createDBImageColorPickerForUserWithImage:profileImage];

        [self.assignmentsMap updateUserPinViewForMapView:self.assignmentsMap withImage:profileImage];
        
        [self.assignmentsMap userRadiusUpdated:nil];
            
    }
    else {
        
        UIImage *defaultPinImage = [UIImage imageNamed:@"dot-user-fill"];
        
        [self.assignmentsMap updateUserPinViewForMapView:self.assignmentsMap withImage:defaultPinImage];
        
    }
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
    
    self.detailViewWrapper.hidden = YES;
    self.detailViewWrapper.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.detailViewWrapper.layer.shadowOpacity = 0.26;
    self.detailViewWrapper.layer.shadowOffset = CGSizeMake(-1, 0);
}


/*
** Action for clicking radius banner
*/

- (IBAction)clickedRadiusNotificationButton:(id)sender {
        
    ProfileSettingsViewController *pVC = [[ProfileSettingsViewController alloc] initWithNibName:@"ProfileSettingsViewController" bundle:nil];
    pVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:pVC animated:YES];
    
}

/*
** Action to open camera from single assignment view
*/

- (IBAction)openInCamera:(id)sender {
    
    [self navigateToCamera];
}


#pragma mark - Assignment Management

/*
** Sets current assignment of view controller, with conditioning variables and checks for expiration
*/

-(void)setCurrentAssignment:(FRSAssignment *)currentAssignment navigateTo:(BOOL)navigate present:(BOOL)present withAnimation:(BOOL)animate{
    
    if(([currentAssignment.expirationTime timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970]) > 0) {
        
        self.currentAssignment = currentAssignment;
        
        self.centeredUserLocation = YES;
        
        if(navigate) self.navigateTo = YES;
        
        if(present) [self presentCurrentAssignmentWithAnimation:animate];
    
    }
}

/*
** Presents current assignment of view controller, fades in view
*/

- (void)presentCurrentAssignmentWithAnimation:(BOOL)animate{
    
    if(self.isViewLoaded){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.assignmentTitle.text= self.currentAssignment.title;
            
            self.assignmentDescription.text = self.currentAssignment.caption;
            
            self.assignmentTimeElapsed.text = [NSString stringWithFormat:@"Expires %@", [MTLModel futureDateStringFromDate:self.currentAssignment.expirationTime]];
            
            [self.assignmentsMap zoomToCoordinates:self.currentAssignment.lat lon:self.currentAssignment.lon withRadius:self.currentAssignment.radius withAnimation:animate];
            
            self.operatingRadius = 0;
            
            self.detailViewWrapper.hidden = NO;
            
            CGRect newFrame = CGRectMake(0, 0, self.detailViewWrapper.frame.size.width, self.detailViewWrapper.frame.size.height);
            
            [UIView animateWithDuration:.4 animations:^(void) {
                
                [self.detailViewWrapper setFrame:newFrame];
                
            }];
            
            if(self.navigateTo) [self.navigationSheet showInView:self.view];
            
            self.navigateTo = false;
            
        });
    }
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
        if((fabsf(radius.floatValue - [self.operatingRadius floatValue]) > .4)){
            
            self.updating = true;
        
            self.operatingRadius = radius;
            
            self.operatingLat = [NSNumber numberWithFloat:self.assignmentsMap.centerCoordinate.latitude];
            
            self.operatingLon = [NSNumber numberWithFloat:self.assignmentsMap.centerCoordinate.longitude];
            
            if([radius integerValue] < 500){

                [[FRSDataManager sharedManager] getAssignmentsWithinRadius:[radius floatValue]
                 ofLocation:CLLocationCoordinate2DMake(
                                                       self.assignmentsMap.centerCoordinate.latitude,
                                                       self.assignmentsMap.centerCoordinate.longitude)
                 withResponseBlock:^(id responseObject, NSError *error) {
                    
                     if (!error) {
                        
                        self.viewingClusters = false;
                         
                        if([responseObject count] > 0){
    
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
                            else if(([self.assignments count] +1) > [self.assignmentsMap.annotations count]){
                            
                                [self populateMapWithAnnotations];
                                
                            }
                            
                        }
                        else{
                        
                            [self clearMapAnnotations];
                        
                        }
                        
                    }
                    
                    self.updating = false;
                    
                }];
                
            }
            else{
                
                [[FRSDataManager sharedManager] getClustersWithinLocation:self.assignmentsMap.centerCoordinate.latitude
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
        
        [self clearMapAnnotations];
        
        for(FRSCluster *cluster in self.clusters){
            
            [self addClusterAnnotation:cluster index:count];
            count++;
        }
    
    }
    else {
        
        if (self.assignmentsMap.annotations != nil) {
        
            for (id<MKAnnotation> annotation in self.assignmentsMap.annotations){
                
                if ([annotation isKindOfClass:[ClusterAnnotation class]]){
                    
                    [self.assignmentsMap removeAnnotation:annotation];
                    
                }
                
            }
             
         }
        
        [self.assignmentsMap removeAllOverlaysButUser];
        
        for(FRSAssignment *assignment in self.assignments){
            
            [self addAssignmentAnnotation:assignment index:count];
            count++;
        }
    

        // Run this after populating map with assignments, this ensures we have the annotation to select
        if(self.currentAssignment && [self.assignmentsMap.selectedAnnotations count] == 0){
            
            [self selectCurrentAssignmentAnnotation];
            
        }
    
    }

}

/*
** Adds assignment to map through AssignmentAnnotation (MKAnnotation subclass)
*/

- (void)addAssignmentAnnotation:(FRSAssignment*)assignment index:(NSInteger)index{
    
    //Create AssignmentAnnotaiton for passed assignment
    AssignmentAnnotation *annotation = [[AssignmentAnnotation alloc] initWithAssignment:assignment andIndex:index];
    
    //Create center coordinate for the assignment
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([assignment.lat floatValue], [assignment.lon floatValue]);
    
    //Create MKCircle surroudning the annotation
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:coord radius:([assignment.radius floatValue] * kMetersInAMile)];

    [self.assignmentsMap addOverlay:circle];
    
    [self.assignmentsMap addAnnotation:annotation];
    
}

/*
** Adds cluster to map through ClusterAnnotion (MKAnnotation sublcass)
*/

- (void)addClusterAnnotation:(FRSCluster*)cluster index:(NSInteger)index{
    
    ClusterAnnotation *annotation = [[ClusterAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake([cluster.lat floatValue], [cluster.lon floatValue]) clusterIndex:index];
    
    [self.assignmentsMap addAnnotation:annotation];
    
}

/*
** Cleans up annotations on the map
*/

- (void)clearMapAnnotations{

    if(self.assignmentsMap.annotations != nil){
        
        for (id<MKAnnotation> annotation in self.assignmentsMap.annotations){
            
            MKAnnotationView *view = [self.assignmentsMap viewForAnnotation:annotation];
            
            if (view) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
                        view.alpha = 0.0;
                    }completion:^(BOOL finished) {
                        [self.assignmentsMap removeAnnotation:annotation];
                        view.alpha = 1.0;
                    }];
                        
                });
                
            }
            else {
                [self.assignmentsMap removeAnnotation:annotation];
            }
            
        }
        
        self.assignments = nil;
        
        [self.assignmentsMap removeOverlays:self.assignmentsMap.overlays];
        
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

    //If the annotiation is for the user's location
    if (annotation == mapView.userLocation) {
        
        [self.assignmentsMap addOverlay:[MKMapView userRadiusForMap:self.assignmentsMap withRadius:nil]];

        return [self.assignmentsMap setupUserPinForAnnotation:annotation];
            
    }
    //If the annotation is for an assignment
    else if ([annotation isKindOfClass:[AssignmentAnnotation class]]){

        return [self.assignmentsMap setupAssignmentPinForAnnotation:annotation withType:FRSAssignmentAnnotation];
        
    }
    //If the annotation is for a cluster (multiple assignments into one annotiation)
    else if ([annotation isKindOfClass:[ClusterAnnotation class]]){

        return  [self.assignmentsMap setupAssignmentPinForAnnotation:annotation withType:FRSClusterAnnotation];

    
    }

    return nil;
    
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    if ([view.annotation isKindOfClass:[AssignmentAnnotation class]]){
        
        //Check if we have an assignment at this index
        if([self.assignments objectAtIndex:((AssignmentAnnotation *) view.annotation).assignmentIndex] != nil){
        
            //Set the current assignment
            [self setCurrentAssignment:[self.assignments objectAtIndex:((AssignmentAnnotation *) view.annotation).assignmentIndex] navigateTo:NO present:YES withAnimation:YES];
            
        }
        
    }
    else if ([view.annotation isKindOfClass:[ClusterAnnotation class]]){
        
        FRSCluster *cluster = [self.clusters objectAtIndex:((ClusterAnnotation *) view.annotation).clusterIndex];
        
        [self.assignmentsMap zoomToCoordinates:cluster.lat lon:cluster.lon withRadius:cluster.radius withAnimation:YES];
        
        self.operatingRadius = 0;
        
    }
    
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{

    [mapView deselectAnnotation:view.annotation animated:YES];
    
    self.currentAssignment = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGRect newFrame = CGRectMake(0,
                                     0 + self.detailViewWrapper.frame.size.height,
                                     self.detailViewWrapper.frame.size.width,
                                     self.detailViewWrapper.frame.size.height);
        
        [UIView animateWithDuration:.4 animations:^(void) {
            
            [self.detailViewWrapper setFrame:newFrame];
            
        } completion:^(BOOL finished) {
            self.detailViewWrapper.hidden = YES;
        }];

    });

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    if ([view.annotation isKindOfClass:[AssignmentAnnotation class]]){
        
        [self.navigationSheet showInView:self.view];
        
    }
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    if(self.centeredUserLocation) {
        [self updateAssignments];
    }
    
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"Failed to locate user: %@", error);
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    [self zoomToCurrentLocation];
    
    [self.assignmentsMap userRadiusUpdated:nil];

}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
    return [MKMapView radiusRendererForOverlay:overlay withImagePicker:self.picker];

}

#pragma mark - Location Zoom/View Methods


/*
 ** Zooms to user location
 */

- (void)zoomToCurrentLocation {
    
    __block BOOL runUserLocation = true;
    
    //Check if we're already centered
    if (self.centeredUserLocation)
        return;
    
    if ([self.lastLoc distanceFromLocation:self.assignmentsMap.userLocation.location] > 0 || self.lastLoc == nil){
        
        //Find nearby assignments in a 20 mile radius
        [[FRSDataManager sharedManager] getAssignmentsWithinRadius:10 ofLocation:self.assignmentsMap.userLocation.coordinate
                                                 withResponseBlock:^(id responseObject, NSError *error)
        {
            if (!error) {
                
                //If the assignments exists, navigate to the avg location respective to the current location
                if([responseObject count] > 0) {
                    
                    //Don't zoom to user location
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
                    
                    self.centeredUserLocation = YES;
                    
                }
                
            }
            
        }];
        
    }

    if (runUserLocation) {
        
        if (self.assignmentsMap.userLocation.location != nil) {
            
            // Zooming map after delay for effect
            MKCoordinateSpan span = MKCoordinateSpanMake(0.0002f, 0.0002f);
            
            MKCoordinateRegion region = {self.assignmentsMap.userLocation.location.coordinate, span};
            
            MKCoordinateRegion regionThatFits = [self.assignmentsMap regionThatFits:region];
            
            [self.assignmentsMap setRegion:regionThatFits animated:YES];
            
            self.lastLoc = self.assignmentsMap.userLocation.location;
            
            self.centeredUserLocation = YES;
            
        }
        
    }
    
    self.operatingRadius = 0;
    
}


#pragma mark - Authorization 

- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        
        UIAlertController *alertCon = [[FRSAlertViewManager sharedManager]
                                       alertControllerWithTitle:CASUAL_LOC_DISABLED
                                       message:ENABLE_LOC_SETTINGS
                                       action:DISMISS handler:nil];
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
        }]];
        
        [self presentViewController:alertCon animated:YES completion:nil];

    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        
        [[FRSLocationManager sharedManager] requestAlwaysAuthorization];
        
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