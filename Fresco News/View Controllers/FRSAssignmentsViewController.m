//
//  FRSAssignmentsViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAssignmentsViewController.h"
#import "FRSTabBarController.h"
#import "FRSCameraViewController.h"

#import "FRSLocationManager.h"

#import "FRSAssignment.h"

#import "FRSDateFormatter.h"

#import "FRSMapCircle.h"
#import "FRSAssignmentAnnotation.h"

#import "UITextView+Resize.h"
#import "Fresco.h"

#import "FRSAppDelegate.h"

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

@property (strong, nonatomic) NSDate *assignmentExpirationDate;

@property (strong, nonatomic) UILabel *assignmentTitleLabel;

@property (strong, nonatomic) UITextView *assignmentTextView;

@property (strong, nonatomic) UIView *assignmentCard;

@property (strong, nonatomic) UILabel *expirationLabel;
@property (strong, nonatomic) UILabel *distanceLabel;

@property (nonatomic, assign) BOOL showsCard;
@property (nonatomic, retain) NSMutableArray *assignmentIDs;

@property (strong, nonatomic) UILabel *photoCashLabel;
@property (strong, nonatomic) UILabel *videoCashLabel;

@property (strong, nonatomic) UIButton *closeButton;

@property (strong, nonatomic) UIView *assignmentStatsContainer;

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
    
    [self fetchLocalAssignments];
    
    if (lastLocation) {
        [self locationUpdate:lastLocation];
    }
    
    self.navigationItem.title = @"ASSIGNMENTS";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont notaBoldWithSize:17]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self removeNavigationBarLine];
    
}

-(void)didReceiveLocationUpdate:(NSNotification *)notification {
    NSDictionary *latLong = notification.userInfo;
    
    NSNumber *lat = latLong[@"lat"];
    NSNumber *lon = latLong[@"lng"];
    
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
    
    [[FRSAPIClient sharedClient] getAssignmentsWithinRadius:radii ofLocation:@[@(location.coordinate.longitude), @(location.coordinate.latitude)] withCompletion:^(id responseObject, NSError *error) {
        NSArray *assignments = (NSArray *)responseObject[@"nearby"];
        NSArray *globalAssignments = (NSArray *)responseObject[@"global"];
        
        FRSAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSMutableArray *mSerializedAssignments = [NSMutableArray new];
        
        if (globalAssignments.count > 0) {
            
        }
                
        for (NSDictionary *dict in assignments){
            
            FRSAssignment *assignmentToAdd = [NSEntityDescription insertNewObjectForEntityForName:@"FRSAssignment" inManagedObjectContext:delegate.managedObjectContext];
            [assignmentToAdd configureWithDictionary:dict];
            NSString *uid = assignmentToAdd.uid;
            
            if ([self assignmentExists:uid]) {
                continue;
            }
            
            [mSerializedAssignments addObject:assignmentToAdd];

            if (!dictionaryRepresentations) {
                dictionaryRepresentations = [[NSMutableArray alloc] init];
            }
            
            [dictionaryRepresentations addObject:dict];
        }
        
        self.assignments = [mSerializedAssignments copy];
        [self addAnnotationsForAssignments];
        
        self.isFetching = NO;
        
        if (!notFirstFetch) {
            notFirstFetch = TRUE;
            [self cacheAssignments];
        }
        
        [self configureAnnotationsForMap];
        [delegate.managedObjectContext save:Nil];
        [delegate saveContext];
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

-(void)fetchLocalAssignments {
    FRSAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(expirationDate >= %@)", [NSDate date]];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FRSAssignment"];
    request.predicate = predicate;
    NSError *error = nil;
    NSArray *stored = [moc executeFetchRequest:request error:&error];
    self.assignments = [NSMutableArray arrayWithArray:stored];
    [self configureAnnotationsForMap];
}

-(void)cacheAssignments {
   
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
        if ([self assignmentExists:assignment.uid]) {
            continue;
        }
        
        [self.assignmentIDs addObject:assignment.uid];
        [self addAssignmentAnnotation:assignment index:count];
        count++;
    }
}

- (void)addAssignmentAnnotation:(FRSAssignment*)assignment index:(NSInteger)index {
    
    FRSAssignmentAnnotation *ann = [[FRSAssignmentAnnotation alloc] initWithAssignment:assignment atIndex:index];
//    NSLog(@"EXPIRATION %@", assignment.expirationDate);
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

    
//    for (id<MKOverlay>overlay in self.mapView.overlays) {
//        if ([overlay isKindOfClass:[FRSMapCircle class]]) {
//            FRSMapCircle *circle = (FRSMapCircle *)overlay;
//            
//            if (circle.circleType == FRSMapCircleTypeUser) {
//               
//                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//                view.backgroundColor = [UIColor redColor];
//                [annotationView addSubview:view];
//                
//                return annotationView;
//                
//            } else {
//
//            }
//        };
//    }
    
    
    if (!annotationView) {
        
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"assignment-annotation"];
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        container.backgroundColor = [UIColor clearColor];
        /* container.layer.borderColor = [UIColor redColor].CGColor;
        container.layer.borderWidth = 1.0f;*/
        
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(25.5, 25.5, 24, 24)];
        whiteView.layer.cornerRadius = 12;
        whiteView.backgroundColor = [UIColor whiteColor];
        
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
        [container addSubview:whiteView];
        [annotationView addSubview:container];

        annotationView.enabled = YES;
        annotationView.frame = CGRectMake(0, 0, 75, 75);
        
    }
    
    return annotationView;
}


