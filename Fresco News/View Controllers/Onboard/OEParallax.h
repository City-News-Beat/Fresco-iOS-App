//
//  OEParallax.h
//  Limbus
//
//  Created by Omar Elfanek on 10/15/15.
//  Copyright © 2015 Omar Elfanek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OEParallax : UIView

+ (UIView *)createParallaxFromView:(UIView *)view withMaxX:(NSUInteger)xMax withMinX:(NSInteger)xMin withMaxY:(NSUInteger)yMax withMinY:(NSInteger)yMin;

@end
