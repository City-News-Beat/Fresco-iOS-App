//
//  FirstRunRadiusViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "MKMapView+Additions.h"
#import "FirstRunRadiusViewController.h"
#import "FRSDataManager.h"

@interface FirstRunRadiusViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapviewRadius;
@property (weak, nonatomic) IBOutlet UISlider *radiusStepper;
@property (weak, nonatomic) IBOutlet UILabel *radiusStepperLabel;
@property (nonatomic) NSArray *stepperSteps;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation FirstRunRadiusViewController

// 500 ft (.095), 2000 ft (0.38), 1, 2, 5, 10, 15, 20, 30, 40, 50

// Note: If user has declined to share location (either "when in use" or "always"), the following console warning will appear:
// Trying to start MapKit location updates without prompting for location authorization. Must call -[CLLocationManager requestWhenInUseAuthorization] or -[CLLocationManager requestAlwaysAuthorization] first.

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // build a list of stepper values
    self.stepperSteps = @[ @{@"display": @"Off", @"value" : @(0)},
                           @{@"display": @"500 ft", @"value" : @(.095)},
                           @{@"display": @"2000 ft", @"value" : @(0.38)},
                            @{@"display": @"1 mi", @"value" : @(1)},
                            @{@"display": @"2 mi", @"value" : @(2)},
                            @{@"display": @"5 mi", @"value" : @(5)},
                            @{@"display": @"10 mi", @"value" : @(10)},
                            @{@"display": @"20 mi", @"value" : @(20)},
                            @{@"display": @"30 mi", @"value" : @(30)},
                            @{@"display": @"40 mi", @"value" : @(40)},
                            @{@"display": @"50 mi", @"value" : @(50)} ];

    self.radiusStepper.value = [[[self.stepperSteps objectAtIndex:5] valueForKey:@"value"] floatValue];
    
    [self sliderValueChanged:self.radiusStepper];
    
//    // Add map overlay
//    UIView *overlayAView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mapView.frame.size.width, self.mapView.frame.size.height)];
//    UIView *overlayBView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mapView.frame.size.width, self.mapView.frame.size.height)];
//    
//    overlayAView.backgroundColor = [UIColor colorWithHex:@"#0077ff" alpha:0.26];
//    overlayBView.backgroundColor = [UIColor colorWithHex:@"#ffffff" alpha:0.54];
//    
//    
//    [self.mapView addSubview:overlayAView];
//    [self.mapView addSubview:overlayBView];
}

- (IBAction)actionDone:(id)sender
{
    [self save];
    [self navigateToMainApp];
}

- (IBAction)sliderValueChanged:(UISlider *)slider
{
    // CGFloat roundedValue = [self roundedValueForSlider:slider];
    CGFloat roundedValue = [MKMapView roundedValueForRadiusSlider:slider];
    
    if(roundedValue > 0){
        
        NSString *pluralizer = (roundedValue > 1 || roundedValue == 0) ? @"s" : @"";
        
        NSString *newValue = [NSString stringWithFormat:@"%2.0f mile%@", roundedValue, pluralizer];
        
        // only update changes
        if (![self.radiusStepperLabel.text isEqualToString:newValue])
            self.radiusStepperLabel.text = newValue;
        
    }
    else{
        
        self.radiusStepperLabel.text = @"Off";
        
    }
}

- (IBAction)sliderTouchUpInside:(UISlider *)slider
{
    self.radiusStepper.value = [MKMapView roundedValueForRadiusSlider:slider];
    [self.mapviewRadius updateUserLocationCircleWithRadius:self.radiusStepper.value * kMetersInAMile];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [mapView updateUserLocationCircleWithRadius:self.radiusStepper.value * kMetersInAMile];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    return [MKMapView circleRenderWithColor:[UIColor colorWithHex:@"#0077ff"] forOverlay:overlay];
}

#pragma mark - Utility methods

- (void)save
{
    NSDictionary *updateParams = @{@"radius" : [NSNumber numberWithInt:(int)self.radiusStepper.value]};
    
    [[FRSDataManager sharedManager] updateFrescoUserWithParams:updateParams withImageData:nil block:^(id responseObject, NSError *error) {
        
        if (error) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Could not save notification radius"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
        }

        
    }];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self save];
}

@end
