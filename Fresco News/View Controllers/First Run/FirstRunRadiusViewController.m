//
//  FirstRunRadiusViewController.m
//  FrescoNews
//
//  Created by Fresco News on 4/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "MKMapView+Additions.h"
#import "FirstRunRadiusViewController.h"
#import "FRSDataManager.h"
#import "TOSViewController.h"
#import "UIView+Border.h"
#import <DBImageColorPicker.h>

@interface FirstRunRadiusViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapviewRadius;
@property (weak, nonatomic) IBOutlet UISlider *radiusStepper;
@property (weak, nonatomic) IBOutlet UILabel *radiusStepperLabel;

@property (nonatomic) NSArray *stepperSteps;

@property (assign, nonatomic) BOOL ranUserUpdate;

@property (strong, nonatomic) DBImageColorPicker *picker;

@end

@implementation FirstRunRadiusViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self sliderValueChanged:self.radiusStepper];
    
    [[self.view viewWithTag:100] addBorderWithWidth:1.0f];
    [[self.view viewWithTag:101] addBorderWithWidth:1.0f];
    
}


- (IBAction)sliderValueChanged:(UISlider *)slider
{
    
    dispatch_async(dispatch_get_main_queue(), ^{

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
        
    });
}

- (IBAction)sliderTouchUpInside:(UISlider *)slider
{
    self.radiusStepper.value = [MKMapView roundedValueForRadiusSlider:slider];
    
    [self.mapviewRadius updateUserLocationCircleWithRadius:self.radiusStepper.value];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(!self.ranUserUpdate){
        [mapView updateUserLocationCircleWithRadius:self.radiusStepper.value];
        self.ranUserUpdate = YES;
    }

}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    return [MKMapView radiusRendererForOverlay:overlay withImagePicker:self.picker];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    return [self.mapviewRadius setupUserPinForAnnotation:annotation];
    
}

#pragma mark - Utility methods

- (void)save {
    
    [self dismissViewControllerAnimated:YES completion:nil];

    
    NSDictionary *updateParams = @{@"radius" : [NSNumber numberWithInt:(int)self.radiusStepper.value]};
    
    [[FRSDataManager sharedManager] updateFrescoUserWithParams:updateParams withImageData:nil block:^(BOOL success, NSError *error) {
        
        if (!success) {
            
            [self presentViewController:[FRSAlertViewManager
                                         alertControllerWithTitle:ERROR
                                         message:NOTIF_RADIUS_ERROR_MSG action:DISMISS]
                               animated:YES
                             completion:nil];
        }
        else{
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        
        }

    }];

}


@end
