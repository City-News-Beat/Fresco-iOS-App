//
//  FRSSnapKit.m
//  Fresco
//
//  Created by Omar Elfanek on 2/6/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSSnapKit.h"

@implementation FRSSnapKit

+ (void)constrainSubview:(UIView *)subView ToBottomOfParentView:(UIView *)parentView WithHeight:(CGFloat)height {
    
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Trailing
    NSLayoutConstraint *trailing = [NSLayoutConstraint
                                    constraintWithItem:subView
                                    attribute:NSLayoutAttributeTrailing
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:parentView
                                    attribute:NSLayoutAttributeTrailing
                                    multiplier:1
                                    constant:0];
    
    //Leading
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:subView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:parentView
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1
                                   constant:0];
    
    //Bottom
    NSLayoutConstraint *bottom = [NSLayoutConstraint
                                  constraintWithItem:subView
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:parentView
                                  attribute:NSLayoutAttributeBottom
                                  multiplier:1
                                  constant:0];
    
    //Height
    NSLayoutConstraint *constantHeight = [NSLayoutConstraint
                                          constraintWithItem:subView
                                          attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:nil
                                          attribute:0
                                          multiplier:0
                                          constant:height];
    
    [parentView addConstraint:trailing];
    [parentView addConstraint:bottom];
    [parentView addConstraint:leading];
    
    [subView addConstraint:constantHeight];
}

@end