#pragma mark - Circle Overlays

-(void)addUserLocationCircleOverlay {
    
    //    CGFloat radius = self.mapView.usergLocation.location.horizontalAccuracy > 100 ? 100 : self.mapView.userLocation.location.horizontalAccuracy;
    
    CGFloat radius = 300;
    
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

    [self.mapView deselectAnnotation:view.annotation animated:NO];

    FRSAssignmentAnnotation *assAnn = (FRSAssignmentAnnotation *)view.annotation;
    
    self.assignmentTitle = assAnn.title;
    self.assignmentCaption = assAnn.subtitle;
    self.assignmentExpirationDate = assAnn.assignmentExpirationDate;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    NSString *dateString = [formatter stringFromDate:self.assignmentExpirationDate];
    self.expirationLabel.text = dateString; //Not up to spec. "Expires in 24 minutes"
    
    [self configureAssignmentCard];
    [self animateAssignmentCard];
    [self snapToAnnotationView:view]; // Centers map with y offset
    
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
    self.assignmentCard = [[UIView alloc] initWithFrame:CGRectMake(0, 76 + [UIScreen mainScreen].bounds.size.height/3.5, self.view.frame.size.width, 1000)]; //Height is 1000 to avoid user overscrolling in y
    self.assignmentCard.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:self.assignmentCard];
    
    UIView *topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, -76, self.view.frame.size.width, 76)];
    topContainer.backgroundColor = [UIColor clearColor];
    [self.assignmentCard addSubview:topContainer];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = topContainer.frame;
    gradient.opaque = NO;
    UIColor *startColor = [UIColor clearColor];
    UIColor *endColor = [UIColor colorWithWhite:0 alpha:0.42];
    gradient.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
    [self.assignmentCard.layer insertSublayer:gradient atIndex:0];
    
    self.assignmentTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 288, 52)];
    self.assignmentTitleLabel.font = [UIFont notaBoldWithSize:24];
    self.assignmentTitleLabel.numberOfLines = 0;
    self.assignmentTitleLabel.text = self.assignmentTitle;
