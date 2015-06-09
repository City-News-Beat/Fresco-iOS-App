//
//  MKMapView+LegalLabel.m
//  FrescoNews
//
//  Created by Jason Gresh on 4/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "MKMapView+LegalLabel.h"

@implementation MKMapView (LegalLabel)

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

// Zoom to specified coordinates
- (void)zoomToCoordinates:(NSNumber*)lat lon:(NSNumber *)lon withRadius:(NSNumber *)radius
{
    //Span uses degrees, 1 degree = 69 miles
    MKCoordinateSpan span = MKCoordinateSpanMake(([radius floatValue] / 30.0), ([radius floatValue] / 30.0));
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
@end