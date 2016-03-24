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
#import "Fresco.h"

@import MapKit;

@interface FRSAssignmentsViewController () <MKMapViewDelegate>
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

@property (strong, nonatomic) UIView *assignmentBottomBar;

@property (strong, nonatomic) NSString *assignmentTitle;

@property (strong, nonatomic) NSString *assignmentCaption;

@property (strong, nonatomic) UILabel *assignmentTitleLabel;

@property (strong, nonatomic) UITextView *assignmentTextView;

@property (strong, nonatomic) UIView *assignmentCard;

@property (nonatomic, assign) BOOL showsCard;
@property (nonatomic, retain) NSMutableArray *assignmentIDs;
@end

@implementation FRSAssignmentsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self configureMap];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLocationUpdate:)
                                                 name:FRSLocationUpdateNotification
                                               object:nil];
    
    self.assignmentIDs = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.isPresented = YES;
    
    CLLocation *lastLocation = [FRSLocator sharedLocator].currentLocation;
    
    if (lastLocation) {
        [self locationUpdate:lastLocation];
    }
}

-(void)didReceiveLocationUpdate:(NSNotification *)notification {
    NSDictionary *latLong = notification.userInfo;
    
    NSNumber *lat = latLong[@"lat"];
    NSNumber *lon = latLong[@"lon"];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[lat floatValue] longitude:[lon floatValue]];
    [self locationUpdate:location];
}

