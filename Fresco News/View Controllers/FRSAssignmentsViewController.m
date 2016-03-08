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

#import "FRSAssignment.h"

#import "FRSDateFormatter.h"

#import "FRSMapCircle.h"
#import "FRSAssignmentAnnotation.h"

@import MapKit;

@interface FRSAssignmentsViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSArray *assignments;

@property (strong, nonatomic) NSArray *overlays;

@property (nonatomic) BOOL isFetching;

@property (nonatomic) BOOL isOriginalSpan;

@property (strong, nonatomic) FRSMapCircle *userCircle;

@property (strong, nonatomic) FRSLocationManager *locationManager;



@end

@implementation FRSAssignmentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureMap];
    
    
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.isPresented = YES;
    
//    [self addNotificationObservers];
    
    self.locationManager = [[FRSLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startLocationMonitoringForeground];
//    [[FRSLocationManager sharedManager] startLocationMonitoringForeground];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    [[FRSLocationManager sharedManager] pauseLocationMonitoring];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    self.isPresented = NO;
}



-(void)configureNavigationBar{
//    [super configureNavigationBar];
    self.navigationItem.title = @"ASSIGNMENTS";
}

-(void)configureMap{
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    self.mapView.delegate = self;
    self.isOriginalSpan = YES;
    [self.view addSubview:self.mapView];
}

-(void)addNotificationObservers{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocations:) name:NOTIF_LOCATIONS_UPDATE object:nil];
}

//-(void)didUpdateLocations:(NSNotification *)notification{
//    NSArray *locations = notification.userInfo[@"locations"];
//    
//    NSLog(@"Location update notification observed by assignmentsVC");
//    
//    if (!locations.count) return;
//    
//    CLLocation *currentLocation = [locations lastObject];
//    
//    [self adjustMapRegionWithLocation:currentLocation];
//    
//    [self fetchAssignmentsNearLocation:currentLocation];
//    
//    [self configureAnnotationsForMap];
//}


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
    [self adjustMapRegionWithLocation:self.locationManager.lastAcquiredLocation];
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



#pragma mark - Circle Overlays

-(void)addUserLocationCircleOverlay{
    
    //    CGFloat radius = self.mapView.userLocation.location.horizontalAccuracy > 100 ? 100 : self.mapView.userLocation.location.horizontalAccuracy;
    CGFloat radius = 100;
    
    if (self.userCircle){
        [self.mapView removeOverlay:self.userCircle];
    }
    
    self.userCircle = [FRSMapCircle circleWithCenterCoordinate:self.locationManager.lastAcquiredLocation.coordinate radius:radius];
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

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if (!locations.count){
        NSLog(@"FRSLocationManager did not return any locations");
        return;
    }
    
    if (![self.locationManager significantLocationChangeForLocation:[locations lastObject]]) return;
    
    self.locationManager.lastAcquiredLocation = [locations lastObject];
    
    //    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOCATIONS_UPDATE object:nil userInfo:@{@"locations" : locations}];
    
    if (self.locationManager.monitoringState == FRSLocationMonitoringStateForeground){
        [self.locationManager stopUpdatingLocation];
    }
    
    NSLog(@"Location update notification observed by assignmentsVC");
    
//    CLLocation *currentLocation = [locations lastObject];
    
    [self adjustMapRegionWithLocation:self.locationManager.lastAcquiredLocation];
    
    [self fetchAssignmentsNearLocation:self.locationManager.lastAcquiredLocation];
    
    [self configureAnnotationsForMap];
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
