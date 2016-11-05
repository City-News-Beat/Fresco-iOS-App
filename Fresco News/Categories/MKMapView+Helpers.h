////
////  MKMapView+Helpers.h
////  FrescoNews
////
////  Created by Fresco News on 4/29/15.
////  Copyright (c) 2015 Fresco. All rights reserved.
////
//
//@import MapKit;
//
//#import "FRSMapCircle.h"
//#import "DBImageColorPicker.h"
//
//
//@interface MKMapView (Helpers)
//
//typedef enum {
//    MKMapViewLegalLabelPositionBottomLeft = 0,
//    MKMapViewLegalLabelPositionBottomCenter = 1,
//    MKMapViewLegalLabelPositionBottomRight = 2,
//} MKMapViewLegalLabelPosition;
//
//typedef enum : NSInteger {
//    FRSAssignmentAnnotation = 0,
//    FRSUserAnnotation = 1,
//    FRSClusterAnnotation = 2
//} FRSAnnotationType;
//
///**
// *  Zoom to specified coordinates
// *  Note: All values passed into these functions are in meters
// *
// *  @param lat     Latitude to zoom to
// *  @param lon     Longitude to zoom to
// *  @param radius  Radius to be within
// *  @param animate Animate zoom
// */
//
//- (void)zoomToCoordinates:(NSNumber*)lat lon:(NSNumber *)lon withRadius:(NSNumber *)radius withAnimation:(BOOL)animate;
//
///**
// *  Zooms to user location of the class map
// */
//
//- (void)zoomToCurrentLocation;
//
///**
// *  Adds overlay to map for user location
// *
// *  @param radius Radius of the user location overlay
// */
//
////- (void)updateUserLocationCircleWithRadius:(CGFloat)radius;
//
//
//-(void)updateUserCircleWithLocation:(CLLocationCoordinate2D)location withRadius:(CGFloat)radius;
//
///**
// *  Finds user annotaiton in map, and reset to the passed image
// *
// *  @param image   Image to set the user pin to
// */
//
//
//
//- (void)updateUserPinViewForMapViewWithImage:(UIImage *)image;
//
///**
// *  Method to remove and re-add the user's radius
// *
// *  @param radius Radius to reset to
// */
//
//- (void)userRadiusUpdated:(NSNumber *)radius;
//
//- (void)updateRadiusColor;
//
//- (void)removeAllOverlaysButUser;
//
//#pragma mark - Annotation Views
//
///**
// *  Sets up an assignment annotation
// *
// *  @param annotation MKAnnotation that is to be associated with annotiation view
// *  @param type       FRSAnnotationType
// *
// *  @return MKAnnotationView for Assignment Annotation
// */
//
//- (MKAnnotationView *)setupAssignmentPinForAnnotation:(id <MKAnnotation>)annotation withType:(FRSAnnotationType)type;
//
///**
// *  Returns MKAnnotationView for User Annotation
// *
// *  @param annotation MKAnnotation that is to be associated with annotiation view
// *
// *  @return <#return value description#>
// */
//
//- (MKAnnotationView *)setupUserPinForAnnotation:(id <MKAnnotation>)annotation;
//
///**
// *  Returns DBImageColorPicker, with optinal image paramater
// *
// *  @param image Image to assocaite DBImageColorPicker with
// *
// *  @return a DBImageColorPicker with passed image
// */
//
//+ (DBImageColorPicker *)createDBImageColorPickerForUserWithImage:(UIImage *)image;
//
///**
// *  Returns MKCircleRenderer for user/assignments
// *
// *  @param overlay MKOverlay that is to be associated with renderer
// *  @param picker  Color picker holding color of renderer
// *
// *  @return renderer representing overlay
// */
//
//+ (MKCircleRenderer *)radiusRendererForOverlay:(id<MKOverlay>)overlay withImagePicker:(DBImageColorPicker *)picker;
//
///**
// *  Returns UIButton for disclosure indicator
// *
// *  @return UIButton for disclosure indicator
// */
//
//+ (UIButton *)caret;
//
//
///**
// *  Helper method to set image for pin view
// *
// *  @param type Type of annotation
// *
// *  @return returns a UIImageView for the annotation
// */
//
//+ (UIImageView *)imagePinViewForAnnotationType:(FRSAnnotationType)type;
//
///**
// *  Returns value for slider, casted to an int
// *
// *  @param CGFloat <#CGFloat description#>
// *
// *  @return <#return value description#>
// */
//
//+ (CGFloat)roundedValueForRadiusSlider:(UISlider *)slider;
//
///**
// *  Returns radius for user annotation view, has option of using the margin of error
// *
// *  @param mapView mapView for the static method
// *  @param radius  Radius of the user radius circle
// *
// *  @return <#return value description#>
// */
//
//+(FRSMapCircle *)circleInMapView:(MKMapView *)mapView forUserWithRadius:(NSNumber *)radius location:(CLLocationCoordinate2D)location;
//
//@end