-(void)locationUpdate:(CLLocation *)location {
    
    if (!hasSnapped) {
        hasSnapped = TRUE;
        [self adjustMapRegionWithLocation:location];
        [self addUserLocationCircleOverlay];
        [self fetchAssignmentsNearLocation:location radius:10];
        [self configureAnnotationsForMap];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [[FRSLocationManager sharedManager] pauseLocationMonitoring];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isPresented = NO;
}

-(void)configureNavigationBar {

    self.navigationItem.title = @"ASSIGNMENTS";
}

-(void)configureMap {
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsBuildings = NO;
    self.isOriginalSpan = YES;
    [self.view addSubview:self.mapView];
}

-(void)fetchAssignmentsNearLocation:(CLLocation *)location radius:(NSInteger)radii {
    
    if (self.isFetching) return;
    
    self.isFetching = YES;
    
    [[FRSAPIClient sharedClient] getAssignmentsWithinRadius:radii ofLocation:@[@(location.coordinate.latitude), @(location.coordinate.longitude)] withCompletion:^(id responseObject, NSError *error) {
        NSArray *assignments = (NSArray *)responseObject;
        
        NSMutableArray *mSerializedAssignments = [NSMutableArray new];
        NSLog(@"ASS: %@", mSerializedAssignments);
        
        for (NSDictionary *dict in assignments){
            FRSAssignment *assignmentToAdd = [FRSAssignment assignmentWithDictionary:dict];
            NSString *uid = assignmentToAdd.uid;
            
            if ([self assignmentExists:uid]) {
                continue;
            }
            
            [mSerializedAssignments addObject:assignmentToAdd];
            [self.assignmentIDs addObject:uid];
            
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

-(BOOL)assignmentExists:(NSString *)assignment {
    
    __block BOOL returnValue = FALSE;
    
    [self.assignmentIDs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *currentID = (NSString *)obj;
        
        if ([currentID isEqualToString:assignment]) {
            returnValue = TRUE;
        }
    }];
    
    return returnValue;
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

-(void)adjustMapRegionWithLocation:(CLLocation *)location {
    
    //We want to preserve the span if the user modified it.
    MKCoordinateSpan currentSpan = self.mapView.region.span;
    
    if (self.isOriginalSpan){
        currentSpan = MKCoordinateSpanMake(0.03f, 0.03f);
        self.isOriginalSpan = NO;
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), currentSpan);
    
    [self.mapView setRegion:region animated:YES];
}

-(void)setInitialMapRegion {
    
    if (self.showsCard) {
        // dismiss card?
        
        return;
    }
    
    self.isOriginalSpan = YES;
    
    if ([FRSLocator sharedLocator].currentLocation) {
        [self adjustMapRegionWithLocation:[FRSLocator sharedLocator].currentLocation];
    }
}

#pragma mark - Annotations

-(void)configureAnnotationsForMap {
    [self addAnnotationsForAssignments];
}

-(void)addAnnotationsForAssignments {
    
    /*for (id<MKAnnotation> annotation in self.mapView.annotations) {
        [self.mapView removeAnnotation:annotation];
    }*/
    
    /*[self removeAllOverlaysIncludingUser:NO];*/
    
    NSInteger count = 0;
    
    for(FRSAssignment *assignment in self.assignments) {
        [self addAssignmentAnnotation:assignment index:count];
        count++;
    }
}

- (void)addAssignmentAnnotation:(FRSAssignment*)assignment index:(NSInteger)index {
    
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
    [self updateAssignments];
}

-(void)updateAssignments {
    
    MKCoordinateRegion region = self.mapView.region;
    CLLocationCoordinate2D center = region.center;
    MKCoordinateSpan span = region.span;
    
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:(center.latitude - span.latitudeDelta * 0.5) longitude:center.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:(center.latitude + span.latitudeDelta * 0.5) longitude:center.longitude];
    NSInteger metersLatitude = [loc1 distanceFromLocation:loc2];
    NSInteger milesLatitude = metersLatitude / 1609.34;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    [self fetchAssignmentsNearLocation:location radius:milesLatitude];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
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


-(void)tap{
    NSLog(@"tap");
}


#pragma mark - Circle Overlays

-(void)addUserLocationCircleOverlay {
    
    //    CGFloat radius = self.mapView.usergLocation.location.horizontalAccuracy > 100 ? 100 : self.mapView.userLocation.location.horizontalAccuracy;
    
    CGFloat radius = 100;
    
    if (self.userCircle) {
        [self.mapView removeOverlay:self.userCircle];
    }
    
    CLLocation *userLocation = [FRSLocator sharedLocator].currentLocation;
    

    self.userCircle = [FRSMapCircle circleWithCenterCoordinate:userLocation.coordinate radius:radius];
    self.userCircle.circleType = FRSMapCircleTypeUser;
    
    [self.mapView addOverlay:self.userCircle];

}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKCircleRenderer *circleR = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
    
    if ([overlay isKindOfClass:[FRSMapCircle class]]) {
        FRSMapCircle *circle = (FRSMapCircle *)overlay;
        
        if (circle.circleType == FRSMapCircleTypeUser) {
            circleR.fillColor = [UIColor frescoBlueColor];
            circleR.alpha = 0.5;
        }
        else if (circle.circleType == FRSMapCircleTypeAssignment) {
            circleR.fillColor = [UIColor frescoOrangeColor];
            circleR.alpha = 0.5;
        }
    }
    
    return circleR;
}

-(void)removeAllOverlaysIncludingUser:(BOOL)removeUser {
    for (id<MKOverlay>overlay in self.mapView.overlays) {
        if ([overlay isKindOfClass:[FRSMapCircle class]]) {
            FRSMapCircle *circle = (FRSMapCircle *)overlay;
            
            if (circle.circleType == FRSMapCircleTypeUser) {
                if (!removeUser) continue;
            };
            
            [self.mapView removeOverlay:circle];
        }
    }
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"TAP");
    FRSAssignmentAnnotation *assAnn = (FRSAssignmentAnnotation *)view.annotation;
    self.assignmentTitle = assAnn.title;
    self.assignmentCaption = assAnn.subtitle;
    [self configureAssignmentCard];
    [self snapToAnnotationView:view]; // centers map on top of content
}

-(void)snapToAnnotationView:(MKAnnotationView *)view {
    CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude, view.annotation.coordinate.longitude);
    newCenter.latitude -= self.mapView.region.span.latitudeDelta * 0.25;
    [self.mapView setCenterCoordinate:newCenter animated:YES];
    
    if ([self.mapView respondsToSelector:@selector(camera)]) {
        [self.mapView setShowsBuildings:NO];
        MKMapCamera *newCamera = [[self.mapView camera] copy];
        [newCamera setHeading:0];
        [self.mapView setCamera:newCamera animated:YES];
    }
}

-(void)createAssignmentView{
    self.showsCard = TRUE;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -49, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.multipleTouchEnabled = NO;
    [self.view addSubview:self.scrollView];
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    self.dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    [self.scrollView addSubview:self.dismissView];
    
    // needs to be global variable & removed on dismiss
    self.assignmentCard = [[UIView alloc] initWithFrame:CGRectMake(0, 76 + [UIScreen mainScreen].bounds.size.height/3.5, self.view.frame.size.width, 412)];
    self.assignmentCard.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:self.assignmentCard];
    
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
    
    self.assignmentTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 288, 52)];
    self.assignmentTitleLabel.font = [UIFont notaBoldWithSize:24];
    self.assignmentTitleLabel.numberOfLines = 0;
    self.assignmentTitleLabel.text = self.assignmentTitle;
    [self.assignmentTitleLabel sizeToFit];
    self.assignmentTitleLabel.textColor = [UIColor whiteColor];
    
    if (self.assignmentTitleLabel.frame.size.height == 72) { // 72 is the size of titleLabel with 3 lines
        [self.assignmentTitleLabel setOriginWithPoint:CGPointMake(16, 0)];
    }
    
    self.assignmentTitleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.assignmentTitleLabel.layer.shadowOpacity = .15;
    self.assignmentTitleLabel.layer.shadowRadius = 2;
    self.assignmentTitleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    self.assignmentTitleLabel.clipsToBounds = NO;
    
    [topContainer addSubview:self.assignmentTitleLabel];
    
    //Configure bottom container
    self.assignmentBottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -93, self.view.frame.size.width, 44)];
    self.assignmentBottomBar.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.view addSubview:self.assignmentBottomBar];
    
    UIView *bottomContainerLine = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, self.view.frame.size.width, 0.5)];
    bottomContainerLine.backgroundColor = [UIColor frescoShadowColor];
    [self.assignmentBottomBar addSubview:bottomContainerLine];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(self.view.frame.size.width -93 , 15, 77, 17);
    [button setTitle:@"ACCEPT ($5)" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [button setTitleColor:[UIColor frescoGreenColor] forState:UIControlStateNormal];
    [self.assignmentBottomBar addSubview:button];
    
    self.assignmentTextView = [[UITextView alloc] initWithFrame:CGRectMake(16, 16, self.view.frame.size.width - 32, 220)];
    [self.assignmentCard addSubview:self.assignmentTextView];
    [self.assignmentTextView setFont:[UIFont systemFontOfSize:15]];
    self.assignmentTextView.textColor = [UIColor frescoDarkTextColor];
    self.assignmentTextView.userInteractionEnabled = NO;
    self.assignmentTextView.editable = NO;
    self.assignmentTextView.selectable = NO;
    self.assignmentTextView.scrollEnabled = NO;
    self.assignmentTextView.backgroundColor = [UIColor clearColor];
    
    [self.assignmentTextView frs_setTextWithResize:self.assignmentCaption];
    
    UIImageView *photoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-icon-profile"]];
    photoImageView.frame = CGRectMake(16, 10, 24, 24);
    [self.assignmentBottomBar addSubview:photoImageView];
    
    UILabel *photoCashLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 15, 23, 17)];
    photoCashLabel.text = @"$10";
    photoCashLabel.textColor = [UIColor frescoMediumTextColor];
    photoCashLabel.textAlignment = NSTextAlignmentCenter;
    photoCashLabel.font = [UIFont notaBoldWithSize:15];
    [self.assignmentBottomBar addSubview:photoCashLabel];
    
    if (self.assignmentCard.frame.size.height < self.assignmentTextView.frame.size.height) {
        CGRect cardFrame = self.assignmentCard.frame;
        cardFrame.size.height = self.assignmentTextView.frame.size.height * 2;
        self.assignmentCard.frame = cardFrame;
    }
    
    NSInteger bottomPadding = 15; // whatever padding we need at the bottom
    
    self.scrollView.contentSize = CGSizeMake(self.assignmentCard.frame.size.width, (self.assignmentTextView.frame.size.height + 50)+[UIScreen mainScreen].bounds.size.height/3.5 + topContainer.frame.size.height + self.assignmentBottomBar.frame.size.height + bottomPadding);
    
    UIImageView *videoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-icon-profile"]];
    videoImageView.frame = CGRectMake(85, 10, 24, 24);
    [self.assignmentBottomBar addSubview:videoImageView];
    
    UILabel *videoCashLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 15, 24, 17)];
    videoCashLabel.text = @"$50";
    videoCashLabel.textColor = [UIColor frescoMediumTextColor];
    videoCashLabel.textAlignment = NSTextAlignmentCenter;
    videoCashLabel.font = [UIFont notaBoldWithSize:15];
    [self.assignmentBottomBar addSubview:videoCashLabel];
}

