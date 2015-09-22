//
//  MKMapView+LegalLabel.m
//  FrescoNews
//
//  Created by Fresco News on 4/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "MKMapView+Additions.h"
#import "FRSDataManager.h"
#import <SVPulsingAnnotationView.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "CALayer+Additions.h"

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
- (void)zoomToCoordinates:(NSNumber*)lat lon:(NSNumber *)lon withRadius:(NSNumber *)radius withAnimation:(BOOL)animate
{
    // Span uses degrees, 1 degree = 69 miles
    MKCoordinateSpan span = MKCoordinateSpanMake(
                                                 ([radius floatValue] / 30),
                                                 ([radius floatValue] / 30)
                                                 );
    MKCoordinateRegion region = {CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]), span};
    MKCoordinateRegion regionThatFits = [self regionThatFits:region];
    
    [self setRegion:regionThatFits animated:animate];
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


/*
 ** Adds radius to user annotation view
 */

+ (FRSMKCircle *)userRadiusForMap: (MKMapView *)mapView {
    
    MKUserLocation *userLocation = mapView.userLocation;
    
    FRSMKCircle *circle = [FRSMKCircle circleWithCenterCoordinate:userLocation.coordinate radius:mapView.userLocation.location.horizontalAccuracy];
    
    circle.identifier = FRSUserCircle;
    
    return circle;
}

- (void)updateUserLocationCircleWithRadius:(CGFloat)radius
{
    CLLocationCoordinate2D coordinate = self.userLocation.location.coordinate;
    
    [self zoomToCoordinates:[NSNumber numberWithDouble:coordinate.latitude]
                                      lon:[NSNumber numberWithDouble:coordinate.longitude]
                               withRadius:[NSNumber numberWithDouble:radius] withAnimation:YES];
    
    [self addRadiusCircle:radius];
}

- (void)addRadiusCircle:(CGFloat)radius
{
    CLLocationCoordinate2D coordinate = self.userLocation.location.coordinate;
    
    FRSMKCircle *circle = [FRSMKCircle circleWithCenterCoordinate:coordinate radius:(radius * kMetersInAMile)];
    
    [self removeOverlays:self.overlays];
    [self addOverlay:circle];
}

+ (DBImageColorPicker *)createDBImageColorPicker {

    NSData *userProfileImageData = [[NSData alloc] initWithContentsOfURL:[[FRSDataManager sharedManager].currentUser avatarUrl]];

    UIImage *userProfileImage = [UIImage imageWithData:userProfileImageData];

    return [[DBImageColorPicker alloc] initFromImage:userProfileImage withBackgroundType:DBImageColorPickerBackgroundTypeDefault];
}

+ (MKCircleRenderer *)customRendererForOverlay:(id<MKOverlay>)overlay forColorPicker:(DBImageColorPicker *)picker
{

    MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    
    if ([overlay isKindOfClass:[FRSMKCircle class]]) {
        
        FRSMKCircle *circleForUserRadius = (FRSMKCircle *)overlay;
        
        if (circleForUserRadius.identifier == FRSUserCircle) { // making sure it's a user
            
            if ([FRSDataManager sharedManager].currentUser.avatar) { // if they have a profile pic
                
                [circleView setFillColor:picker.secondaryTextColor];
                
            } else { // use default fresco blue
                
                [circleView setFillColor:[UIColor frescoBlueColor]];
            }
        }
        
    } else // it's an assignment
        [circleView setFillColor:[UIColor radiusGoldColor]];
    
    circleView.alpha = .26;
    
    return circleView;


}

- (void)updateRadiusColor {
    
    for (id<MKOverlay>overlay in self.overlays) {
        if ([overlay isKindOfClass:[FRSMKCircle class]]) {
            FRSMKCircle *circle = (FRSMKCircle *)overlay;
            [self removeOverlay:circle];
            [self addOverlay:circle];
        }
    }
    
}


+ (UIButton *)caret {
    
    UIButton *caret = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    [caret setImage:[UIImage imageNamed:@"disclosure"] forState:UIControlStateNormal];
    
    caret.frame = CGRectMake(caret.frame.origin.x, caret.frame.origin.x, 10.0f, 15.0f);
    
    caret.contentMode = UIViewContentModeScaleAspectFit;
    
    return caret;
}

