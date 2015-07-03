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
@end

@implementation FirstRunRadiusViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate setupLocationManager];
    [appDelegate setupLocationMonitoring];
    
    self.radiusStepper.value = 5;
    [self sliderValueChanged:self.radiusStepper];
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
    
    NSString *pluralizer = (roundedValue > 1 || roundedValue == 0) ? @"s" : @"";
    
    NSString *newValue = [NSString stringWithFormat:@"%2.0f mile%@", roundedValue, pluralizer];
    
    // only update changes
    if (![self.radiusStepperLabel.text isEqualToString:newValue])
        self.radiusStepperLabel.text = newValue;
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

    [[FRSDataManager sharedManager] updateFrescoUserSettingsWithParams:updateParams
                                                                 block:^(id responseObject, NSError *error) {
                                                                     NSString *title;
                                                                     NSString *message;
                                                                     if (error) {
                                                                         title = @"Error";
                                                                         message = @"Could not save notification radius";
                                                                         
                                                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                                                                         message:message
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
