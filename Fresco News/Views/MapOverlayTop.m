//
//  MapOverlayTop.m
//  Fresco
//
//  Created by Nicolas Rizk on 7/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "MapOverlayTop.h"

@implementation MapOverlayTop

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // prepare the context to draw into
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the blend mode
    
    UIColor *hexBlueColor = [UIColor colorWithRed:0/255 green:119/255 blue:255/255 alpha:0.1];
    CGContextSetFillColorWithColor(context, hexBlueColor.CGColor);

    
    

    // now draw the appropriate color over the whole thing
    CGContextFillRect(context, rect);
    CGContextSetBlendMode(context, kCGBlendModeColor);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil;
    return hitView;
}

- (void) overlayTop {
    
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    self.backgroundColor = [UIColor colorWithRed:0/255 green:119/255 blue:255/255 alpha:0.26];
    
    CGContextDrawImage(context, self.bounds, self.image.CGImage);
    CGContextSetBlendMode(context, kCGBlendModeColor);
    [self.layer renderInContext:context];
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
@end
