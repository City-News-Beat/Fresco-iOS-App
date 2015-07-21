//
//  ScrollViewWithPassthrough.m
//  FrescoNews
//
//  Created by Fresco News on 4/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "ScrollViewWithPassthrough.h"

@implementation ScrollViewWithPassthrough

// if the tap hits any subview then handle it but otherwise if it hits the view
// directly, such as in the inset area, ignore the tap and let it pass through
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView* subview in self.subviews ) {
        if ( [subview hitTest:[self convertPoint:point toView:subview] withEvent:event] != nil ) {
            return YES;
        }
    }
    return NO;
}

@end
