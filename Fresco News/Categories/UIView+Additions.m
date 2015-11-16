//
//  UIView+Border.m
//  Fresco
//
//  Created by Fresco News on 10/1/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "UIView+Border.h"

@implementation UIView (Border)


- (void)addBorderWithWidth:(CGFloat)width{

    CALayer *leftBorder = [CALayer layer];
    leftBorder.frame = CGRectMake(0.0f, 0.0f, width / 2, CGRectGetHeight(self.frame));
    leftBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame =CGRectMake([[UIScreen mainScreen] bounds].size.width - (width /2), 0.0f, width / 2, CGRectGetHeight(self.frame));
    rightBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height, [[UIScreen mainScreen] bounds].size.width, width);
    bottomBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, width);
    topBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
    
    [self.layer addSublayer:rightBorder];
    [self.layer addSublayer:topBorder];
    [self.layer addSublayer:bottomBorder];
    [self.layer addSublayer:leftBorder];
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

@end
