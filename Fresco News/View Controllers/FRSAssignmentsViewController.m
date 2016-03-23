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

#import "UITextView+Resize.h"

@import MapKit;

@interface FRSAssignmentsViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
{
    NSMutableArray *dictionaryRepresentations;
    BOOL hasSnapped;
}
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSArray *assignments;

@property (strong, nonatomic) NSArray *overlays;

@property (nonatomic) BOOL isFetching;

@property (nonatomic) BOOL isOriginalSpan;

@property (strong, nonatomic) FRSMapCircle *userCircle;

@property (strong, nonatomic) FRSLocationManager *locationManager;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIView *dismissView;

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

    self.navigationItem.title = @"ASSIGNMENTS";
}

-(void)configureMap{
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.isOriginalSpan = YES;
    [self.view addSubview:self.mapView];
}

-(void)fetchAssignmentsNearLocation:(CLLocation *)location radius:(NSInteger)radii {
    
    if (self.isFetching) return;
    
    self.isFetching = YES;
    
    [[FRSAPIClient new] getAssignmentsWithinRadius:radii ofLocation:@[@(location.coordinate.latitude), @(location.coordinate.longitude)] withCompletion:^(id responseObject, NSError *error) {
        NSArray *assignments = (NSArray *)responseObject;
        
        NSMutableArray *mSerializedAssignments = [NSMutableArray new];
        NSLog(@"ASS: %@", mSerializedAssignments);
        
        for (NSDictionary *dict in assignments){
            [mSerializedAssignments addObject:[FRSAssignment assignmentWithDictionary:dict]];
            
            if (!dictionaryRepresentations) {
                dictionaryRepresentations = [[NSMutableArray alloc] init];
            }
            
            [dictionaryRepresentations addObject:dict];
        }
        
        self.assignments = [mSerializedAssignments copy];
        [self addAnnotationsForAssignments];
        
        self.isFetching = NO;
        
        [self cacheAssignments];
        [self configureAnnotationsForMap];
    }];
}

-(void)cacheAssignments {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        for (NSDictionary *dict in dictionaryRepresentations) {
            FRSAssignment *assignmentToSave = [FRSAssignment MR_createEntityInContext:localContext];
            [assignmentToSave configureWithDictionary:dict];
        }
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        NSLog(@"ASSIGNMENTS SAVED: %@", (contextDidSave) ? @"TRUE" : @"FALSE");
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
    
    for (id<MKAnnotation> annotation in self.mapView.annotations){
        [self.mapView removeAnnotation:annotation];
    }
    
    [self removeAllOverlaysIncludingUser:NO];
    
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
    CLLocationDistance distance = [assignment.radius floatValue] * 1609.34;
    FRSMapCircle *circle = [FRSMapCircle circleWithCenterCoordinate:coord radius:distance];
    circle.circleType = FRSMapCircleTypeAssignment;
    
    [self.mapView addOverlay:circle];
    [self.mapView addAnnotation:ann];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (!scrollTimer || ![scrollTimer isValid]) {
        scrollTimer = [NSTimer timerWithTimeInterval:.3 target:self selector:@selector(updateAssignments) userInfo:Nil repeats:NO];
    }
    else {
        [scrollTimer invalidate];
        scrollTimer = [NSTimer timerWithTimeInterval:.3 target:self selector:@selector(updateAssignments) userInfo:Nil repeats:NO];
    }
}

