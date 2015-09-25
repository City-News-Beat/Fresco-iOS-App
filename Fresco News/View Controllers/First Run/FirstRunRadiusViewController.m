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
#import "TOSViewController.h"

@interface FirstRunRadiusViewController () <MKMapViewDelegate, FRSBackButtonDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapviewRadius;
@property (weak, nonatomic) IBOutlet UISlider *radiusStepper;
@property (weak, nonatomic) IBOutlet UILabel *radiusStepperLabel;
@property (nonatomic) NSArray *stepperSteps;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)doneButtonTapped:(id)sender;

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

    self.radiusStepper.value = [[[self.stepperSteps objectAtIndex:10] valueForKey:@"value"] floatValue];
    
    [self sliderValueChanged:self.radiusStepper];
    
    [self initBackButton];
    
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
        
        self.radiusStepperLabel.text = OFF;
        
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
    [mapView updateUserLocationCircleWithRadius:self.radiusStepper.value];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    return [MKMapView circleRenderWithColor:[UIColor frescoBlueColor] forOverlay:overlay];
}

#pragma mark - Utility methods

- (void)save {
    
    NSDictionary *updateParams = @{@"radius" : [NSNumber numberWithInt:(int)self.radiusStepper.value]};
    
    [[FRSDataManager sharedManager] updateFrescoUserWithParams:updateParams withImageData:nil block:^(BOOL success, NSError *error) {
        
        if (!success) {
            
            [self presentViewController:[[FRSAlertViewManager sharedManager]
                                         alertControllerWithTitle:ERROR
                                         message:NOTIF_RADIUS_ERROR_MSG action:DISMISS]
                               animated:YES
                             completion:nil];
        }
        else{
        
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            
            if(self.presentingViewController == nil)
                [self navigateToMainApp];
            else{
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        
        }
    }];

}

- (IBAction)doneButtonTapped:(id)sender {
    [self save];
}



- (void)initBackButton {
    
    FRSBackButton *backButton = [[FRSBackButton alloc] initWithFrame:CGRectMake(12, 24, 70, 40)];
    
    [self.view addSubview:backButton];
    
    backButton.delegate = self;
    
    backButton.tag = 10;
    
}


- (void)backButtonTapped {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