+ (MKAnnotationView *)setupAssignmentPinForAnnotation:(id <MKAnnotation>)annotation ForMapView: (MKMapView *)mapView AndType: (FRSAnnotationType) type{
    
    NSString *identifier = (type == FRSAssignmentAnnotation) ? ASSIGNMENT_IDENTIFIER : CLUSTER_IDENTIFIER;
   
    MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView) {
        
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        
        annotationView.centerOffset = CGPointMake(0, 1.5); // offset the shadow
        
        [annotationView setImage:[MKMapView imagePinViewForAnnotationType:FRSAssignmentAnnotation].image];
        
        annotationView.enabled = YES;
        
        if (type == FRSAssignmentAnnotation) {
            
            annotationView.canShowCallout = YES;
            
            annotationView.rightCalloutAccessoryView = [MKMapView caret];
            
        }
    }
    return annotationView;
}

+ (MKAnnotationView *)setupUserPinForAnnotation: (id <MKAnnotation>)annotation
                                     ForMapView: (MKMapView *)mapView {

    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:USER_IDENTIFIER];
    
    if (!annotationView) {
        
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:USER_IDENTIFIER];
        
        annotationView.centerOffset = CGPointMake(-13, -15 + 3); // math is account for 18 width and 5 x, 18 height and 3 y w, 3 pts shadow
        
        UIImage *whiteLayerImage = [UIImage imageNamed:@"dot-user-blank"];
        
        UIImageView *whiteLayerImageView = [[UIImageView alloc] initWithImage:whiteLayerImage];
        
        UIImageView *profileImageView = [MKMapView imagePinViewForAnnotationType:FRSUserAnnotation];

        [profileImageView.layer addPulsingAnimation];
        
        [whiteLayerImageView addSubview:profileImageView];
        
        [annotationView addSubview:whiteLayerImageView];
    }
    
    return annotationView;
}

/*
** Helper method to set image for pin view
*/

+ (UIImageView *)imagePinViewForAnnotationType: (FRSAnnotationType)type {
    
    UIImageView *customPinView = [[UIImageView alloc] init];
    
    CGRect frame = CGRectMake(5, 3, 18, 18);
    
    if (type == FRSAssignmentAnnotation || type == FRSClusterAnnotation) { // is Assignment annotation view
        
        [customPinView setImage:[UIImage imageNamed:@"dot-assignment"]];
        
    } else if (type == FRSUserAnnotation) { // is User annotation view
        
        if ([FRSDataManager sharedManager].currentUser.avatar != nil) {
            
            [customPinView setImageWithURL:[[FRSDataManager sharedManager].currentUser avatarUrl] placeholderImage:[UIImage imageNamed:@"dot-user-fill"]];
   
        } else {
            [customPinView setImage:[UIImage imageNamed:@"dot-user-fill"]];
            
        }
       
    } else {
        [customPinView setImage:[UIImage imageNamed:@"dot-user-fill"]];

    }
    
    customPinView.frame = frame;
    customPinView.layer.masksToBounds = YES;
    customPinView.layer.cornerRadius = customPinView.frame.size.width / 2;
    
    return customPinView;
}


- (void)updateUserPinViewForMapView:(MKMapView *)mapView withImage: (UIImage *)image {
    
    if (image != nil) {
        
        for (id<MKAnnotation> annotation in mapView.annotations){
            
            if (annotation == mapView.userLocation){
                
                MKAnnotationView *profileAnnotation = [mapView viewForAnnotation:annotation];
                
                if ([profileAnnotation.subviews count] > 0){
                    
                    if ([(UIImageView *)(((UIView *)profileAnnotation.subviews[0]).subviews[0]) isKindOfClass:[UIImageView class]]) {
                        UIImageView *profileImageView = (UIImageView *)(((UIView *)profileAnnotation.subviews[0]).subviews[0]);
                        [profileImageView setImage:image];
                        
                    }
                    
                }
                
            }
        }
    }
}

- (void)userLocationUpdated {
    
    for (id<MKOverlay>overlay in self.overlays) {
        
        if ([overlay isKindOfClass:[FRSMKCircle class]]) {
            
            FRSMKCircle *userCircleRadius = (FRSMKCircle *)overlay;
            [self removeOverlay:userCircleRadius];
        }
    }
    
    [self addOverlay:[MKMapView userRadiusForMap:self]];
}

@end