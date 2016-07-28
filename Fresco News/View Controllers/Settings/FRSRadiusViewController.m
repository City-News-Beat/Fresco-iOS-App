//
//  FRSRadiusViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSRadiusViewController.h"

#import "FRSTableViewCell.h"
#import "FRSLocator.h"

#import "UIView+Helpers.h"
#import "UIFont+Fresco.h"
#import "UIColor+Fresco.h"
#import "FRSAssignmentAnnotation.h"
#import "FRSMapCircle.h"
#import "FRSUser.h"
#import "FRSAPIClient.h"

@import MapKit;


@interface FRSRadiusViewController() <MKMapViewDelegate>

@property (strong, nonatomic) UISlider          *radiusSlider;
@property (strong, nonatomic) MKMapView         *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property CGFloat  miles;

@end

@implementation FRSRadiusViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self configureView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.miles] forKey:@"notification-radius"];
}


-(void)configureView{
    
    self.title = @"NOTIFICATION RADIUS";
    [self configureBackButtonAnimated:NO];
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2 - 55)];
    self.mapView.delegate = self;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.rotateEnabled = NO;
    self.mapView.centerCoordinate = [[FRSLocator sharedLocator] currentLocation].coordinate;
    
    NSString *miles = [[NSUserDefaults standardUserDefaults] objectForKey:@"notification-radius"];
    CGFloat milesFloat = [miles floatValue];
    
    MKCoordinateRegion region;
    region.center.latitude = [[FRSLocator sharedLocator] currentLocation].coordinate.latitude;
    region.center.longitude = [[FRSLocator sharedLocator] currentLocation].coordinate.longitude;
    region.span.latitudeDelta = milesFloat/68;
    region.span.longitudeDelta = milesFloat/68;
    self.mapView.region = region;
    
    [self.view addSubview:self.mapView];
    
    [self.mapView addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
    
    FRSAssignmentAnnotation *annotation = [[FRSAssignmentAnnotation alloc] init];
    annotation.coordinate = [[FRSLocator sharedLocator] currentLocation].coordinate;
    [self.mapView addAnnotation:annotation];
    
    UIView *sliderContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.mapView.frame.size.height, self.view.frame.size.width, 55)];
    sliderContainer.backgroundColor = [UIColor colorWithWhite:1 alpha:.92];
    [self.view addSubview:sliderContainer];
    
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.5)];
    top.alpha = 0.2;
    top.backgroundColor = [UIColor frescoDarkTextColor];
    [sliderContainer addSubview:top];
    
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 56, self.view.bounds.size.width, 0.5)];
    bottom.alpha = 0.2;
    bottom.backgroundColor = [UIColor frescoDarkTextColor];
    [sliderContainer addSubview:bottom];
    
    self.radiusSlider = [[UISlider alloc] initWithFrame:CGRectMake(52, 14, self.view.frame.size.width - 104, 28)];
    [self.radiusSlider setMinimumTrackTintColor:[UIColor frescoBlueColor]];
    [self.radiusSlider setMaximumTrackTintColor:[UIColor frescoSliderGray]];
    [self.radiusSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.radiusSlider.value = milesFloat/68;
    
    [sliderContainer addSubview:self.radiusSlider];
    
    UIImageView *smallIV = [[UIImageView alloc] initWithFrame:CGRectMake(12, 16, 24, 24)];
    smallIV.image = [UIImage imageNamed:@"radius-small"];
    [sliderContainer addSubview:smallIV];
    
    UIImageView *bigIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 12 - 24, 16, 24, 24)];
    bigIV.image = [UIImage imageNamed:@"radius-large"];
    [sliderContainer addSubview:bigIV];
    
    UIButton *rightAlignedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightAlignedButton.frame =CGRectMake(self.view.frame.size.width - 118, self.mapView.frame.size.height + sliderContainer.frame.size.height, 118, 44);
    [rightAlignedButton addTarget:self action:@selector(saveRadius) forControlEvents:UIControlEventTouchUpInside];
    [rightAlignedButton setTitle:@"SAVE RADIUS" forState:UIControlStateNormal];
    [rightAlignedButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [rightAlignedButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    
    [self.view addSubview:rightAlignedButton];
}

-(void)saveRadius {
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.miles] forKey:@"notification-radius"];
    
    [self popViewController];
}

-(void)sliderValueChanged:(UISlider *)slider {

    self.miles = slider.value * 68;
    
    if (slider.value == 0) {
        return;
    }

    MKCoordinateRegion region;
    region.center.latitude  = [[FRSLocator sharedLocator] currentLocation].coordinate.latitude;
    region.center.longitude = [[FRSLocator sharedLocator] currentLocation].coordinate.longitude;
    region.span.latitudeDelta  = self.miles/68;
    region.span.longitudeDelta = self.miles/68;
    
    
    CLLocationCoordinate2D center = region.center;
    MKCoordinateSpan span = region.span;
    
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:(center.latitude - span.latitudeDelta * 0.5) longitude:center.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:(center.latitude + span.latitudeDelta * 0.5) longitude:center.longitude];
    NSInteger metersLatitude = [loc1 distanceFromLocation:loc2];
    NSInteger milesLatitude = metersLatitude / 1609.34;
    
    //CLLocation *location = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    
    NSLog(@"MILES LAT: %ld", (long)milesLatitude);
    
    
    self.mapView.region = region;
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString* AnnotationIdentifier = @"Annotation";
    MKAnnotationView *userCircle = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    
    if (!userCircle) {
        
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(-12, -12, 24, 24)];
        view.backgroundColor = [UIColor whiteColor];
        
        view.layer.cornerRadius = 12;
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(0, 2);
        view.layer.shadowOpacity = 0.15;
        view.layer.shadowRadius = 1.5;
        view.layer.shouldRasterize = YES;
        view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        [annotationView addSubview:view];

        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(-9, -9, 18, 18);
        imageView.layer.cornerRadius = 9;
        [annotationView addSubview:imageView];
        
        
        if ([FRSAPIClient sharedClient].authenticatedUser.profileImage) {

        } else {
            imageView.backgroundColor = [UIColor frescoBlueColor];
        }
        
        return annotationView;
        
    } else {
        userCircle.annotation = annotation;
    }
    
    return userCircle;
}



























@end