-(void)updateAssignments {
    MKCoordinateRegion region = self.mapView.region;
    CLLocationCoordinate2D center = region.center;
    MKCoordinateSpan regionSpan = region.span;
    
    NSInteger latitudeCircle = regionSpan.latitudeDelta / 69;
    
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    [self fetchAssignmentsNearLocation:location radius:latitudeCircle];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"assignment-annotation"];
    
    if (!annotationView) {
        
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"assignment-annotation"];
        
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(-12, -12, 24, 24)];
        whiteView.layer.cornerRadius = 12;
        whiteView.backgroundColor = [UIColor whiteColor];
        [annotationView addSubview:whiteView];
        
        whiteView.layer.shadowColor = [UIColor blackColor].CGColor;
        whiteView.layer.shadowOffset = CGSizeMake(0, 2);
        whiteView.layer.shadowOpacity = 0.15;
        whiteView.layer.shadowRadius = 1.5;
        whiteView.layer.shouldRasterize = YES;
        whiteView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        UIView *yellowView = [[UIView alloc] initWithFrame:CGRectMake(4, 4, 16, 16)];
        yellowView.layer.cornerRadius = 8;
        yellowView.backgroundColor = [UIColor frescoOrangeColor];
        
        [whiteView addSubview:yellowView];
        
        annotationView.enabled = YES;

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


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{

    [self configureAssignmentCard];
    [self snapToAnnotationView:view]; // centers map on top of content
    
}

-(void)snapToAnnotationView:(MKAnnotationView *)view {
    // get location
    // offset location to be in centered in view area screenHeight/3.5
    // create region based off this
    // center map to region
    
    CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude, view.annotation.coordinate.longitude);
    [self.mapView setCenterCoordinate:newCenter animated:YES];
}

