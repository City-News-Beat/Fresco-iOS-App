//
//  FRSRadiusViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSRadiusViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"

#import "UIView+Helpers.h"
#import "UIFont+Fresco.h"

@import MapKit;


@interface FRSRadiusViewController()


@end

@implementation FRSRadiusViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"NOTIFICATION RADIUS";
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self configureView];
    
}


-(void)configureView{
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2 - 55)];
//    mapView.delegate = self;
    mapView.zoomEnabled = NO;
    mapView.scrollEnabled = NO;
    mapView.centerCoordinate = CLLocationCoordinate2DMake(40.00123, -70.10239);
    
    MKCoordinateRegion region;
    region.center.latitude = 40.7118;
    region.center.longitude = -74.0105;
    region.span.latitudeDelta = 0.015;
    region.span.longitudeDelta = 0.015;
    mapView.region = region;
    
    [self.view addSubview:mapView];
    
    [mapView addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
    
    UIView *sliderContainer = [[UIView alloc] initWithFrame:CGRectMake(0, mapView.frame.size.height, self.view.frame.size.width, 55)];
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
    
    UISlider *radiusSlider = [[UISlider alloc] initWithFrame:CGRectMake(52, 14, self.view.frame.size.width - 104, 28)];
    [radiusSlider setMinimumTrackTintColor:[UIColor frescoBlueColor]];
    [radiusSlider setMaximumTrackTintColor:[UIColor frescoSliderGray]];
    [sliderContainer addSubview:radiusSlider];
    
    UIImageView *smallIV = [[UIImageView alloc] initWithFrame:CGRectMake(12, 16, 24, 24)];
    smallIV.image = [UIImage imageNamed:@"radius-small"];
    [sliderContainer addSubview:smallIV];
    
    UIImageView *bigIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 12 - 24, 16, 24, 24)];
    bigIV.image = [UIImage imageNamed:@"radius-large"];
    [sliderContainer addSubview:bigIV];
    
    UIButton *rightAlignedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightAlignedButton.frame =CGRectMake(self.view.frame.size.width - 118, mapView.frame.size.height + sliderContainer.frame.size.height, 118, 44);
    [rightAlignedButton setTitle:@"SAVE RADIUS" forState:UIControlStateNormal];
    [rightAlignedButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [rightAlignedButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    
    [self.view addSubview:rightAlignedButton];
    
}

@end
