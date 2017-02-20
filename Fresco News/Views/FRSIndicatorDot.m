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
    
    int size = 12;
    int yPos = 30;
    int maskDiameter = 5;
    
    // When rendered, containerDot acts as the masking ring around the yellow dot.
    UIView *containerDot = [[UIView alloc] initWithFrame:CGRectMake(0, yPos, size, size)];
    containerDot.backgroundColor = [UIColor frescoTabBarColor];
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
    
    // Calculate x position of containerDot and set the frame.
    CGFloat tabBarItemCount = tabBar.items.count;
    CGFloat halfItemWidth = CGRectGetWidth([UIScreen mainScreen].bounds) /( tabBarItemCount *2);
    CGFloat xOffset = halfItemWidth * (index * 2 +1);
    CGFloat halfImageWidth = [tabBar.items objectAtIndex:index].selectedImage.size.width/2;
    
    containerDot.frame = CGRectMake(xOffset + halfImageWidth, containerDot.frame.origin.y, containerDot.frame.size.width, containerDot.frame.size.height);
    
    if (animated) {
        containerDot.transform = CGAffineTransformMakeScale(0.001, 0.001);
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            containerDot.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                containerDot.transform = CGAffineTransformMakeScale(1, 1);
            } completion:nil];
        }];
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

@end