-(void)configureAssignmentCard {
    
    if (_scrollView) {
        self.assignmentTitleLabel.text = self.assignmentTitle;
        self.assignmentTextView.text = self.assignmentCaption;
        
    } else {
        [self createAssignmentView];
    }
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.assignmentBottomBar];
    
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect scrollFrame = self.scrollView.frame;
        scrollFrame.origin.y = 0;
        self.scrollView.frame = scrollFrame;
        self.assignmentBottomBar.transform = CGAffineTransformMakeTranslation(0, 0);
        
    } completion:nil];
    
    currentScroller = self.scrollView;
    currentScroller.delegate = self;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTap:)];
    [self.dismissView addGestureRecognizer:singleTap];
}

-(void)dismissTap:(UITapGestureRecognizer *)sender {

    [self dismissAssignmentCard];
    
    //Waits for animation to complete before removing from superview
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.scrollView removeFromSuperview];
        [self.assignmentBottomBar removeFromSuperview];
    });
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == currentScroller) {
        [self handleAssignmentScroll];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y <= -50) {
        [self dismissAssignmentCard];
    }
}


-(void)dismissAssignmentCard {
    
    self.showsCard = FALSE;
    
    [UIView animateWithDuration:0.4 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [self.scrollView setOriginWithPoint:CGPointMake(0, self.view.frame.size.height)];
        self.assignmentBottomBar.transform = CGAffineTransformMakeTranslation(0, 44);
        
    } completion:nil];
}

-(void)handleAssignmentScroll {
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!locations.count) {
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
