//
//  MKMapView+LegalLabel.m
//  FrescoNews
//
//  Created by Jason Gresh on 4/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "MKMapView+Additions.h"

@implementation MKMapView (Additions)

#pragma mark - Legal Label
- (UILabel *)legalLabel
{
    return [self.subviews objectAtIndex:1];
}

- (void)offsetLegalLabel:(CGSize)distance
{
    UILabel *label = self.legalLabel;
    CGPoint point = label.center;
    point.x += distance.width;
    point.y += distance.height;
    label.center = point;
}

- (void)setLegalLabelCenter:(CGPoint)point
{
    UILabel *label = self.legalLabel;
    label.center = point;
}

#pragma mark - Zooming
// Zoom to specified coordinates
// Note: All values passed into these functions are in meters
- (void)zoomToCoordinates:(NSNumber*)lat lon:(NSNumber *)lon withRadius:(NSNumber *)radius
{
    // Span uses degrees, 1 degree = 69 miles (very sort of)
    MKCoordinateSpan span = MKCoordinateSpanMake(([radius floatValue] / (30.0 * kMetersInAMile)), ([radius floatValue] / (30.0 * kMetersInAMile)));
    MKCoordinateRegion region = {CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]), span};
    MKCoordinateRegion regionThatFits = [self regionThatFits:region];
    [self setRegion:regionThatFits animated:YES];
}

// Zooms to user location
- (void)zoomToCurrentLocation
{
    MKCoordinateSpan span = MKCoordinateSpanMake(0.0002f, 0.0002f);
    MKCoordinateRegion region = {self.userLocation.location.coordinate, span};
    MKCoordinateRegion regionThatFits = [self regionThatFits:region];
    [self setRegion:regionThatFits animated:YES];
}

+ (CGFloat)roundedValueForRadiusSlider:(UISlider *)slider
{
    CGFloat roundedValue;
    if (slider.value < 10)
        roundedValue = (int)slider.value;
    else
        roundedValue = ((int)slider.value / 10) * 10;
    
    return roundedValue;
}

#pragma mark - Map utility methods
- (void)updateUserLocationCircleWithRadius:(CGFloat)radius
{
    CLLocationCoordinate2D coordinate = self.userLocation.location.coordinate;
    [self zoomToCoordinates:[NSNumber numberWithDouble:coordinate.latitude]
                                      lon:[NSNumber numberWithDouble:coordinate.longitude]
                               withRadius:[NSNumber numberWithDouble:radius]];
    [self addRadiusCircle:radius];
}

- (void)addRadiusCircle:(CGFloat)radius
{
    CLLocationCoordinate2D coordinate = self.userLocation.location.coordinate;
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:radius];
    
    [self removeOverlays:self.overlays];
    [self addOverlay:circle];
}

+ (MKCircleRenderer *)circleRenderWithColor:(UIColor *)color forOverlay:(id<MKOverlay>)overlay
{
    MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    [circleView setFillColor:color];
    circleView.alpha = .26;
    return circleView;
}

@end