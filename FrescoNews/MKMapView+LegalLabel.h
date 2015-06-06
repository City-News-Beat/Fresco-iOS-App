//
//  MKMapView+LegalLabel.h
//  FrescoNews
//
//  Created by Jason Gresh on 4/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import MapKit;

@interface MKMapView (LegalLabel)

typedef enum {
    MKMapViewLegalLabelPositionBottomLeft = 0,
    MKMapViewLegalLabelPositionBottomCenter = 1,
    MKMapViewLegalLabelPositionBottomRight = 2,
} MKMapViewLegalLabelPosition;

@property (nonatomic, readonly) UILabel *legalLabel;

- (void)offsetLegalLabel:(CGSize)distance;
- (void)setLegalLabelCenter:(CGPoint)point;

@end
