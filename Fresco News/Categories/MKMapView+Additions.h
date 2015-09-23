//
//  MKMapView+Additions.h
//  FrescoNews
//
//  Created by Fresco News on 4/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import MapKit;
#import <DBImageColorPicker.h>
#import "FRSMKCircle.h"

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
- (void)zoomToCoordinates:(NSNumber*)lat lon:(NSNumber *)lon withRadius:(NSNumber *)radius withAnimation:(BOOL)animate;
- (void)zoomToCurrentLocation;
- (void)updateUserLocationCircleWithRadius:(CGFloat)radius;
- (void)updateUserPinViewForMapView: (MKMapView *)mapView withImage: (UIImage *)image;
- (void)userRadiusUpdated:(NSNumber *)radius;

+ (DBImageColorPicker *)createDBImageColorPickerForUserWithImage:(UIImage *)image;

+ (MKCircleRenderer *)radiusRendererForOverlay:(id<MKOverlay>)overlay withImagePicker:(DBImageColorPicker *)picker;

- (void)updateRadiusColor;

- (void)removeAllOverlaysButUser;

// Annotation Views
- (MKAnnotationView *)setupAssignmentPinForAnnotation:(id <MKAnnotation>)annotation withType:(FRSAnnotationType)type;

- (MKAnnotationView *)setupUserPinForAnnotation: (id <MKAnnotation>)annotation;

// Annotation additional views
+ (UIButton *)caret;
+ (UIImageView *)imagePinViewForAnnotationType:(FRSAnnotationType)type;

// not a MapView method but a buddy in our interface sometimes
+ (CGFloat)roundedValueForRadiusSlider:(UISlider *)slider;

+ (FRSMKCircle *)userRadiusForMap:(MKMapView *)mapView withRadius:(NSNumber *)radius;

@end