//    [self.assignmentTitleLabel sizeToFit];
    self.assignmentTitleLabel.textColor = [UIColor whiteColor];
    self.assignmentTitleLabel.adjustsFontSizeToFitWidth = YES;
    
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
    self.assignmentBottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44)];
    self.assignmentBottomBar.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.view addSubview:self.assignmentBottomBar];
    
    UIView *bottomContainerLine = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, self.view.frame.size.width, 0.5)];
    bottomContainerLine.backgroundColor = [UIColor frescoShadowColor];
    [self.assignmentBottomBar addSubview:bottomContainerLine];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(self.view.frame.size.width -93-23 , 15, 100, 17);
    [button setTitle:@"OPEN CAMERA" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [button setTitleColor:[UIColor frescoGreenColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(acceptAssignment) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    
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
    
    self.photoCashLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 15, 23, 17)];
    self.photoCashLabel.text = @"$10";
    self.photoCashLabel.textColor = [UIColor frescoMediumTextColor];
    self.photoCashLabel.textAlignment = NSTextAlignmentCenter;
    self.photoCashLabel.font = [UIFont notaBoldWithSize:15];
    [self.assignmentBottomBar addSubview:self.photoCashLabel];
    
    if (self.assignmentCard.frame.size.height < self.assignmentTextView.frame.size.height) {
        CGRect cardFrame = self.assignmentCard.frame;
        cardFrame.size.height = self.assignmentTextView.frame.size.height * 2;
        self.assignmentCard.frame = cardFrame;
    }
    
    NSInteger bottomPadding = 15; // whatever padding we need at the bottom
    
//    self.scrollView.contentSize = CGSizeMake(self.assignmentCard.frame.size.width, (self.assignmentTextView.frame.size.height + 50)+[UIScreen mainScreen].bounds.size.height/3.5 + topContainer.frame.size.height + self.assignmentBottomBar.frame.size.height + bottomPadding +190); //120 is the height of the container at the bottom where expiration time, assignemnt distance, and the warning label live.
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height +1); //TODO: test with longer assignment captions
    
    UIImageView *videoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video-icon"]];
    videoImageView.frame = CGRectMake(85, 10, 24, 24);
    [self.assignmentBottomBar addSubview:videoImageView];
    
    self.videoCashLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 15, 24, 17)];
    self.videoCashLabel.text = @"$50";
    self.videoCashLabel.textColor = [UIColor frescoMediumTextColor];
    self.videoCashLabel.textAlignment = NSTextAlignmentCenter;
    self.videoCashLabel.font = [UIFont notaBoldWithSize:15];
    [self.assignmentBottomBar addSubview:self.videoCashLabel];
    
    self.assignmentStatsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.assignmentTextView.frame.size.height + 16, self.view.frame.size.width, 120)];
    [self.assignmentCard addSubview:self.assignmentStatsContainer];
    
    UIImageView *clock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock"]];
    clock.frame = CGRectMake(16, 8, 24, 24);
    [self.assignmentStatsContainer addSubview:clock];
    
    UIImageView *mapAnnotation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"annotation"]];
    mapAnnotation.frame = CGRectMake(16, 48, 24, 24);
    [self.assignmentStatsContainer addSubview:mapAnnotation];
    
    UIImageView *warning = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
    warning.frame = CGRectMake(16, 88, 24, 24);
    [self.assignmentStatsContainer addSubview:warning];
    
    self.expirationLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 10, self.view.frame.size.width, 20)];
    self.expirationLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.expirationLabel.textColor = [UIColor frescoMediumTextColor];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    NSString *dateString = [formatter stringFromDate:self.assignmentExpirationDate];
    self.expirationLabel.text = dateString;

    [self.assignmentStatsContainer addSubview:self.expirationLabel];
    
    self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 50, self.view.frame.size.width, 20)];
    self.distanceLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.distanceLabel.textColor = [UIColor frescoMediumTextColor];
    self.distanceLabel.text = @"1.1 miles away";
    [self.assignmentStatsContainer addSubview:self.distanceLabel];
    
    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 90, self.view.frame.size.width, 20)];
    warningLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    warningLabel.textColor = [UIColor frescoMediumTextColor];
    warningLabel.text = @"Not all events are safe. Be careful!";
    [self.assignmentStatsContainer addSubview:warningLabel];
    
    UIImage *closeButtonImage = [UIImage imageNamed:@"close"];
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.tintColor = [UIColor whiteColor];
    [self.closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    self.closeButton.frame = CGRectMake(0 , 0, 24, 24);
    [self.closeButton addTarget:self action:@selector(dismissAssignmentCard) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:self.closeButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    //Configure photo/video labels for animation
    self.closeButton.alpha    = 0;
    //self.photoCashLabel.alpha = 0;
    //self.videoCashLabel.alpha = 0;
    //self.photoCashLabel.transform = CGAffineTransformMakeTranslation(-5, 0);
    //self.videoCashLabel.transform = CGAffineTransformMakeTranslation(-5, 0);
    
    
    [self.assignmentTextView frs_setTextWithResize:self.assignmentCaption];
    self.assignmentCard.frame = CGRectMake(self.assignmentCard.frame.origin.x, self.view.frame.size.height - (24 + self.assignmentTextView.frame.size.height + 24 + 40 + 24 + 44 + 49 + 24 + bottomPadding), self.assignmentCard.frame.size.width, self.assignmentCard.frame.size.height);
    
    
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
    
    currentScroller = self.scrollView;
    currentScroller.delegate = self;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTap:)];
    [self.dismissView addGestureRecognizer:singleTap];
    
    [self.assignmentTextView frs_setTextWithResize:self.assignmentCaption];
    self.assignmentCard.frame = CGRectMake(self.assignmentCard.frame.origin.x, self.view.frame.size.height - (24 + self.assignmentTextView.frame.size.height + 24 + 40 + 24 + 44 + 49 + 24 + 15), self.assignmentCard.frame.size.width, self.assignmentCard.frame.size.height);
    self.assignmentStatsContainer.frame = CGRectMake(self.assignmentStatsContainer.frame.origin.x, self.assignmentTextView.frame.size.height + 24, self.assignmentStatsContainer.frame.size.width, self.assignmentStatsContainer.frame.size.height);
}

