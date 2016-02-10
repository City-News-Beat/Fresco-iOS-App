//
//  FRSAssignmentsViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAssignmentsViewController.h"
#import "FRSTabBarController.h"

#import "FRSLocationManager.h"
#import "FRSAPIClient.h"

#import "FRSAssignment.h"

#import "FRSDateFormatter.h"

#import "FRSMapCircle.h"
#import "FRSAssignmentAnnotation.h"

@import MapKit;

@interface FRSAssignmentsViewController () <MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSArray *assignments;

@property (strong, nonatomic) NSArray *overlays;

@property (nonatomic) BOOL isFetching;

@property (nonatomic) BOOL isOriginalSpan;

@property (strong, nonatomic) FRSMapCircle *userCircle;

@end

@implementation FRSAssignmentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureMap];
    [self addNotificationObservers];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[FRSLocationManager sharedManager] startLocationMonitoringForeground];

}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[FRSLocationManager sharedManager] pauseLocationMonitoring];
}


-(void)configureNavigationBar{
    [super configureNavigationBar];
    self.navigationItem.title = @"ASSIGNMENTS";
}

-(void)configureMap{
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    self.mapView.delegate = self;
    self.isOriginalSpan = YES;
    [self.view addSubview:self.mapView];
}

-(void)addNotificationObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocations:) name:NOTIF_LOCATIONS_UPDATE object:nil];
}

-(void)didUpdateLocations:(NSNotification *)notification{
    NSArray *locations = notification.userInfo[@"locations"];
    
    NSLog(@"Location update notification observed by assignmentsVC");
    
    if (!locations.count) return;
    
    CLLocation *currentLocation = [locations lastObject];
    
    [self adjustMapRegionWithLocation:currentLocation];
    
    [self fetchAssignmentsNearLocation:currentLocation];
    
    [self configureAnnotationsForMap];
}


-(void)fetchAssignmentsNearLocation:(CLLocation *)location{
    
    if (self.isFetching) return;
    
    self.isFetching = YES;
    
    [[FRSAPIClient new] getAssignmentsWithinRadius:10 ofLocation:@[@(location.coordinate.latitude), @(location.coordinate.longitude)] withCompletion:^(id responseObject, NSError *error) {
        NSArray *assignments = (NSArray *)responseObject;
        
        NSMutableArray *mSerializedAssignments = [NSMutableArray new];
        
        for (NSDictionary *dict in assignments){
            [mSerializedAssignments addObject:[FRSAssignment assignmentWithDictionary:dict]];
        }
        
        self.assignments = [mSerializedAssignments copy];
        [self addAnnotationsForAssignments];
        
        self.isFetching = NO;
    }];
}

#pragma mark - Region

-(void)adjustMapRegionWithLocation:(CLLocation *)location{
    
    //We want to preserve the span if the user modified it.
    MKCoordinateSpan currentSpan = self.mapView.region.span;
    
    if (self.isOriginalSpan){
        currentSpan = MKCoordinateSpanMake(0.03f, 0.03f);
        self.isOriginalSpan = NO;
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), currentSpan);
    
    [self.mapView setRegion:region animated:YES];
}

-(void)setInitialMapRegion{
    self.isOriginalSpan = YES;
    [self adjustMapRegionWithLocation:[FRSLocationManager sharedManager].lastAcquiredLocation];
}

#pragma mark - Annotations

-(void)configureAnnotationsForMap{
    [self addUserLocationCircleOverlay];
    [self addAnnotationsForAssignments];
}

-(void)addAnnotationsForAssignments{
    
//    for (id<MKAnnotation> annotation in self.mapView.annotations){
//        [self.mapView removeAnnotation:annotation];
//    }
//    
//    [self removeAllOverlaysIncludingUser:NO];
    
    NSInteger count = 0;
    
    for(FRSAssignment *assignment in self.assignments){
        
        [self addAssignmentAnnotation:assignment index:count];
        count++;
    }
}

- (void)addAssignmentAnnotation:(FRSAssignment*)assignment index:(NSInteger)index{
    
    FRSAssignmentAnnotation *ann = [[FRSAssignmentAnnotation alloc] initWithAssignment:assignment atIndex:index];
    
    //Create center coordinate for the assignment
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([assignment.latitude floatValue], [assignment.longitude floatValue]);
    
    //Create MKCircle surroudning the annotation
    FRSMapCircle *circle = [FRSMapCircle circleWithCenterCoordinate:coord radius:100];
    circle.circleType = FRSMapCircleTypeAssignment;
    
    [self.mapView addOverlay:circle];
    
    [self.mapView addAnnotation:ann];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
//    NSString *identifier = (type == FRSAssignmentAnnotation) ? ASSIGNMENT_IDENTIFIER : CLUSTER_IDENTIFIER;
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"assignment-annotation"];
    
    if (!annotationView) {
        
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"assignment-annotation"];
        
        annotationView.centerOffset = CGPointMake(0, 1.5); // offset the shadow
        
//        [annotationView setImage:[UIImage imageNamed:@"radius-large"]];
        
        annotationView.enabled = YES;
        
//        if (type == FRSAssignmentAnnotation) {
//            
//            annotationView.canShowCallout = YES;
//            
//            annotationView.rightCalloutAccessoryView = [MKMapView caret];
//            
//        }
    }
    
    return annotationView;
}

