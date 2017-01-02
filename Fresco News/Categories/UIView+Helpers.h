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
- (void)centerHorizontallyInView:(UIView *)superView;

/**
 *  Auto-centers the view vertically in its container view
 *
 *  @param superView The view in which the image view is contained
 */
- (void)centerVerticallyInView:(UIView *)superView;

/**
 *  Sets the view's origin while retaining size
 *
 *  @param origin A CGPoint which represents the view's origin in the x-y plane
 */
- (void)setOriginWithPoint:(CGPoint)origin;

/**
 *  Sets the view's size while retaining its origin
 *
 *  @param size A CGSize which represents the view's size in the x-y plane
 */
- (void)setSizeWithSize:(CGSize)size;

/**
 *  Convenience method for adding a border to a view
 *
 *  @param width The width of the border
 *  @param color The color of the border
 */
- (void)addBorderWithWidth:(CGFloat)width color:(UIColor *)color;

/**
 *  Sets the corner radius to be half of the view's width and sets its clipsToBounds property to YES
 */
- (void)clipAsCircle;

/**
 *  Adds drop shadow with radius 2, opacity 1, and y offset of 2.
 *
 *  @param color Color of Shadow
 *  @param path  Optional property (can be nil) for the path of the shadow
 */

- (void)addDropShadowWithColor:(UIColor *)color path:(UIBezierPath *)path;

/**
 
 *Adds a shadow with the supplied color, radius, and offset
 *
 *@param color Color of shadow. If nil, default color will be applied
 *@param radius Radius of shadow. If nil, default radius of 2 will be applied
 *@param offset Offset of shadow. Required to be passed in
 *
*/
- (void)addShadowWithColor:(UIColor *)color radius:(CGFloat)radius offset:(CGSize)offset;

- (void)addFixedShadow;

+ (UIView *)lineAtPoint:(CGPoint)point;

@end
