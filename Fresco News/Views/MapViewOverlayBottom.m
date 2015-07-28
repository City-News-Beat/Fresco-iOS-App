//
//  MapViewOverlay.m
//  Fresco
//
//  Created by Nicolas Rizk on 7/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "MapViewOverlayBottom.h"
#import <UIKit/UIKit.h>

@implementation MapViewOverlayBottom

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // prepare the context to draw into
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the blend mode
    UIColor *transluscentWhiteColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.54];
    CGContextSetFillColorWithColor(context, transluscentWhiteColor.CGColor);
    // now draw the appropriate color over the whole thing
    CGContextFillRect(context, rect);
    CGContextSetBlendMode(context, kCGBlendModeLuminosity);

}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil;
    return hitView;
}

//- (void) overlayBottom {
//    
//    UIGraphicsBeginImageContext(self.bounds.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//  
//    self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.54];
//    CGContextDrawImage(context, self.bounds, self.image.CGImage);
//    CGContextSetBlendMode(context, kCGBlendModeLuminosity);
//    [self.layer renderInContext:context];
//    self.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//}
@end
