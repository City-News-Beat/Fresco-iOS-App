//
//  MKMapView+Additions.h
//  FrescoNews
//
//  Created by Fresco News on 4/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import MapKit;

@interface MKMapView (Additions)

typedef enum {
    MKMapViewLegalLabelPositionBottomLeft = 0,
    MKMapViewLegalLabelPositionBottomCenter = 1,
    MKMapViewLegalLabelPositionBottomRight = 2,
} MKMapViewLegalLabelPosition;

#define kMetersInAMile 1609.34

@property (nonatomic, readonly) UILabel *legalLabel;

- (void)offsetLegalLabel:(CGSize)distance;
- (void)setLegalLabelCenter:(CGPoint)point;
- (void)zoomToCoordinates:(NSNumber*)lat lon:(NSNumber *)lon withRadius:(NSNumber *)radius;
- (void)zoomToCurrentLocation;
+ (MKCircleRenderer *)circleRenderWithColor:(UIColor *)color forOverlay:(id<MKOverlay>)overlay;
+ (MKAnnotationView *)setupPinForAnnotation:(id <MKAnnotation>)annotation withAnnotationView:(MKAnnotationView *)annotationView;
- (void)updateUserLocationCircleWithRadius:(CGFloat)radius;

// not a MapView method but a buddy in our interface sometimes
+ (CGFloat)roundedValueForRadiusSlider:(UISlider *)slider;

+ (void)updateUserPinViewForMapView: (MKMapView *)mapView WithImage: (UIImage *)image;
+ (void)addShadowToAnnotationView:(MKAnnotationView *)annotationView;

@end
