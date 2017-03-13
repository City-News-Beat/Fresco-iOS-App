//
//  FRSRadiusViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSRadiusViewController.h"
#import "FRSLocator.h"
#import "UIView+Helpers.h"
#import "UIFont+Fresco.h"
#import "UIColor+Fresco.h"
#import "FRSAssignmentAnnotation.h"
#import "FRSMapCircle.h"
#import "FRSUser.h"
#import "FRSAlertView.h"
#import "Haneke.h"
#import "FRSConnectivityAlertView.h"
#import "FRSUserManager.h"

@import MapKit;

@interface FRSRadiusViewController () <MKMapViewDelegate>

@property (strong, nonatomic) UISlider *radiusSlider;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) FRSConnectivityAlertView *alert;

@property CGFloat miles;
@property BOOL sliderDidSlide;

@end

@implementation FRSRadiusViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    //if (self.miles) {
    //    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.miles] forKey:settingsUserNotificationRadius];
    //}
}

- (void)configureView {

    self.title = @"NOTIFICATION RADIUS";
    [self configureBackButtonAnimated:NO];
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];

    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 2 - 55)];
    self.mapView.delegate = self;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.rotateEnabled = NO;
    self.mapView.centerCoordinate = [[FRSLocator sharedLocator] currentLocation].coordinate;

    NSString *miles = [[NSUserDefaults standardUserDefaults] objectForKey:settingsUserNotificationRadius];
    CGFloat milesFloat = [miles floatValue];

    MKCoordinateRegion region;
    region.center.latitude = [[FRSLocator sharedLocator] currentLocation].coordinate.latitude;
    region.center.longitude = [[FRSLocator sharedLocator] currentLocation].coordinate.longitude;
    region.span.latitudeDelta = milesFloat / 50;
    region.span.longitudeDelta = milesFloat / 50;
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

    self.radiusSlider.value = milesFloat / 50;

    [sliderContainer addSubview:self.radiusSlider];

    UIImageView *smallIV = [[UIImageView alloc] initWithFrame:CGRectMake(12, 16, 24, 24)];
    smallIV.image = [UIImage imageNamed:@"radius-small"];
    [sliderContainer addSubview:smallIV];

    UIImageView *bigIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 12 - 24, 16, 24, 24)];
    bigIV.image = [UIImage imageNamed:@"radius-large"];
    [sliderContainer addSubview:bigIV];

    UIButton *rightAlignedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightAlignedButton.frame = CGRectMake(self.view.frame.size.width - 118, self.mapView.frame.size.height + sliderContainer.frame.size.height, 118, 44);
    [rightAlignedButton addTarget:self action:@selector(saveRadius) forControlEvents:UIControlEventTouchUpInside];
    [rightAlignedButton setTitle:@"SAVE RADIUS" forState:UIControlStateNormal];
    [rightAlignedButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [rightAlignedButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];

    [self.view addSubview:rightAlignedButton];
}

- (void)saveRadius {

    NSString *radius = [NSString stringWithFormat:@"%.0f", self.miles];

    [[FRSUserManager sharedInstance] updateUserWithDigestion:@{ @"radius" : radius }
        completion:^(id responseObject, NSError *error) {

          if (error.code == -1009) {
              NSString *title = @"";

              if (IS_IPHONE_5) {
                  title = @"UNABLE TO CONNECT";
              } else if (IS_IPHONE_6) {
                  title = @"UNABLE TO CONNECT. CHECK SIGNAL";
              } else if (IS_IPHONE_6_PLUS) {
                  title = @"UNABLE TO CONNECT. CHECK YOUR SIGNAL";
              }

              if (!self.alert) {
                  self.alert = [[FRSConnectivityAlertView alloc] initNoConnectionBannerWithBackButton:YES];
                  [self.alert show];
              }

              return;
          }

          if (error) {
              [self presentGenericError];
          }

          if (responseObject) {
              [self popViewController];
              [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.miles] forKey:settingsUserNotificationRadius];
              FRSUser *userToUpdate = [[FRSUserManager sharedInstance] authenticatedUser];
              userToUpdate.notificationRadius = @(self.miles);
              [[[FRSUserManager sharedInstance] managedObjectContext] save:Nil];
          }
        }];
}

- (void)sliderValueChanged:(UISlider *)slider {

    self.sliderDidSlide = YES;

    self.miles = slider.value * 50;

    if (slider.value == 0) {
        return;
    }

    [self zoomToCoordinates:[NSNumber numberWithDouble:[[FRSLocator sharedLocator] currentLocation].coordinate.latitude] lon:[NSNumber numberWithDouble:[[FRSLocator sharedLocator] currentLocation].coordinate.longitude] withRadius:@(self.miles) withAnimation:YES];
}

- (void)zoomToCoordinates:(NSNumber *)lat lon:(NSNumber *)lon withRadius:(NSNumber *)radius withAnimation:(BOOL)animate {
    // Span uses degrees, 1 degree = 69 miles
    MKCoordinateSpan span = MKCoordinateSpanMake(
        ([radius floatValue] / 30),
        ([radius floatValue] / 30));
    MKCoordinateRegion region = { CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]), span };
    MKCoordinateRegion regionThatFits = [self.mapView regionThatFits:region];

    [self.mapView setRegion:regionThatFits animated:animate];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    static NSString *AnnotationIdentifier = @"Annotation";
    MKAnnotationView *userCircle = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];

    if (!userCircle) {

        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];

        CGFloat circleRadius;
        if (IS_IPHONE_5) {
            circleRadius = 208;
        } else if (IS_IPHONE_6) {
            circleRadius = 248;
        } else if (IS_IPHONE_6_PLUS) {
            circleRadius = 278;
        }

        UIView *mapCircleView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - circleRadius / 2, 16, circleRadius, circleRadius)];
        mapCircleView.backgroundColor = [UIColor frescoLightBlueColor];
        mapCircleView.layer.cornerRadius = circleRadius / 2;
        [mapView addSubview:mapCircleView];

        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(circleRadius / 2 - 24 / 2, circleRadius / 2 - 24 / 2, 24, 24)];
        view.backgroundColor = [UIColor whiteColor];

        view.layer.cornerRadius = 12;
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(0, 2);
        view.layer.shadowOpacity = 0.15;
        view.layer.shadowRadius = 1.5;
        view.layer.shouldRasterize = YES;
        view.clipsToBounds = YES;
        view.layer.rasterizationScale = [[UIScreen mainScreen] scale];

        [mapCircleView addSubview:view];

        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(circleRadius / 2 - 18 / 2, circleRadius / 2 - 18 / 2, 18, 18);
        imageView.layer.cornerRadius = 9;
        imageView.clipsToBounds = YES;
        [mapCircleView addSubview:imageView];

        if ([FRSUserManager sharedInstance].authenticatedUser.profileImage) {

            NSString *link = [[FRSUserManager sharedInstance].authenticatedUser valueForKey:@"profileImage"];
            NSURL *url = [NSURL URLWithString:link];
            [imageView hnk_setImageFromURL:url];

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
