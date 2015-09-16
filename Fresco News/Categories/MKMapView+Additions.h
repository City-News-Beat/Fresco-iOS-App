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

typedef enum : NSInteger {
    FRSAssignmentAnnotation = 0,
    FRSUserAnnotation = 1,
    FRSClusterAnnotation = 2
} FRSAnnotationType;

@property (nonatomic, readonly) UILabel *legalLabel;

// Actions
- (void)offsetLegalLabel:(CGSize)distance;
- (void)setLegalLabelCenter:(CGPoint)point;
- (void)zoomToCoordinates:(NSNumber*)lat lon:(NSNumber *)lon withRadius:(NSNumber *)radius;
- (void)zoomToCurrentLocation;
- (void)updateUserLocationCircleWithRadius:(CGFloat)radius;
+ (void)updateUserPinViewForMapView: (MKMapView *)mapView WithImage: (UIImage *)image;

// Annotation Views
+ (MKAnnotationView *)setupAssignmentPinForAnnotation: (id <MKAnnotation>)annotation
                                           ForMapView: (MKMapView *)mapView
                                              AndType: (FRSAnnotationType)type;

+ (MKAnnotationView *)setupUserPinForAnnotation: (id <MKAnnotation>)annotation
                                     ForMapView: (MKMapView *)mapView;

// Annotation additional views
+ (MKCircleRenderer *)circleRenderWithColor:(UIColor *)color forOverlay:(id<MKOverlay>)overlay;
+ (UIButton *)caret;
+ (UIImageView *)imagePinViewForAnnotationType:(FRSAnnotationType)type;

// not a MapView method but a buddy in our interface sometimes
+ (CGFloat)roundedValueForRadiusSlider:(UISlider *)slider;

@end
