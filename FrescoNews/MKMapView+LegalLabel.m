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
@end