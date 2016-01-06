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

    
    CALayer *leftBorder = [CALayer layer];
    leftBorder.frame = CGRectMake(0.0f, 0.0f, width / 2, CGRectGetHeight(self.frame));
    leftBorder.backgroundColor = [UIColor blackColor].CGColor;
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame =CGRectMake([[UIScreen mainScreen] bounds].size.width - (width /2), 0.0f, width / 2, CGRectGetHeight(self.frame));
    rightBorder.backgroundColor = [UIColor blackColor].CGColor;
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height, [[UIScreen mainScreen] bounds].size.width, width);
    bottomBorder.backgroundColor = [UIColor blackColor].CGColor;
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, width);
    topBorder.backgroundColor = [UIColor blackColor].CGColor;
    
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

-(void)setOriginWithPoint:(CGPoint)origin{
    self.frame = CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height);
}

-(void)setSizeWithSize:(CGSize)size{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

-(void)addBorderWithWidth:(CGFloat)width color:(UIColor *)color{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

-(void)clipAsCircle{
    self.layer.cornerRadius = self.frame.size.width/2.0;
    self.clipsToBounds = YES;
}

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
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

-(void)addShadowWithColor:(UIColor *)color radius:(CGFloat)radius offset:(CGSize)offset{
    UIColor *shadowColor = color ? : [UIColor frescoShadowColor];
    CGFloat shadowRadius = radius ? : 2;
    
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowRadius = shadowRadius;
    self.layer.shadowOffset = offset;
}

+(UIView *)lineAtPoint:(CGPoint)point{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, [UIScreen mainScreen].bounds.size.width, 0.5)];
    line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
    return line;
}


@end
