//
//  FRSIndicatorDot.m
//  Fresco
//
//  Created by Omar Elfanek on 2/20/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSIndicatorDot.h"
#import "UIColor+Fresco.h"

@implementation FRSIndicatorDot

+ (void)addDotToTabBar:(UITabBar *)tabBar atIndex:(NSInteger)index animated:(BOOL)animated {
    
    UIView *dot = [self indicatorDotInTabBar:tabBar atIndex:index];
    
    // Calculate x position of containerDot and set the frame.
    // This calculation assumes the tab bar items are spaced out evenly.
    // Use addDotToTabBar:atPosition to place the dot at a custom x position.
    CGFloat tabBarItemCount = tabBar.items.count;
    CGFloat halfItemWidth = CGRectGetWidth([UIScreen mainScreen].bounds) /( tabBarItemCount *2);
    CGFloat xOffset = halfItemWidth * (index * 2 +1);
    CGFloat halfImageWidth = [tabBar.items objectAtIndex:index].selectedImage.size.width/2;
    
    dot.frame = CGRectMake(xOffset + halfImageWidth, dot.frame.origin.y, dot.frame.size.width, dot.frame.size.height);
    
    if (animated) {
        [self animateView:dot];
    }
}

+ (void)addDotToTabBar:(UITabBar *)tabBar atPosition:(CGFloat)position atIndex:(NSInteger)index animated:(BOOL)animated {
    
    UIView *dot = [self indicatorDotInTabBar:tabBar atIndex:index];
    dot.frame = CGRectMake(position, dot.frame.origin.y, dot.frame.size.width, dot.frame.size.height);
    
    if (animated) {
        [self animateView:dot];
    }
}

+ (void)removeDotInView:(UIView *)view atIndex:(NSInteger)index {
    for (UIView *dot in view.subviews) {
        if (dot.tag == index) {
            [dot removeFromSuperview];
            break;
        }
    }
}


/**
 Creates a yellow indicator dot in the given tab bar with the given tag.

 @param tabBar UITabBar to contain the indicator dot.
 @param index NSInteger the tag that will be assigned to the indicator dot.
 @return UIView a yellow indicator dot with a mask around it.
 */
+ (UIView *)indicatorDotInTabBar:(UITabBar *)tabBar atIndex:(NSInteger)index {
    int size = 12;
    int yPos = 30;
    int maskDiameter = 5;
    
    // When rendered, containerDot acts as the masking ring around the yellow dot.
    UIView *containerDot = [[UIView alloc] initWithFrame:CGRectMake(0, yPos, size, size)];
    containerDot.backgroundColor = tabBar.backgroundColor;
    containerDot.layer.cornerRadius = size/2;
    containerDot.layer.masksToBounds = YES;
    containerDot.layer.zPosition = 1;
    containerDot.userInteractionEnabled = NO;
    containerDot.tag = index; // Add tag to access when removing from superview.
    [tabBar addSubview:containerDot];
    
    UIView *yellowCircle = [[UIView alloc] initWithFrame:CGRectMake(maskDiameter/2, maskDiameter/2, size - maskDiameter, size - maskDiameter)];
    yellowCircle.backgroundColor = [UIColor frescoOrangeColor];
    yellowCircle.layer.cornerRadius = yellowCircle.frame.size.width/2;
    [containerDot addSubview:yellowCircle];
    
    return containerDot;
}


/**
 Animates the indicator dot into the view.

 @param view The view that will be animated.
 */
+ (void)animateView:(UIView *)view {
    view.transform = CGAffineTransformMakeScale(0.001, 0.001);
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.transform = CGAffineTransformMakeScale(1, 1);
        } completion:nil];
    }];
}

@end
