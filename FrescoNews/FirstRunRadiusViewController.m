
//
//  FirstRunRadiusViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MKMapView+Additions.h"
#import "FirstRunRadiusViewController.h"

@interface FirstRunRadiusViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapviewRadiusMap;
@property (weak, nonatomic) IBOutlet UISlider *sliderRadius;
@property (weak, nonatomic) IBOutlet UILabel *labelRadius;
@end

@implementation FirstRunRadiusViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (IBAction)actionDone:(id)sender
{
    [self navigateToMainApp];
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    self.labelRadius.text = [NSString stringWithFormat:@"%3.0f", self.sliderRadius.value];
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [mapView zoomToCurrentLocation];
}
@end
