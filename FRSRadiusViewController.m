//
//  FRSRadiusViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSRadiusViewController.h"
#import "UIView+Helpers.h"
#import "FRSAssignmentAnnotation.h"
#import "FRSMapCircle.h"
#import "FRSUser.h"
#import "Haneke.h"
#import "FRSUserManager.h"
#import "FRSAssignment.h"

@import MapKit;

@interface FRSRadiusViewController () <MKMapViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationDistance distance;


@end

@implementation FRSRadiusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureView];
}

- (void)configureNavigationBar {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    label.text = @"RADIUS";
    label.font = [UIFont notaBoldWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [self configureBackButtonAnimated:YES];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setTitleView:label];
}

- (void)configureView {

    [self configureNavigationBar];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];

    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 2 - 55)];
    self.mapView.delegate = self;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.rotateEnabled = NO;
    
    
    MKCoordinateRegion region;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.assignment[@"location"][@"coordinates"][0] doubleValue] longitude:[self.assignment[@"location"][@"coordinates"][1] doubleValue]];
    
    region.center.latitude = location.coordinate.longitude;
    region.center.longitude = location.coordinate.latitude;
    
    [self.mapView setRegion:region animated:YES];
    
    [self.view addSubview:self.mapView];
    
    [self zoomToCoordinates:region.center.latitude lon:region.center.longitude withRadius:@([self.assignment[@"radius"] doubleValue]) withAnimation:YES];
    
    [self.mapView addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];

    [self addAssignmentAnnotation:self.assignment index:0];
    
    
    
    UIView *sliderContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.mapView.frame.size.height, self.view.frame.size.width, 44)];
    sliderContainer.backgroundColor = [UIColor colorWithWhite:1 alpha:.92];
    [self.view addSubview:sliderContainer];

    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, self.view.bounds.size.width, 0.5)];
    top.alpha = 0.12;
    top.backgroundColor = [UIColor blackColor];
    [sliderContainer addSubview:top];

    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 44.5, self.view.bounds.size.width, 0.5)];
    bottom.alpha = 0.12;
    bottom.backgroundColor = [UIColor blackColor];
    [sliderContainer addSubview:bottom];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width-32, 44)];
    textField.tintColor = [UIColor frescoBlueColor];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    [textField becomeFirstResponder];
    textField.delegate = self;
    textField.text = [NSString stringWithFormat:@"%.0f", RoundTo(([self.assignment[@"radius"] floatValue] * metersInAMile), 100)];
    [textField addTarget:self action:@selector(updateMapFromTextFieldText:) forControlEvents:UIControlEventEditingChanged];
    [sliderContainer addSubview:textField];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    nextButton.tintColor = [UIColor frescoBlueColor];
    [nextButton setTitle:@"NEXT" forState:UIControlStateNormal];
    [nextButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    nextButton.frame = CGRectMake(self.view.frame.size.width -100, self.mapView.frame.size.height + sliderContainer.frame.size.height, 100, 56);
    [self.view addSubview:nextButton];
}

- (void)next {
    
    NSMutableDictionary *mutableDict = [self.assignment mutableCopy];
    [mutableDict setObject:@(self.distance / 1609.34) forKey:@"radius"];
    self.assignment = [mutableDict mutableCopy];
    
//    FRSRadiusViewController *locvc = [[FRSRadiusViewController alloc] init];
//    locvc.assignment = self.assignment;
//    [self.navigationController pushViewController:locvc animated:YES];
    
    
}

- (void)updateMapFromTextFieldText:(UITextField *)textField {
    
    if ([textField.text length] > 6) {
        return;
    }
    
    MKCoordinateRegion region;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.assignment[@"location"][@"coordinates"][0] doubleValue] longitude:[self.assignment[@"location"][@"coordinates"][1] doubleValue]];
    
    region.center.latitude = location.coordinate.longitude;
    region.center.longitude = location.coordinate.latitude;
    [self zoomToCoordinates:region.center.latitude lon:region.center.longitude withRadius:@([textField.text doubleValue] / metersInAMile) withAnimation:YES];
    
    self.distance = [textField.text floatValue];
    
    NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
    [self.mapView removeAnnotations:annotations];
    
    [self removeAllOverlaysIncludingUser:YES];
    
    [self addAssignmentAnnotation:self.assignment index:0];
    
}

