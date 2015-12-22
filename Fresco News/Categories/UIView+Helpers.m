//
//  UIView+Helpers.m
//  Fresco
//
//  Created by Daniel Sun on 11/16/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "UIView+Helpers.h"
#import "UIColor+Fresco.h"

@implementation UIView (Helpers)

- (void)addBorderWithWidth:(CGFloat)width{
//    
//    CALayer *leftBorder = [CALayer layer];
//    leftBorder.frame = CGRectMake(0.0f, 0.0f, width / 2, CGRectGetHeight(self.frame));
//    leftBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
//    
//    CALayer *rightBorder = [CALayer layer];
//    rightBorder.frame =CGRectMake([[UIScreen mainScreen] bounds].size.width - (width /2), 0.0f, width / 2, CGRectGetHeight(self.frame));
//    rightBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
//    
//    CALayer *bottomBorder = [CALayer layer];
//    bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height, [[UIScreen mainScreen] bounds].size.width, width);
//    bottomBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
//    
//    CALayer *topBorder = [CALayer layer];
//    topBorder.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, width);
//    topBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
//    
//    [self.layer addSublayer:rightBorder];
//    [self.layer addSublayer:topBorder];
//    [self.layer addSublayer:bottomBorder];
//    [self.layer addSublayer:leftBorder];
    
}

- (void)centerHorizontallyInView:(UIView *)superView{
    CGRect oldFrame = self.frame;
    NSInteger xOrigin = (superView.frame.size.width - self.frame.size.width)/2;
    self.frame = CGRectMake(xOrigin, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
}

-(void)centerVerticallyInView:(UIView *)superView{
    CGRect oldFrame = self.frame;
    NSInteger yOrigin = (superView.frame.size.height - self.frame.size.height)/2;
    self.frame = CGRectMake(oldFrame.origin.x, yOrigin, oldFrame.size.width, oldFrame.size.height);
}

-(void)addBorderWithWidth:(CGFloat)width color:(UIColor *)color{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

-(void)clipAsCircle{
    self.layer.cornerRadius = self.frame.size.width/2.0;
    self.clipsToBounds = YES;
}

/**
 *  Adds drop shadow with radius 2, opacity 1, and an offset of (1,2).
 *
 *  @param color Color of Shadow
 *  @param path  Optional property (can be nil) for the path of the shadow
 */

-(void)addDropShadowWithColor:(UIColor *)color path:(UIBezierPath *)path{
    if (color == nil){
        self.layer.shadowColor = nil;
    }
    else {
        self.layer.shadowColor = color.CGColor;
    }
    self.layer.shadowOffset = CGSizeMake(1, 2);
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowRadius = 2.0;
    if (path){
        self.layer.shadowPath = path.CGPath;
    }
}


@end
