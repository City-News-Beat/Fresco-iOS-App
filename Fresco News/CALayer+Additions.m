//
//  CALayer+Additions.m
//  Fresco
//
//  Created by Fresco News on 9/14/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "CALayer+Additions.h"

@implementation CALayer (Additions)

//- (CALayer *)addRadiusAnimation {
// 
//        CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
//        
//        CAAnimationGroup *pulseAnimationGroup = [CAAnimationGroup animation];
//        pulseAnimationGroup.duration = 0.3;
//        pulseAnimationGroup.repeatCount = INFINITY;
//        pulseAnimationGroup.removedOnCompletion = NO;
//        pulseAnimationGroup.timingFunction = defaultCurve;
//        
//        NSMutableArray *animations = [NSMutableArray new];
//
//
//        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
//        pulseAnimation.fromValue = @0.0;
//        pulseAnimation.toValue = @1.0;
//        pulseAnimation.duration = self.outerPulseAnimationDuration;
//        [animations addObject:pulseAnimation];
//        
//        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
//        animation.duration = 0.3;
//        animation.values = @[@0.45, @0.45, @0];
//        animation.keyTimes = @[@0, @0.2, @1];
//        animation.removedOnCompletion = NO;
//        [animations addObject:animation];
//        
//        
//        _pulseAnimationGroup.animations = animations;
//    }
//    return _pulseAnimationGroup;
//}

- (CALayer *)addPulsingAnimation {
    
    CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 1.5;
    animationGroup.repeatCount = INFINITY;
    animationGroup.removedOnCompletion = NO;
    animationGroup.autoreverses = YES;
    animationGroup.beginTime = 1;
    animationGroup.timingFunction = defaultCurve;
    animationGroup.speed = 1;
    animationGroup.fillMode = kCAFillModeBoth;
    
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    pulseAnimation.fromValue = @0.8;
    pulseAnimation.toValue = @0.98;
    pulseAnimation.duration = 1.5;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @0.8;
    opacityAnimation.toValue = @1;
    opacityAnimation.duration = 1.5;
    
    animationGroup.animations = @[pulseAnimation, opacityAnimation];
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self addAnimation:animationGroup forKey:@"pulse"];
    });
    
    return self;
}

@end
