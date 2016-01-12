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

@import MapKit;

@interface FRSAssignmentsViewController ()

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSArray *assignments;

@property (nonatomic) BOOL isFetching;

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
}

-(void)adjustMapRegionWithLocation:(CLLocation *)location{
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), MKCoordinateSpanMake(0.15f, 0.15f));
    [self.mapView setRegion:region animated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