-(void)dismissTap:(UITapGestureRecognizer *)sender {

    [self dismissAssignmentCard];
    
    //Waits for animation to complete before removing from superview
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.scrollView removeFromSuperview];
        [self.assignmentBottomBar removeFromSuperview];
    });
}

-(void)animateAssignmentCard{
    
    //Animate scrollView in y
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGRect scrollFrame = self.scrollView.frame;
        scrollFrame.origin.y = 0;
        self.scrollView.frame = scrollFrame;
        
    } completion:nil];
    
    //Animate bottom bar in y
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.assignmentBottomBar.transform = CGAffineTransformMakeTranslation(0, -93);
        
    } completion:^(BOOL finished) {
        
        //Animate photoCashLabel
        [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            //self.photoCashLabel.alpha = 1;
            //self.photoCashLabel.transform = CGAffineTransformMakeTranslation(0, 0);

        } completion:nil];
        
        //Animate videoCashLabel with delay
        [UIView animateWithDuration:0.2 delay:0.1 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            //self.videoCashLabel.alpha = 1;
            //self.videoCashLabel.transform = CGAffineTransformMakeTranslation(0, 0);

        } completion:nil];
    }];
    
    [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.closeButton.alpha = 1;
        
    } completion:nil];
}

-(void)dismissAssignmentCard {
    
    self.showsCard = FALSE;
    
    
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
    self.assignmentCard.frame = CGRectMake(self.assignmentCard.frame.origin.x, self.assignmentCard.frame.origin.y + (self.view.frame.size.height - self.assignmentCard.frame.origin.y) +100, self.assignmentCard.frame.size.width, self.assignmentCard.frame.size.height);
        
    } completion:nil];
    
    [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.assignmentBottomBar.transform = CGAffineTransformMakeTranslation(0, 44);
        
    } completion:^(BOOL finished) {
        
        [self.scrollView setOriginWithPoint:CGPointMake(0, self.view.frame.size.height)];

        //Reset animated labels
//        self.photoCashLabel.alpha = 0;
//        self.videoCashLabel.alpha = 0;
//        self.photoCashLabel.transform = CGAffineTransformMakeTranslation(-5, 0);
//        self.videoCashLabel.transform = CGAffineTransformMakeTranslation(-5, 0);
    }];
    
    [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.closeButton.alpha = 0;
    } completion:nil];
}

-(void)acceptAssignment {
    NSLog(@"acceptAssignment");
    
    FRSCameraViewController *cam = [[FRSCameraViewController alloc] initWithCaptureMode:FRSCaptureModeVideo];
    UINavigationController *navControl = [[UINavigationController alloc] init];
    navControl.navigationBar.barTintColor = [UIColor frescoOrangeColor];
    [navControl pushViewController:cam animated:NO];
    [navControl setNavigationBarHidden:YES];
    
    [self presentViewController:navControl animated:YES completion:^{
        [self.tabBarController setSelectedIndex:3];//should return to assignments 
    }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == currentScroller) {
        [self handleAssignmentScroll];
    }
        
//    if (self.scrollView.contentOffset.y <= -80) {
//        [self dismissAssignmentCard];
//    }
}


-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y <= -75) { //QA value, see what's most comfortable for over scrolling and dismissing
        [self dismissAssignmentCard];
    }
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
