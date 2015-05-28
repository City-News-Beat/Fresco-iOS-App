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
#import "AssignmentAnnotation.h"
#import "ClusterAnnotation.h"

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

    @property (assign, nonatomic) BOOL updating;

    @property (assign, nonatomic) BOOL viewingClusters;

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
    [super viewDidAppear:animated];
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
    
    if(!_updating){
        
        _updating = true;
        
        //Grab the assignments in that region
        //One degree of latitude = 69 miles
        NSNumber *radius = [NSNumber numberWithFloat:self.assignmentsMap.region.span.latitudeDelta * 69];
        
        if([radius integerValue] < 500){

            [[FRSDataManager sharedManager] getAssignmentsWithinRadius:[radius floatValue] ofLocation:CLLocationCoordinate2DMake(self.assignmentsMap.centerCoordinate.latitude, self.assignmentsMap.centerCoordinate.longitude) withResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    
                    _viewingClusters = false;
                    
                    _updating = false;
                    
                    NSMutableArray *copy;
                    
                    if(self.assignments != nil){
                        
                        copy = [responseObject mutableCopy];
                        
                        [copy removeObjectsInArray:self.assignments];
                        
                    }
                    
                    if(copy.count > 0 || copy == nil || self.assignments.count == 0 || self.assignments == nil){
                        
                        self.assignments = responseObject;
                        
                        [self populateMapWithAnnotations];
                    
                    }
                    
                }
                
            }];
            
        }
        else{
            [[FRSDataManager sharedManager] getClustersWithinLocation:self.assignmentsMap.centerCoordinate.latitude lon:self.assignmentsMap.centerCoordinate.longitude radius:[radius floatValue] withResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    
                    _updating = false;
                    
                    _viewingClusters = true;
                    
                    self.clusters = responseObject;
                
                    [self populateMapWithAnnotations];
                    
                }
                
            }];
        
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
    
    AssignmentAnnotation *annotation = [[AssignmentAnnotation alloc] initWithName:assignment.title address:assignment.location[@"googlemaps"] assignmentIndex:index coordinate:CLLocationCoordinate2DMake([assignment.lat floatValue], [assignment.lon floatValue])];
    
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
** Set the current assignment in the view
*/

- (void)updateCurrentAssignmentInView{
    
    self.assignmentTitle.text= self.currentAssignment.title;
    
    self.assignmentDescription.text = self.currentAssignment.caption;
    
    self.assignmentTimeElapsed.text = [MTLModel relativeDateStringFromDate:self.currentAssignment.timeCreated];
    
    [self zoomToCoordinates:self.currentAssignment.lat lon:self.currentAssignment.lon withRadius:self.currentAssignment.radius];
    
    [UIView animateWithDuration:1 animations:^(void) {
        [self.scrollView setAlpha:1];
    }];
    
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

}


/*
** Zooms to user location
*/

- (void)zoomToCurrentLocation {
    
    //center on the current location
    if (!self.centeredUserLocation){
        
        // Zooming map after delay for effect
        MKCoordinateSpan span = MKCoordinateSpanMake(0.0002f, 0.0002f);
        
        MKCoordinateRegion region = {self.assignmentsMap.userLocation.location.coordinate, span};
        
        MKCoordinateRegion regionThatFits = [self.assignmentsMap regionThatFits:region];
        
        [self.assignmentsMap setRegion:regionThatFits animated:YES];
        
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
    static NSString *clusterIdentifier = @"ClusterAnnotation";
    
    if ([annotation isKindOfClass:[AssignmentAnnotation class]]){
  
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
    else if ([annotation isKindOfClass:[ClusterAnnotation class]]){
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [self.assignmentsMap dequeueReusableAnnotationViewWithIdentifier:clusterIdentifier];
        
        if (annotationView == nil) {
            
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
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
    
    [circleView setFillColor:[UIColor colorWithHex:@"e8d2a2" alpha:.3]];
    
    circleView.alpha = .4;
    
    return circleView;
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    [mapView selectAnnotation:view.annotation animated:YES];
    
    if ([view.annotation isKindOfClass:[AssignmentAnnotation class]]){
        
        self.currentAssignment = [self.assignments objectAtIndex:((AssignmentAnnotation *) view.annotation).assignmentIndex];
        
        [self updateCurrentAssignmentInView];

    }
    else if ([view.annotation isKindOfClass:[ClusterAnnotation class]]){
        
        FRSCluster *cluster = [self.clusters objectAtIndex:((ClusterAnnotation *) view.annotation).clusterIndex];
        
        [self zoomToCoordinates:cluster.lat lon:cluster.lon withRadius:cluster.radius];
    
    }

}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{

    [mapView deselectAnnotation:view.annotation animated:YES];
    
    [UIView animateWithDuration:1 animations:^(void) {
        [self.scrollView setAlpha:0];
    }];

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    if ([view.annotation isKindOfClass:[AssignmentAnnotation class]]){
        

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
