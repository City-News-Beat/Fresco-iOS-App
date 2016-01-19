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

@import MapKit;

@interface FRSAssignmentsViewController () <MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSArray *assignments;

@property (nonatomic) BOOL isFetching;

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
        
        self.isFetching = NO;
    }];
}

#pragma mark - Region Setting

-(void)adjustMapRegionWithLocation:(CLLocation *)location{
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), MKCoordinateSpanMake(0.01f, 0.01f));
    
    [self.mapView setRegion:region animated:YES];
}

-(void)setInitialMapRegion{
    [self adjustMapRegionWithLocation:[FRSLocationManager sharedManager].lastAcquiredLocation];
}

#pragma mark - Annotations

-(void)configureAnnotationsForMap{
    [self addUserLocationCircleOverlay];
}




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
    circleR.fillColor = [UIColor frescoBlueColor];
    circleR.alpha = 0.5;
    
    return circleR;
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
