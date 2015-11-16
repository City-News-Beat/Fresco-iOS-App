//
//  UIView+Helpers.h
//  Fresco
//
//  Created by Daniel Sun on 11/16/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Helpers)

- (void)addBorderWithWidth:(CGFloat)width;


/**
 *  Auto-centers the view horizontally in its container view
 *
 *  @param superView The view in which the image view is contained
 */
- (void) centerHorizontallyInView:(UIView *)superView;

/**
 *  Auto-centers the view vertically in its container view
 *
 *  @param superView The view in which the image view is contained
 */
- (void) centerVerticallyInView:(UIView *)superView;

/**
 *  Convenience method for adding a border to a view
 *
 *  @param width The width of the border
 *  @param color The color of the border
 */

- (void) addBorderWithWidth:(CGFloat)width color:(UIColor *)color;

/**
 *  Sets the corner radius to be half of the view's width and sets its clipsToBounds property to YES
 */
- (void) clipAsCircle;

/**
 *  Adds drop shadow with radius 2, opacity 1, and y offset of 2.
 *
 *  @param color Color of Shadow
 *  @param path  Optional property (can be nil) for the path of the shadow
 */

-(void)addDropShadowWithColor:(UIColor *)color path:(UIBezierPath *)path;

@end
