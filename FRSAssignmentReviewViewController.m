//
//  FRSAssignmentReviewViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 7/16/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSAssignmentReviewViewController.h"
@import MapKit;
#import "FRSAssignment.h"
#import "FRSMapCircle.h"
#import "FRSAssignmentAnnotation.h"

@interface FRSAssignmentReviewViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UITextField *expirationTextField;


@end


@implementation FRSAssignmentReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationBar];
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    self.mapView.layer.cornerRadius = 3;
    self.mapView.layer.borderColor = [UIColor frescoShadowColor].CGColor;
    self.mapView.layer.borderWidth = 0.5;
    self.mapView.delegate = self;
    
    MKCoordinateRegion region;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.assignment[@"location"][@"coordinates"][0] doubleValue] longitude:[self.assignment[@"location"][@"coordinates"][1] doubleValue]];
    region.center.latitude = location.coordinate.longitude;
    region.center.longitude = location.coordinate.latitude;
    [self.mapView setRegion:region animated:YES];
    [self.view addSubview:self.mapView];
    [self zoomToCoordinates:region.center.latitude lon:region.center.longitude withRadius:@([self.assignment[@"radius"] doubleValue]) withAnimation:YES];
    [self.mapView addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
    [self addAssignmentAnnotation:self.assignment index:0];
    
    self.titleTextField.text = self.assignment[@"title"];
    self.captionTextView.text = self.assignment[@"caption"];
    
    
    // need to get expiration date from `ends_at`
    self.expirationTextField.text = self.assignment[@""];
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

- (void)addAssignmentAnnotation:(NSMutableDictionary *)dictionary index:(NSInteger)index {
    
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    FRSAssignment *assignment = [NSEntityDescription insertNewObjectForEntityForName:@"FRSAssignment" inManagedObjectContext:delegate.managedObjectContext];
    [assignment configureWithDictionary:dictionary];
    
    FRSAssignmentAnnotation *ann = [[FRSAssignmentAnnotation alloc] initWithAssignment:assignment atIndex:index];
    // create center coordinate for the assignment
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([assignment.latitude floatValue], [assignment.longitude floatValue]);
    
    // create MKCircle surroudning the annotation
    CLLocationDistance distance = [assignment.radius floatValue] * metersInAMile;
    FRSMapCircle *circle = [FRSMapCircle circleWithCenterCoordinate:coord radius:distance];
    circle.circleType = FRSMapCircleTypeAssignment;
    
    [self.mapView addOverlay:circle];
    [self.mapView addAnnotation:ann];
    
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



- (void)configureNavigationBar {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    label.text = @"REVIEW";
    label.font = [UIFont notaBoldWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [self configureBackButtonAnimated:YES];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setTitleView:label];
}

@end