//
//
//- (MKAnnotationView *)setupAssignmentPinForAnnotation:(id <MKAnnotation>)annotation withType:(FRSAnnotationType)type{
//    
//    NSString *identifier = (type == FRSAssignmentAnnotation) ? ASSIGNMENT_IDENTIFIER : CLUSTER_IDENTIFIER;
//    
//    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
//    
//    if (!annotationView) {
//        
//        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
//        
//        annotationView.centerOffset = CGPointMake(0, 1.5); // offset the shadow
//        
//        [annotationView setImage:[MKMapView imagePinViewForAnnotationType:FRSAssignmentAnnotation].image];
//        
//        annotationView.enabled = YES;
//        
//        if (type == FRSAssignmentAnnotation) {
//            
//            annotationView.canShowCallout = YES;
//            
//            annotationView.rightCalloutAccessoryView = [MKMapView caret];
//            
//        }
//    }
//    
//    return annotationView;
//}
//
//
//- (MKAnnotationView *)setupUserPinForAnnotation:(id <MKAnnotation>)annotation {
//    
//    MKAnnotationView *annotationView = [self dequeueReusableAnnotationViewWithIdentifier:USER_IDENTIFIER];
//    
//    if (!annotationView) {
//        
//        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:USER_IDENTIFIER];
//        
//        annotationView.centerOffset = CGPointMake(-14, -15 + 3); // math is account for 18 width and 5 x, 18 height and 3 y w, 3 pts shadow
//        
//        UIImageView *whiteLayerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot-user-blank"]];
//        
//        UIImageView *profileImageView = [MKMapView imagePinViewForAnnotationType:FRSUserAnnotation];
//        
//        [profileImageView.layer addPulsingAnimation];
//        
//        [whiteLayerImageView addSubview:profileImageView];
//        
//        [annotationView addSubview:whiteLayerImageView];
//    }
//    
//    return annotationView;
//}
//
//
//+ (UIImageView *)imagePinViewForAnnotationType: (FRSAnnotationType)type {
//    
//    UIImageView *customPinView = [[UIImageView alloc] init];
//    
//    CGRect frame = CGRectMake(5, 3, 18, 18);
//    
//    if (type == FRSAssignmentAnnotation || type == FRSClusterAnnotation) { // is Assignment annotation view
//        
//        [customPinView setImage:[UIImage imageNamed:@"dot-assignment"]];
//        
//    }
//    else if (type == FRSUserAnnotation) { // is User annotation view
//        
//        if ([[NSUserDefaults standardUserDefaults] stringForKey:UD_AVATAR] != nil)
//            [customPinView setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:UD_AVATAR]]];
//        
//        else
//            [customPinView setImage:[UIImage imageNamed:@"dot-user-fill"]];
//    }
//    
//    customPinView.frame = frame;
//    customPinView.layer.masksToBounds = YES;
//    customPinView.layer.cornerRadius = customPinView.frame.size.width / 2;
//    
//    return customPinView;
//}

//- (void)updateUserPinViewForMapViewWithImage:(UIImage *)image {
//    
//    if (image != nil) {
//        
//        for (id<MKAnnotation> annotation in self.annotations){
//            
//            if (annotation == self.userLocation){
//                
//                MKAnnotationView *profileAnnotation = [self viewForAnnotation:annotation];
//                
//                if ([profileAnnotation.subviews count] > 0){
//                    
//                    if ([(UIImageView *)(((UIView *)profileAnnotation.subviews[0]).subviews[0]) isKindOfClass:[UIImageView class]]) {
//                        
//                        UIImageView *profileImageView = (UIImageView *)(((UIView *)profileAnnotation.subviews[0]).subviews[0]);
//                        
//                        [profileImageView setImage:image];
//                        
//                    }
//                }
//            }
//        }
//    }
//}


#pragma mark - Circle Overlays

-(void)addUserLocationCircleOverlay{
    
    //    CGFloat radius = self.mapView.userLocation.location.horizontalAccuracy > 100 ? 100 : self.mapView.userLocation.location.horizontalAccuracy;
    CGFloat radius = 100;
    
    if (self.userCircle){
        [self.mapView removeOverlay:self.userCircle];
    }
    
    self.userCircle = [FRSMapCircle circleWithCenterCoordinate:[FRSLocationManager sharedManager].lastAcquiredLocation.coordinate radius:radius];
    self.userCircle.circleType = FRSMapCircleTypeUser;
    
    [self.mapView addOverlay:self.userCircle];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKCircleRenderer *circleR = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
    
    if ([overlay isKindOfClass:[FRSMapCircle class]]){
        FRSMapCircle *circle = (FRSMapCircle *)overlay;
        
        if (circle.circleType == FRSMapCircleTypeUser){
            circleR.fillColor = [UIColor frescoBlueColor];
            circleR.alpha = 0.5;
        }
        else if (circle.circleType == FRSMapCircleTypeAssignment){
            circleR.fillColor = [UIColor frescoOrangeColor];
            circleR.alpha = 0.5;
        }
    }
    
    return circleR;
}

-(void)removeAllOverlaysIncludingUser:(BOOL)removeUser{
    for (id<MKOverlay>overlay in self.mapView.overlays){
        if ([overlay isKindOfClass:[FRSMapCircle class]]){
            FRSMapCircle *circle = (FRSMapCircle *)overlay;
            
            if (circle.circleType == FRSMapCircleTypeUser){
                if (!removeUser) continue;
            };
            
            [self.mapView removeOverlay:circle];
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
