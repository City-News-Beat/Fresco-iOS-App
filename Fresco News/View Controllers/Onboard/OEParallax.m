//
//  OEParallax.m
//  Limbus
//
//  Created by Omar Elfanek on 10/15/15.
//  Copyright © 2015 Omar Elfanek. All rights reserved.
//

#import "OEParallax.h"

@implementation OEParallax

+ (UIView *)createParallaxFromView:(UIView *)view withMaxX:(NSUInteger)xMax withMinX:(NSInteger)xMin withMaxY:(NSUInteger)yMax withMinY:(NSInteger)yMin{

    NSInteger negativeX = xMin;
    NSUInteger positiveX = xMax;
    
    NSInteger negativeY = yMin;
    NSUInteger positiveY = yMax;
    
    
    UIInterpolatingMotionEffect *xValue = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    
    xValue.minimumRelativeValue = @(negativeX);
    xValue.maximumRelativeValue = @(positiveX);
    
    UIInterpolatingMotionEffect *yValue = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    yValue.minimumRelativeValue = @(negativeY);
    yValue.maximumRelativeValue = @(positiveY);
    
    //Create a motion effect group
    
    UIMotionEffectGroup *xGroup = [[UIMotionEffectGroup alloc] init];
    xGroup.motionEffects = @[xValue];
    
    UIMotionEffectGroup *yGroup = [[UIMotionEffectGroup alloc] init];
    yGroup.motionEffects = @[yValue];
    
    //Add motion effect group to image view
    
    [view addMotionEffect:xGroup];
    [view addMotionEffect:yGroup];
    
    return view;
}


@end