-(void)configureAssignmentCard{
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -49, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.multipleTouchEnabled = NO;
    [self.view addSubview:self.scrollView];
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    self.dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
//    self.dismissView.backgroundColor = [UIColor redColor];
//    self.dismissView.alpha = 0.2;
    [self.scrollView addSubview:self.dismissView];
    
    UIView *assignmentCard = [[UIView alloc] initWithFrame:CGRectMake(0, 76 + [UIScreen mainScreen].bounds.size.height/3.5, self.view.frame.size.width, 412)];
    assignmentCard.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:assignmentCard];
    
    UIView *topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height/3.5, self.view.frame.size.width, 76)];
    topContainer.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:topContainer];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = topContainer.frame;
    gradient.opaque = NO;
    UIColor *startColor = [UIColor clearColor];
    UIColor *endColor = [UIColor colorWithWhite:0 alpha:0.42];
    gradient.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
    [self.scrollView.layer insertSublayer:gradient atIndex:0];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 288, 52)];
    titleLabel.text = @"Viral cronut letterpress put a bird on it, ugh blog quinoa";
    titleLabel.numberOfLines = 2;
    titleLabel.font = [UIFont notaBoldWithSize:24];
    titleLabel.textColor = [UIColor whiteColor];
    
    titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    titleLabel.layer.shadowOpacity = .15;
    titleLabel.layer.shadowRadius = 2;
    titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    titleLabel.clipsToBounds = NO;
    
    [topContainer addSubview:titleLabel];

    
    //Configure bottom container
    UIView *bottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    bottomContainer.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:bottomContainer];
    
    UIView *bottomContainerLine = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, self.view.frame.size.width, 0.5)];
    bottomContainerLine.backgroundColor = [UIColor frescoShadowColor];
    [bottomContainer addSubview:bottomContainerLine];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(self.view.frame.size.width -93 , 15, 77, 17);
    [button setTitle:@"ACCEPT ($5)" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [button setTitleColor:[UIColor frescoGreenColor] forState:UIControlStateNormal];
    [bottomContainer addSubview:button];
    
    UITextView *assignmentDetailTextField = [[UITextView alloc] initWithFrame:CGRectMake(16, 16, self.view.frame.size.width - 32, 220)];
    [assignmentCard addSubview:assignmentDetailTextField];
    [assignmentDetailTextField setFont:[UIFont systemFontOfSize:15]];
    assignmentDetailTextField.textColor = [UIColor frescoDarkTextColor];
    assignmentDetailTextField.userInteractionEnabled = NO;
    assignmentDetailTextField.editable = NO;
    assignmentDetailTextField.selectable = NO;
    assignmentDetailTextField.scrollEnabled = NO;
    assignmentDetailTextField.backgroundColor = [UIColor clearColor];
    
    [assignmentDetailTextField frs_setTextWithResize:@"To you of the outer earth it might seem a slow and tortuous method of traveling through the jungle, but were you of Pellucidar you would realize that time is no factor where time does not exist. So labyrinthine are the windings of these trails, so varied the connecting links and the distances which one must retrace one's steps from the paths' ends to find them that a Mezop often reaches man's estate before he is familiar even with those which lead from his own city to the sea. To you of the outer earth it might seem a slow and tortuous method of traveling through the jungle, but were you of Pellucidar you would realize that time is no factor where time does not exist. So labyrinthine are the windings of these trails, so varied the connecting links and the distances which one must retrace one's steps from the paths' ends to find them that a Mezop often reaches man's estate before he is familiar even with those which lead from his own city to the sea. To you of the outer earth it might seem a slow and tortuous method of traveling through the jungle, but were you of Pellucidar you would realize that time is no factor where time does not exist. So labyrinthine are the windings of these trails, so varied the connecting links and the distances which one must retrace one's steps from the paths' ends to find them that a Mezop often reaches man's estate before he is familiar even with those which lead from his own city to the sea."];
    
    
    UIImageView *photoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-icon-profile"]];
    photoImageView.frame = CGRectMake(16, 10, 24, 24);
    [bottomContainer addSubview:photoImageView];
    
    UILabel *photoCashLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 15, 23, 17)];
    photoCashLabel.text = @"$10";
    photoCashLabel.textColor = [UIColor frescoMediumTextColor];
    photoCashLabel.textAlignment = NSTextAlignmentCenter;
    photoCashLabel.font = [UIFont notaBoldWithSize:15];
    [bottomContainer addSubview:photoCashLabel];

    if (assignmentCard.frame.size.height < assignmentDetailTextField.frame.size.height) {
        CGRect cardFrame = assignmentCard.frame;
        cardFrame.size.height = assignmentDetailTextField.frame.size.height * 2;
        assignmentCard.frame = cardFrame;
    }
    
    NSInteger bottomPadding = 15; // whatever padding we need at the bottom
    
    self.scrollView.contentSize = CGSizeMake(assignmentCard.frame.size.width, (assignmentDetailTextField.frame.size.height + 50)+[UIScreen mainScreen].bounds.size.height/3.5 + topContainer.frame.size.height + bottomContainer.frame.size.height + bottomPadding);
    
    UIImageView *videoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-icon-profile"]];
    videoImageView.frame = CGRectMake(85, 10, 24, 24);
    [bottomContainer addSubview:videoImageView];
    
    UILabel *videoCashLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 15, 24, 17)];
    videoCashLabel.text = @"$50";
    videoCashLabel.textColor = [UIColor frescoMediumTextColor];
    videoCashLabel.textAlignment = NSTextAlignmentCenter;
    videoCashLabel.font = [UIFont notaBoldWithSize:15];
    [bottomContainer addSubview:videoCashLabel];
    
    
    [bottomContainer setOriginWithPoint:CGPointMake(0, self.scrollView.contentSize.height -93)]; //Check on 5/6plus

    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect scrollFrame = self.scrollView.frame;
        scrollFrame.origin.y = 0;
        self.scrollView.frame = scrollFrame;
        
    } completion:nil];
    
    currentScroller = self.scrollView;
    currentScroller.delegate = self;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.dismissView addGestureRecognizer:singleTap];
}

-(void)handleTap:(UITapGestureRecognizer *)sender {

    [self dismissAssignmentCard];

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == currentScroller) {
        [self handleAssignmentScroll];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentOffset.y <= -50) {
        [self dismissAssignmentCard];
    }
}


-(void)dismissAssignmentCard{
    [UIView animateWithDuration:0.4 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [self.scrollView setOriginWithPoint:CGPointMake(0, self.view.frame.size.height)];
        
    } completion:nil];
}

-(void)handleAssignmentScroll {
    
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
    
    if (!hasSnapped) {
        hasSnapped = TRUE;
        [self adjustMapRegionWithLocation:self.locationManager.lastAcquiredLocation];
    }
    
    [self fetchAssignmentsNearLocation:self.locationManager.lastAcquiredLocation radius:10];
    
    [self configureAnnotationsForMap];
}

@end