- (void)removeAllOverlaysIncludingUser:(BOOL)removeUser {
    for (id<MKOverlay> overlay in self.mapView.overlays) {
        if ([overlay isKindOfClass:[FRSMapCircle class]]) {
            FRSMapCircle *circle = (FRSMapCircle *)overlay;
            
            if (circle.circleType == FRSMapCircleTypeUser) {
                if (!removeUser)
                    continue;
            };
            
            [self.mapView removeOverlay:circle];
        }
    }
}

float RoundTo(float number, float to)
{
    if (number >= 0) {
        return to * floorf(number / to + 0.5f);
    }
    else {
        return to * ceilf(number / to - 0.5f);
    }
}


- (void)addAssignmentAnnotation:(NSMutableDictionary *)dictionary index:(NSInteger)index {
    
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    FRSAssignment *assignment = [NSEntityDescription insertNewObjectForEntityForName:@"FRSAssignment" inManagedObjectContext:delegate.managedObjectContext];
    [assignment configureWithDictionary:dictionary];
    
    FRSAssignmentAnnotation *ann = [[FRSAssignmentAnnotation alloc] initWithAssignment:assignment atIndex:index];
    // create center coordinate for the assignment
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([assignment.latitude floatValue], [assignment.longitude floatValue]);
    
    // create MKCircle surroudning the annotation
    if (![@(self.distance) boolValue]) {
        self.distance = [assignment.radius floatValue] * metersInAMile;
    }
    FRSMapCircle *circle = [FRSMapCircle circleWithCenterCoordinate:coord radius:self.distance];
    circle.circleType = FRSMapCircleTypeAssignment;
    
    [self.mapView addOverlay:circle];
    [self.mapView addAnnotation:ann];
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKCircleRenderer *circleR = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
    if ([overlay isKindOfClass:[FRSMapCircle class]]) {
        circleR.fillColor = [UIColor frescoOrangeColor];
        circleR.alpha = 0.3;
    }
    
    return circleR;
}

- (void)zoomToCoordinates:(double)lat lon:(double)lon withRadius:(NSNumber *)radius withAnimation:(BOOL)animate {
    // Span uses degrees, 1 degree = 69 miles
    MKCoordinateSpan span = MKCoordinateSpanMake(
        ([radius floatValue] / 30),
        ([radius floatValue] / 30));
    MKCoordinateRegion region = { CLLocationCoordinate2DMake(lat, lon), span };
    MKCoordinateRegion regionThatFits = [self.mapView regionThatFits:region];
    
    [UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.mapView setRegion:regionThatFits animated:animate];
    } completion:nil];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *annotationIdentifer = @"assignment-annotation";
    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifer];
    annotationView = nil; // clear these to force redraw, avoid yellow annotations that shoud be green and visa versa
    
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifer];
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        container.backgroundColor = [UIColor clearColor];
        
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(25.5, 25.5, 24, 24)];
        whiteView.layer.cornerRadius = 12;
        whiteView.backgroundColor = [UIColor whiteColor];
        
        whiteView.layer.shadowColor = [UIColor blackColor].CGColor;
        whiteView.layer.shadowOffset = CGSizeMake(0, 2);
        whiteView.layer.shadowOpacity = 0.15;
        whiteView.layer.shadowRadius = 1.5;
        whiteView.layer.shouldRasterize = YES;
        whiteView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(4, 4, 16, 16)];
        view.layer.cornerRadius = 8;
        
        view.backgroundColor = [UIColor frescoOrangeColor];
        
        
        [whiteView addSubview:view];
        [container addSubview:whiteView];
        [annotationView addSubview:container];
        
        annotationView.enabled = YES;
        annotationView.frame = CGRectMake(0, 0, 75, 75);
    } else {
        annotationView.annotation = annotation;
    }
    return annotationView;
}

@end
